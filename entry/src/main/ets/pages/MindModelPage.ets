import router from '@ohos.router';

/**
 * 心智模型页面 �?第一问的独立页面入口
 * 实际心智模型展示已集成在 CourseSpacePage �? * 此页面作为路由占位，重定向到课程空间
 */
@Entry
@Component
export struct MindModelPage {
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
