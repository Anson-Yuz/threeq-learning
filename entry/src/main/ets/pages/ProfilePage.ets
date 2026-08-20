import router from '@ohos.router';

@Entry
@Component
export struct ProfilePage {
  @State totalCourses: number = 0;
  @State completedCourses: number = 0;
  @State totalQuizzes: number = 0;

  build() {
    Column() {
      Row() {
        Text('<-').fontSize(24).fontColor('#1A73E8').onClick(() => { router.back() })
        Text('Profile').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1D1D1F')
          .layoutWeight(1).textAlign(TextAlign.Center)
      }
      .width('100%').padding({ left: 16, right: 16, top: 50, bottom: 10 })

      Scroll() {
        Column() {
          this.HeaderCard()
          this.StatsCard()
          this.MenuCard()
        }
        .width('100%').padding({ left: 16, right: 16, bottom: 30 })
      }
      .layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor('#F2F2F7')
  }

  @Builder HeaderCard() {
    Column() {
      Text('Student').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1D1D1F').margin({ top: 8 })
      Text('ThreeQ Learning Machine User').fontSize(13).fontColor('#8E8E93')
    }
    .width('100%').padding(30).backgroundColor('#FFFFFF').borderRadius(16)
    .margin({ top: 10, bottom: 12 })
  }

  @Builder StatsCard() {
    Column() {
      Text('Learning Stats').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1D1D1F').margin({ bottom: 12 })
      Row() {
        this.StatColumn('Courses', '0')
        this.StatColumn('Completed', '0')
        this.StatColumn('Quizzes', '0')
      }
      .width('100%').justifyContent(FlexAlign.SpaceEvenly)
    }
    .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16).margin({ bottom: 12 })
  }

  @Builder StatColumn(lbl: string, val: string) {
    Column() {
      Text(val).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#1A73E8')
      Text(lbl).fontSize(12).fontColor('#8E8E93').margin({ top: 4 })
    }
  }

  @Builder MenuCard() {
    Column() {
      this.MenuRow('Archived Courses')
      this.MenuRow('Export Data')
      this.MenuRow('Settings')
      this.MenuRow('AI Service Status')
      this.MenuRow('About ThreeQ')
    }
    .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16)
  }

  @Builder MenuRow(title: string) {
    Row() {
      Text(title).fontSize(15).fontColor('#1D1D1F').layoutWeight(1)
      Text('>').fontSize(18).fontColor('#C7C7CC')
    }
    .width('100%').height(48).borderWidth({ bottom: 0.5 }).borderColor('#F2F2F7')
  }
}
