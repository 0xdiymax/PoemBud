import { common } from '@kit.AbilityKit';
import { audio } from '@kit.AudioKit';
import { media } from '@kit.MediaKit';

export class PoemAudioPlayer {
  private static player: media.AVPlayer | null = null;
  private static soundPool: media.SoundPool | null = null;
  private static soundPoolPromise: Promise<media.SoundPool> | null = null;
  private static soundIds: Map<string, number> = new Map();
  private static loadingSounds: Map<string, Promise<number>> = new Map();
  private static pendingLoadResolvers: Map<number, () => void> = new Map();
  private static readySoundIds: Set<number> = new Set();
  private static activeStreamId: number = -1;

  private static logMusicStreamState(): void {
    try {
      const volumeManager = audio.getAudioManager().getVolumeManager();
      const volume = volumeManager.getVolumeByStream(audio.StreamUsage.STREAM_USAGE_MUSIC);
      const muted = volumeManager.isSystemMutedForStream(audio.StreamUsage.STREAM_USAGE_MUSIC);
      console.info(`[PoemAudioPlayer] music stream volume=${volume} muted=${muted}`);
    } catch (err) {
      console.error(`Failed to read music stream state: ${JSON.stringify(err)}`);
    }
  }

  private static async logActiveRenderers(tag: string): Promise<void> {
    try {
      const streamManager = audio.getAudioManager().getStreamManager();
      const renderers = await streamManager.getCurrentAudioRendererInfoArray();
      console.info(`[PoemAudioPlayer] ${tag} activeRenderers=${JSON.stringify(renderers)}`);
    } catch (err) {
      console.error(`Failed to get current audio renderer info array (${tag}): ${JSON.stringify(err)}`);
    }
  }

  private static async ensureSoundPool(): Promise<media.SoundPool> {
    if (PoemAudioPlayer.soundPool) {
      return PoemAudioPlayer.soundPool;
    }

    if (PoemAudioPlayer.soundPoolPromise) {
      return PoemAudioPlayer.soundPoolPromise;
    }

    PoemAudioPlayer.soundPoolPromise = media.createSoundPool(4, {
      usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
      rendererFlags: 1
    }).then((soundPool: media.SoundPool) => {
      soundPool.on('loadComplete', (soundId: number) => {
        PoemAudioPlayer.readySoundIds.add(soundId);
        const resolve = PoemAudioPlayer.pendingLoadResolvers.get(soundId);
        if (resolve) {
          resolve();
          PoemAudioPlayer.pendingLoadResolvers.delete(soundId);
        }
      });
      soundPool.on('playFinishedWithStreamId', (streamId: number) => {
        if (PoemAudioPlayer.activeStreamId === streamId) {
          PoemAudioPlayer.activeStreamId = -1;
        }
      });
      soundPool.on('error', (error) => {
        console.error(`[PoemAudioPlayer] soundPool error code=${error.code} message=${error.message}`);
      });
      PoemAudioPlayer.soundPool = soundPool;
      console.info('[PoemAudioPlayer] SoundPool initialized');
      return soundPool;
    }).finally(() => {
      PoemAudioPlayer.soundPoolPromise = null;
    });

    return PoemAudioPlayer.soundPoolPromise;
  }

  private static async waitForLoadComplete(soundId: number): Promise<void> {
    if (PoemAudioPlayer.readySoundIds.has(soundId)) {
      return;
    }
    await new Promise<void>((resolve) => {
      let settled = false;
      const resolveLoad = () => {
        if (settled) {
          return;
        }
        settled = true;
        clearTimeout(timeoutId);
        resolve();
      };
      const timeoutId = setTimeout(() => {
        console.warn(`[PoemAudioPlayer] loadComplete timeout soundId=${soundId}, continue with play attempt`);
        PoemAudioPlayer.pendingLoadResolvers.delete(soundId);
        resolveLoad();
      }, 1500);

      PoemAudioPlayer.pendingLoadResolvers.set(soundId, resolveLoad);
      if (PoemAudioPlayer.readySoundIds.has(soundId)) {
        PoemAudioPlayer.pendingLoadResolvers.delete(soundId);
        resolveLoad();
      }
    });
  }

