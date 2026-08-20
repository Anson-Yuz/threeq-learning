import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import { Logger } from '../utils/Utils';
import hilog from '@ohos.hilog';

export default class EntryAbility extends UIAbility {
  onCreate(): void {
    hilog.info(0x0000, 'ThreeQ', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'ThreeQ', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'ThreeQ', 'Ability onWindowStageCreate');
    Logger.info('EntryAbility', 'Application started');

    windowStage.loadContent('pages/HomePage', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'ThreeQ', 'Failed to load content');
        return;
      }
      hilog.info(0x0000, 'ThreeQ', 'Content loaded successfully');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(0x0000, 'ThreeQ', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(0x0000, 'ThreeQ', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(0x0000, 'ThreeQ', 'Ability onBackground');
  }
}
