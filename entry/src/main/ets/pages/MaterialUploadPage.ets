import router from '@ohos.router';
import { Logger } from '../utils/Utils';

@Entry
@Component
export struct MaterialUploadPage {
  @State courseId: string = '';
  @State selectedFiles: string[] = [];
  @State isUploading: boolean = false;
  @State uploadProgress: number = 0;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    if (params && params['courseId']) {
      this.courseId = params['courseId'];
    }
  }

  build() {
    Column() {
      Row() {
        Text('←').fontSize(24).fontColor('#1A73E8').onClick(() => { router.back() })
        Text('上传学习资料').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1D1D1F')
          .layoutWeight(1).textAlign(TextAlign.Center)
      }
      .width('100%').padding({ left: 16, right: 16, top: 50, bottom: 10 })

      Column() {
        this.UploadZone()
        if (this.selectedFiles.length > 0) {
          this.FileList()
        }
        if (this.isUploading) {
          this.UploadProgress()
        }
      }
      .padding({ left: 16, right: 16 })
      .layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor('#F2F2F7')
  }

  @Builder UploadZone() {
    Column() {
      Text('📁').fontSize(48).margin({ bottom: 12 })
      Text('点击上传资料').fontSize(16).fontColor('#1D1D1F').margin({ bottom: 6 })
      Text('支持 PDF、Word、Markdown、TXT 格式').fontSize(13).fontColor('#C7C7CC').margin({ bottom: 20 })
      Button('选择文件')
        .fontSize(15).fontColor('#FFFFFF').backgroundColor('#1A73E8').borderRadius(10).height(44)
        .onClick(() => { Logger.info('MaterialUpload', 'Open file picker'); })
    }
    .width('100%').padding(40).backgroundColor('#FFFFFF').borderRadius(16).margin({ top: 20 })
  }

  @Builder FileList() {
    Column() {
      Text('已选择文件').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#1D1D1F').margin({ bottom: 8 })
      ForEach(this.selectedFiles, (file: string) => {
        Text(file).fontSize(13).fontColor('#3C3C43').padding(10)
          .backgroundColor('#F5F5F7').borderRadius(8).width('100%').margin({ bottom: 6 })
      })
    }
    .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16).margin({ top: 12 })
  }

  @Builder UploadProgress() {
    Column() {
      Progress({ value: this.uploadProgress, total: 100, type: ProgressType.Linear })
        .width('100%').color('#1A73E8')
      Text('上传中 ' + this.uploadProgress.toString() + '%')
        .fontSize(12).fontColor('#8E8E93').margin({ top: 6 })
    }
    .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16).margin({ top: 12 })
  }
}