  private static async ensureSoundLoaded(context: common.UIAbilityContext, rawPath: string): Promise<number> {
    const cachedSoundId = PoemAudioPlayer.soundIds.get(rawPath);
    if (cachedSoundId !== undefined) {
      return cachedSoundId;
    }

    const loadingTask = PoemAudioPlayer.loadingSounds.get(rawPath);
    if (loadingTask) {
      return loadingTask;
    }

    const loadTask = (async () => {
      const soundPool = await PoemAudioPlayer.ensureSoundPool();
      const descriptor = await context.resourceManager.getRawFd(rawPath);
      let soundId: number = -1;

      try {
        soundId = await soundPool.load(descriptor.fd, descriptor.offset, descriptor.length);
        console.info(`[PoemAudioPlayer] load sound rawPath=${rawPath} soundId=${soundId}`);
        await PoemAudioPlayer.waitForLoadComplete(soundId);
        PoemAudioPlayer.soundIds.set(rawPath, soundId);
        return soundId;
      } finally {
        try {
          await context.resourceManager.closeRawFd(rawPath);
        } catch (_err) {
        }
        PoemAudioPlayer.loadingSounds.delete(rawPath);
      }
    })();

    PoemAudioPlayer.loadingSounds.set(rawPath, loadTask);
    return loadTask;
  }

  private static async stopCurrentPlayback(): Promise<void> {
    const streamId = PoemAudioPlayer.activeStreamId;
    PoemAudioPlayer.activeStreamId = -1;
    if (streamId > 0 && PoemAudioPlayer.soundPool) {
      try {
        await PoemAudioPlayer.soundPool.stop(streamId);
      } catch (_err) {
      }
    }

    const player = PoemAudioPlayer.player;
    PoemAudioPlayer.player = null;
    if (player) {
      try {
        await player.release();
      } catch (_err) {
      }
    }
  }

  static async playRawFile(context: common.UIAbilityContext, rawPath: string): Promise<void> {
    await PoemAudioPlayer.stopCurrentPlayback();

    PoemAudioPlayer.logMusicStreamState();
    await PoemAudioPlayer.logActiveRenderers('before-play');

    const soundPool = await PoemAudioPlayer.ensureSoundPool();
    const soundId = await PoemAudioPlayer.ensureSoundLoaded(context, rawPath);
    PoemAudioPlayer.activeStreamId = await soundPool.play(soundId, {
      loop: 0,
      rate: audio.AudioRendererRate.RENDER_RATE_NORMAL,
      leftVolume: 1.0,
      rightVolume: 1.0,
      priority: 1
    });

    console.info(`[PoemAudioPlayer] play rawPath=${rawPath} soundId=${soundId} streamId=${PoemAudioPlayer.activeStreamId}`);
    PoemAudioPlayer.logMusicStreamState();
    await PoemAudioPlayer.logActiveRenderers('playing');
  }

  static async playUri(uri: string): Promise<void> {
    await PoemAudioPlayer.stopCurrentPlayback();

    const player = await media.createAVPlayer();
    player.on('stateChange', async (state: string) => {
      try {
        console.info(`[PoemAudioPlayer] uri stateChange=${state} currentTime=${player.currentTime} duration=${player.duration}`);
        if (state === 'initialized') {
          player.audioRendererInfo = {
            content: audio.ContentType.CONTENT_TYPE_MUSIC,
            usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
            rendererFlags: 0,
            volumeMode: audio.AudioVolumeMode.SYSTEM_GLOBAL
          };
          PoemAudioPlayer.logMusicStreamState();
          await PoemAudioPlayer.logActiveRenderers('before-prepare');
          await player.prepare();
          return;
        }
        if (state === 'prepared') {
          player.setVolume(1.0);
          console.info('[PoemAudioPlayer] uri setVolume(1.0) after prepared');
          await player.play();
          return;
        }
        if (state === 'playing') {
          PoemAudioPlayer.logMusicStreamState();
          await PoemAudioPlayer.logActiveRenderers('playing');
          return;
        }
        if (state === 'completed') {
          await PoemAudioPlayer.stopCurrentPlayback();
        }
      } catch (err) {
        console.error(`Failed to advance uri AVPlayer state=${state}: ${JSON.stringify(err)}`);
        await PoemAudioPlayer.stopCurrentPlayback();
      }
    });
    player.on('error', async (error) => {
      console.error(`AVPlayer uri error: ${JSON.stringify(error)}`);
      await PoemAudioPlayer.stopCurrentPlayback();
    });

    PoemAudioPlayer.player = player;
    player.url = uri;
  }

  static async release(): Promise<void> {
    await PoemAudioPlayer.stopCurrentPlayback();

    if (PoemAudioPlayer.soundPool) {
      for (const soundId of PoemAudioPlayer.soundIds.values()) {
        try {
          await PoemAudioPlayer.soundPool.unload(soundId);
        } catch (_err) {
        }
      }
      try {
        await PoemAudioPlayer.soundPool.release();
      } catch (_err) {
      }
      PoemAudioPlayer.soundPool = null;
    }

    PoemAudioPlayer.soundIds.clear();
    PoemAudioPlayer.loadingSounds.clear();
    PoemAudioPlayer.pendingLoadResolvers.clear();
    PoemAudioPlayer.readySoundIds.clear();
  }
}
