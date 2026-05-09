import { common } from '@kit.AbilityKit';
import { audio } from '@kit.AudioKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { media } from '@kit.MediaKit';

export type PoemAudioPlaybackStatus = 'idle' | 'loading' | 'playing' | 'paused';

export class PoemAudioPlayer {
  private static player: media.AVPlayer | null = null;
  private static rawContext: common.UIAbilityContext | null = null;
  private static rawPath: string = '';
  private static localFile: fs.File | null = null;
  private static playbackStatus: PoemAudioPlaybackStatus = 'idle';
  private static playerToken: number = 0;

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

  private static setPlaybackState(status: PoemAudioPlaybackStatus, rawPath: string): void {
    PoemAudioPlayer.playbackStatus = status;
    AppStorage.setOrCreate<string>('poemAudioPlaybackStatus', status);
    AppStorage.setOrCreate<string>('poemAudioPlaybackRawPath', rawPath);
    console.info(`[PoemAudioPlayer] playback status=${status} rawPath=${rawPath}`);
  }

  private static isActivePlayer(player: media.AVPlayer, token: number): boolean {
    return PoemAudioPlayer.player === player && PoemAudioPlayer.playerToken === token;
  }

  private static async closeCurrentRawFd(rawContext: common.UIAbilityContext | null, rawPath: string): Promise<void> {
    if (!rawContext || rawPath.length === 0) {
      return;
    }

    try {
      await rawContext.resourceManager.closeRawFd(rawPath);
    } catch (_err) {
    }
  }

  private static closeLocalFile(file: fs.File | null): void {
    if (!file) {
      return;
    }

    try {
      fs.closeSync(file);
    } catch (_err) {
    }
  }

  private static async stopAndReleaseCurrentPlayer(): Promise<void> {
    const player = PoemAudioPlayer.player;
    const rawContext = PoemAudioPlayer.rawContext;
    const rawPath = PoemAudioPlayer.rawPath;
    const localFile = PoemAudioPlayer.localFile;

    PoemAudioPlayer.player = null;
    PoemAudioPlayer.rawContext = null;
    PoemAudioPlayer.rawPath = '';
    PoemAudioPlayer.localFile = null;

    if (player) {
      try {
        await player.release();
      } catch (_err) {
      }
    }

    await PoemAudioPlayer.closeCurrentRawFd(rawContext, rawPath);
    PoemAudioPlayer.closeLocalFile(localFile);
  }

  private static async bindAndStartRawPlayer(
    player: media.AVPlayer,
    token: number,
    rawPath: string
  ): Promise<void> {
    player.on('stateChange', async (state: string) => {
      if (!PoemAudioPlayer.isActivePlayer(player, token)) {
        return;
      }

      try {
        console.info(`[PoemAudioPlayer] raw stateChange=${state} currentTime=${player.currentTime} duration=${player.duration}`);
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
          console.info('[PoemAudioPlayer] raw setVolume(1.0) after prepared');
          await player.play();
          return;
        }

        if (state === 'playing') {
          PoemAudioPlayer.setPlaybackState('playing', rawPath);
          PoemAudioPlayer.logMusicStreamState();
          await PoemAudioPlayer.logActiveRenderers('playing');
          return;
        }

        if (state === 'paused') {
          PoemAudioPlayer.setPlaybackState('paused', rawPath);
          return;
        }

        if (state === 'completed') {
          PoemAudioPlayer.setPlaybackState('idle', '');
          await PoemAudioPlayer.stopAndReleaseCurrentPlayer();
        }
      } catch (err) {
        console.error(`Failed to advance raw AVPlayer state=${state}: ${JSON.stringify(err)}`);
        PoemAudioPlayer.setPlaybackState('idle', '');
        await PoemAudioPlayer.stopAndReleaseCurrentPlayer();
      }
    });

