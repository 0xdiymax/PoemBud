import { textToSpeech } from '@kit.CoreSpeechKit';

export type SpeechPlaybackStatus = 'idle' | 'loading' | 'playing' | 'paused';

const ENGINE_NAME = 'PoemBudTtsEngine';
const TTS_PLAYBACK_PREFIX = 'tts:';

export class SpeechManager {
  private static ttsEngine: textToSpeech.TextToSpeechEngine | null = null;
  private static listenerReady: boolean = false;
  private static activePlaybackKey: string = '';
  private static activeRequestId: string = '';
  private static playbackStatus: SpeechPlaybackStatus = 'idle';
  private static requestSerial: number = 0;

  static playbackKeyForPoem(poemId: string): string {
    return `${TTS_PLAYBACK_PREFIX}${poemId}`;
  }

  static normalizePinyinForTTS(text: string): string {
    return text
      .replace('万里长征人未还。', '万里长征人未还[=huan2]。')
      .replace('万里长征人未还，', '万里长征人未还[=huan2]，');
  }

  private static setPlaybackState(status: SpeechPlaybackStatus, playbackKey: string): void {
    SpeechManager.playbackStatus = status;
    SpeechManager.activePlaybackKey = playbackKey;
    AppStorage.setOrCreate<string>('poemAudioPlaybackStatus', status);
    AppStorage.setOrCreate<string>('poemAudioPlaybackRawPath', playbackKey);
    console.info(`[SpeechManager] playback status=${status} key=${playbackKey}`);
  }

  private static engineParams(online: number, person: number): textToSpeech.CreateEngineParams {
    const extraParams: Record<string, Object> = {
      'style': 'interaction-broadcast',
      'locate': 'CN',
      'name': ENGINE_NAME,
      'isBackStage': false
    };
    return {
      language: 'zh-CN',
      person,
      online,
      extraParams
    };
  }

  private static async createEngineWithFallback(): Promise<textToSpeech.TextToSpeechEngine> {
    const attempts: textToSpeech.CreateEngineParams[] = [
      SpeechManager.engineParams(0, 13),
      SpeechManager.engineParams(0, 0),
      SpeechManager.engineParams(1, 13),
      SpeechManager.engineParams(1, 0)
    ];
    let lastError: Error | null = null;

    for (let index = 0; index < attempts.length; index += 1) {
      const params = attempts[index];
      try {
        const engine = await textToSpeech.createEngine(params);
        console.info(`[SpeechManager] created TTS engine online=${params.online} person=${params.person}`);
        return engine;
      } catch (err) {
        lastError = err as Error;
        console.error(`[SpeechManager] create engine failed online=${params.online} person=${params.person} err=${JSON.stringify(err)}`);
      }
    }

    throw lastError ?? new Error('Create TTS engine failed.');
  }

  static async init(): Promise<void> {
    if (SpeechManager.ttsEngine) {
      SpeechManager.setupListener();
      return;
    }

    SpeechManager.ttsEngine = await SpeechManager.createEngineWithFallback();
    SpeechManager.setupListener();
  }

  static setupListener(): void {
    if (!SpeechManager.ttsEngine || SpeechManager.listenerReady) {
      return;
    }

    const listener: textToSpeech.SpeakListener = {
      onStart(requestId: string, response: textToSpeech.StartResponse): void {
        console.info(`[SpeechManager] onStart requestId=${requestId} response=${JSON.stringify(response)}`);
        if (requestId === SpeechManager.activeRequestId) {
          SpeechManager.setPlaybackState('playing', SpeechManager.activePlaybackKey);
        }
      },
      onComplete(requestId: string, response: textToSpeech.CompleteResponse): void {
        console.info(`[SpeechManager] onComplete requestId=${requestId} response=${JSON.stringify(response)}`);
        if (requestId === SpeechManager.activeRequestId) {
          SpeechManager.setPlaybackState('idle', '');
          SpeechManager.activeRequestId = '';
        }
      },
      onStop(requestId: string, response: textToSpeech.StopResponse): void {
        console.info(`[SpeechManager] onStop requestId=${requestId} response=${JSON.stringify(response)}`);
        if (requestId === SpeechManager.activeRequestId) {
          SpeechManager.setPlaybackState('idle', '');
          SpeechManager.activeRequestId = '';
        }
      },
      onError(requestId: string, errorCode: number, errorMessage: string): void {
        console.error(`[SpeechManager] onError requestId=${requestId} code=${errorCode} message=${errorMessage}`);
        if (requestId === SpeechManager.activeRequestId) {
          SpeechManager.setPlaybackState('idle', '');
          SpeechManager.activeRequestId = '';
        }
      },
      onData(requestId: string, _audio: ArrayBuffer, response: textToSpeech.SynthesisResponse): void {
        console.info(`[SpeechManager] onData requestId=${requestId} response=${JSON.stringify(response)}`);
      }
    };
    SpeechManager.ttsEngine.setListener(listener);
    SpeechManager.listenerReady = true;
  }

  static async speak(text: string, playbackKey: string): Promise<void> {
    await SpeechManager.init();
    const engine = SpeechManager.ttsEngine;
    if (!engine) {
      throw new Error('TTS engine is not ready.');
    }

    try {
      if (engine.isBusy()) {
        engine.stop();
      }
    } catch (_err) {
    }

    const requestId = `poembud-${new Date().getTime()}-${SpeechManager.requestSerial}`;
    SpeechManager.requestSerial += 1;
    SpeechManager.activeRequestId = requestId;
    SpeechManager.activePlaybackKey = playbackKey;
    SpeechManager.setPlaybackState('loading', playbackKey);

    const extraParams: Record<string, Object> = {
      'queueMode': 1,
      'speed': 0.85,
      'volume': 1.6,
      'pitch': 1.0,
      'languageContext': 'zh-CN',
      'audioType': 'pcm',
      'soundChannel': 3,
      'playType': 1
    };
    const speakParams: textToSpeech.SpeakParams = {
      requestId,
      extraParams
    };
    const normalizedText = SpeechManager.normalizePinyinForTTS(text);
    console.info(`[SpeechManager] speak requestId=${requestId} key=${playbackKey} text=${normalizedText}`);
    engine.speak(normalizedText, speakParams);
  }

  static async toggleSpeak(text: string, playbackKey: string): Promise<void> {
    if (SpeechManager.activePlaybackKey === playbackKey &&
      (SpeechManager.playbackStatus === 'loading' || SpeechManager.playbackStatus === 'playing')) {
      SpeechManager.stop();
      return;
    }

    await SpeechManager.speak(text, playbackKey);
  }

  static stop(): void {
    try {
      SpeechManager.ttsEngine?.stop();
    } catch (err) {
      console.error(`[SpeechManager] stop failed err=${JSON.stringify(err)}`);
    }
    SpeechManager.setPlaybackState('idle', '');
    SpeechManager.activeRequestId = '';
  }

  static shutdown(): void {
    try {
      SpeechManager.ttsEngine?.shutdown();
    } catch (err) {
      console.error(`[SpeechManager] shutdown failed err=${JSON.stringify(err)}`);
    }
    SpeechManager.ttsEngine = null;
    SpeechManager.listenerReady = false;
    SpeechManager.setPlaybackState('idle', '');
  }
}
