import { abilityAccessCtrl, common, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { media } from '@kit.MediaKit';

export class PoemRecorder {
  private recorder: media.AVRecorder | null = null;
  private recordFile: fs.File | null = null;
  private recordPath: string = '';

  async start(context: common.UIAbilityContext): Promise<string> {
    const hasPermission = await this.requestMicrophonePermission(context);
    if (!hasPermission) {
      throw new Error('Microphone permission denied.');
    }

    await this.release();

    const fileName = `poem_reading_${new Date().getTime()}.m4a`;
    this.recordPath = `${context.filesDir}/${fileName}`;
    this.recordFile = fs.openSync(this.recordPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
    this.recorder = await media.createAVRecorder();

    const profile: media.AVRecorderProfile = {
      audioBitrate: 64000,
      audioChannels: 1,
      audioCodec: media.CodecMimeType.AUDIO_AAC,
      audioSampleRate: 44100,
      fileFormat: media.ContainerFormatType.CFT_MPEG_4A
    };
    const config: media.AVRecorderConfig = {
      audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
      profile: profile,
      url: `fd://${this.recordFile.fd}`
    };

    await this.recorder.prepare(config);
    await this.recorder.start();
    return this.recordPath;
  }

  async stop(): Promise<string> {
    const savedPath = this.recordPath;
    if (this.recorder) {
      try {
        await this.recorder.stop();
      } catch (_err) {
      }
    }
    await this.release();
    return savedPath;
  }

  async release(): Promise<void> {
    if (this.recorder) {
      try {
        await this.recorder.release();
      } catch (_err) {
      }
      this.recorder = null;
    }

    if (this.recordFile) {
      try {
        fs.closeSync(this.recordFile);
      } catch (_err) {
      }
      this.recordFile = null;
    }
  }

  private async requestMicrophonePermission(context: common.UIAbilityContext): Promise<boolean> {
    const atManager = abilityAccessCtrl.createAtManager();
    const permission: Permissions = 'ohos.permission.MICROPHONE';
    const result: PermissionRequestResult = await atManager.requestPermissionsFromUser(context, [permission]);
    return result.authResults.length > 0 && result.authResults[0] === 0;
  }
}