    player.on('error', async (error) => {
      if (!PoemAudioPlayer.isActivePlayer(player, token)) {
        return;
      }

      console.error(`AVPlayer raw error: ${JSON.stringify(error)}`);
      PoemAudioPlayer.setPlaybackState('idle', '');
      await PoemAudioPlayer.stopAndReleaseCurrentPlayer();
    });
  }

  static getPlaybackStatus(): PoemAudioPlaybackStatus {
    return PoemAudioPlayer.playbackStatus;
  }

  static getCurrentRawPath(): string {
    return PoemAudioPlayer.rawPath;
  }

  static async toggleRawFile(context: common.UIAbilityContext, rawPath: string): Promise<void> {
    if (PoemAudioPlayer.rawPath === rawPath) {
      if (PoemAudioPlayer.playbackStatus === 'playing') {
        await PoemAudioPlayer.pause();
        return;
      }

      if (PoemAudioPlayer.playbackStatus === 'paused') {
        await PoemAudioPlayer.resume();
        return;
      }

      if (PoemAudioPlayer.playbackStatus === 'loading') {
        return;
      }
    }

    await PoemAudioPlayer.playRawFile(context, rawPath);
  }

  static async playRawFile(context: common.UIAbilityContext, rawPath: string): Promise<void> {
    if (PoemAudioPlayer.rawPath === rawPath && PoemAudioPlayer.playbackStatus === 'paused') {
      await PoemAudioPlayer.resume();
      return;
    }

    const token = PoemAudioPlayer.playerToken + 1;
    PoemAudioPlayer.playerToken = token;
    await PoemAudioPlayer.stopAndReleaseCurrentPlayer();

    const player = await media.createAVPlayer();
    PoemAudioPlayer.player = player;
    PoemAudioPlayer.rawContext = context;
    PoemAudioPlayer.rawPath = rawPath;
    PoemAudioPlayer.setPlaybackState('loading', rawPath);
    await PoemAudioPlayer.bindAndStartRawPlayer(player, token, rawPath);
    player.fdSrc = await context.resourceManager.getRawFd(rawPath);
  }

  static async pause(): Promise<void> {
    if (!PoemAudioPlayer.player || PoemAudioPlayer.playbackStatus !== 'playing') {
      return;
    }

    await PoemAudioPlayer.player.pause();
  }

  static async resume(): Promise<void> {
    if (!PoemAudioPlayer.player || PoemAudioPlayer.playbackStatus !== 'paused') {
      return;
    }

    PoemAudioPlayer.player.setVolume(1.0);
    await PoemAudioPlayer.player.play();
  }

  static async playUri(uri: string): Promise<void> {
    const token = PoemAudioPlayer.playerToken + 1;
    PoemAudioPlayer.playerToken = token;
    await PoemAudioPlayer.stopAndReleaseCurrentPlayer();

    const player = await media.createAVPlayer();
    PoemAudioPlayer.player = player;
    PoemAudioPlayer.setPlaybackState('loading', '');
    player.on('stateChange', async (state: string) => {
      if (!PoemAudioPlayer.isActivePlayer(player, token)) {
        return;
      }

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
          PoemAudioPlayer.setPlaybackState('playing', '');
          PoemAudioPlayer.logMusicStreamState();
          await PoemAudioPlayer.logActiveRenderers('playing');
          return;
        }

        if (state === 'paused') {
          PoemAudioPlayer.setPlaybackState('paused', '');
          return;
        }

        if (state === 'completed') {
          PoemAudioPlayer.setPlaybackState('idle', '');
          await PoemAudioPlayer.stopAndReleaseCurrentPlayer();
        }
      } catch (err) {
        console.error(`Failed to advance uri AVPlayer state=${state}: ${JSON.stringify(err)}`);
        PoemAudioPlayer.setPlaybackState('idle', '');
        await PoemAudioPlayer.stopAndReleaseCurrentPlayer();
      }
    });
    player.on('error', async (error) => {
      if (!PoemAudioPlayer.isActivePlayer(player, token)) {
        return;
      }

      console.error(`AVPlayer uri error: ${JSON.stringify(error)}`);
      PoemAudioPlayer.setPlaybackState('idle', '');
      await PoemAudioPlayer.stopAndReleaseCurrentPlayer();
    });
    player.url = uri;
  }

  static async playFile(filePath: string, playbackKey: string = filePath): Promise<void> {
    const token = PoemAudioPlayer.playerToken + 1;
    PoemAudioPlayer.playerToken = token;
    await PoemAudioPlayer.stopAndReleaseCurrentPlayer();

    const file = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
    const player = await media.createAVPlayer();
    PoemAudioPlayer.player = player;
    PoemAudioPlayer.localFile = file;
    PoemAudioPlayer.setPlaybackState('loading', playbackKey);
    player.on('stateChange', async (state: string) => {
      if (!PoemAudioPlayer.isActivePlayer(player, token)) {
        return;
      }

      try {
        console.info(`[PoemAudioPlayer] file stateChange=${state} currentTime=${player.currentTime} duration=${player.duration}`);
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
          console.info('[PoemAudioPlayer] file setVolume(1.0) after prepared');
          await player.play();
          return;
        }

        if (state === 'playing') {
          PoemAudioPlayer.setPlaybackState('playing', playbackKey);
          PoemAudioPlayer.logMusicStreamState();
          await PoemAudioPlayer.logActiveRenderers('playing');
          return;
        }

        if (state === 'paused') {
          PoemAudioPlayer.setPlaybackState('paused', playbackKey);
          return;
        }

        if (state === 'completed') {
          PoemAudioPlayer.setPlaybackState('idle', '');
          await PoemAudioPlayer.stopAndReleaseCurrentPlayer();
        }
      } catch (err) {
        console.error(`Failed to advance file AVPlayer state=${state}: ${JSON.stringify(err)}`);
        PoemAudioPlayer.setPlaybackState('idle', '');
        await PoemAudioPlayer.stopAndReleaseCurrentPlayer();
      }
    });
    player.on('error', async (error) => {
      if (!PoemAudioPlayer.isActivePlayer(player, token)) {
        return;
      }

      console.error(`AVPlayer file error: ${JSON.stringify(error)}`);
      PoemAudioPlayer.setPlaybackState('idle', '');
      await PoemAudioPlayer.stopAndReleaseCurrentPlayer();
    });
    player.url = `fd://${file.fd}`;
  }

  static async release(): Promise<void> {
    PoemAudioPlayer.playerToken += 1;
    await PoemAudioPlayer.stopAndReleaseCurrentPlayer();
    PoemAudioPlayer.setPlaybackState('idle', '');
  }
}
