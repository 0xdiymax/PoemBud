import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

export class PreferencesManager {
  private static context: common.UIAbilityContext | null = null;
  private static prefsMap: Map<string, preferences.Preferences> = new Map();

  static init(context: common.UIAbilityContext): void {
    PreferencesManager.context = context;
  }

  static async getPreferences(name: string): Promise<preferences.Preferences> {
    if (!PreferencesManager.context) {
      throw new Error('PreferencesManager has not been initialized.');
    }

    const cached = PreferencesManager.prefsMap.get(name);
    if (cached) {
      return cached;
    }

    const prefs = await preferences.getPreferences(PreferencesManager.context, name);
    PreferencesManager.prefsMap.set(name, prefs);
    return prefs;
  }

  static clearCache(): void {
    PreferencesManager.prefsMap.clear();
  }
}
