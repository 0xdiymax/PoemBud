import { common } from '@kit.AbilityKit';
import { media } from '@kit.MediaKit';

export class PoemAudioPlayer {
  private static player: media.AVPlayer | null = null;
  private static rawContext: common.UIAbilityContext | null = null;
  private static rawPath: string = '';

  static async playRawFile(context: common.UIAbilityContext, rawPath: string): Promise<void> {
    await PoemAudioPlayer.release();

    const player = await media.createAVPlayer();
    const descriptor = await context.resourceManager.getRawFd(rawPath);
    player.fdSrc = descriptor;
    player.on('stateChange', (state: string) => {
      if (state === 'completed' || state === 'released') {
        PoemAudioPlayer.release();
      }
    });
    player.on('error', () => {
      PoemAudioPlayer.release();
    });

    PoemAudioPlayer.player = player;
    PoemAudioPlayer.rawContext = context;
    PoemAudioPlayer.rawPath = rawPath;
    await player.prepare();
    await player.play();
  }

  static async playUri(uri: string): Promise<void> {
    await PoemAudioPlayer.release();

    const player = await media.createAVPlayer();
    player.url = uri;
    player.on('stateChange', (state: string) => {
      if (state === 'completed' || state === 'released') {
        PoemAudioPlayer.release();
      }
    });
    player.on('error', () => {
      PoemAudioPlayer.release();
    });

    PoemAudioPlayer.player = player;
    await player.prepare();
    await player.play();
  }

  static async release(): Promise<void> {
    const player = PoemAudioPlayer.player;
    PoemAudioPlayer.player = null;
    if (player) {
      try {
        await player.release();
      } catch (_err) {
      }
    }

    if (PoemAudioPlayer.rawContext && PoemAudioPlayer.rawPath.length > 0) {
      try {
        await PoemAudioPlayer.rawContext.resourceManager.closeRawFd(PoemAudioPlayer.rawPath);
      } catch (_err) {
      }
      PoemAudioPlayer.rawContext = null;
      PoemAudioPlayer.rawPath = '';
    }
  }
}
