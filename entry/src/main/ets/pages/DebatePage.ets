import router from '@ohos.router';

/**
 * 争议挖掘页面 �?第二问的独立页面入口
 * 实际争议展示已集成在 CourseSpacePage �? */
@Entry
@Component
export struct DebatePage {
  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    router.replaceUrl({
      url: 'pages/CourseSpacePage',
      params: params
    });
  }

  build() {
    Column() {
      Text('加载�?..').fontSize(14).fontColor('#8E8E93')
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center).backgroundColor('#F2F2F7')
  }
}
