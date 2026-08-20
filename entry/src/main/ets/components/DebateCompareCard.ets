import { DebateTopic } from '../models/CourseModel';

@Component
export struct DebateCompareCard {
  @Prop topic: DebateTopic;
  @State userOpinion: string = '';
  @State userVerdict: string = '';
  onOpinionSubmit?: (topicId: string, opinion: string, verdict: string) => void;

  build() {
    Column() {
      Text(this.topic.topic)
        .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1D1D1F').margin({ bottom: 12 }).width('100%')

      Row() {
        Column() {
          Text('观点 A').fontSize(12).fontColor('#1A73E8').fontWeight(FontWeight.Bold).margin({ bottom: 8 })
          Text(this.topic.sideA).fontSize(13).fontColor('#3C3C43').lineHeight(20).margin({ bottom: 8 })
          if (this.topic.evidenceA && this.topic.evidenceA.length > 0) {
            Text(`📄 ${this.topic.evidenceA.length}条依据`).fontSize(11).fontColor('#8E8E93')
          }
        }
        .width('46%').padding(12).backgroundColor('#E3F2FD').borderRadius(12)

        Text('VS').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#E0E0E0').margin({ left: 4, right: 4 })

        Column() {
          Text('观点 B').fontSize(12).fontColor('#FF6D00').fontWeight(FontWeight.Bold).margin({ bottom: 8 })
          Text(this.topic.sideB).fontSize(13).fontColor('#3C3C43').lineHeight(20).margin({ bottom: 8 })
          if (this.topic.evidenceB && this.topic.evidenceB.length > 0) {
            Text(`📄 ${this.topic.evidenceB.length}条依据`).fontSize(11).fontColor('#8E8E93')
          }
        }
        .width('46%').padding(12).backgroundColor('#FFF3E0').borderRadius(12)
      }
      .width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 16 })

      if (!this.topic.userOpinion || this.topic.userOpinion.length === 0) {
        Column() {
          Text('你的观点是什么？请引用资料依据').fontSize(13).fontColor('#8E8E93').margin({ bottom: 8 }).width('100%')
          TextArea({ placeholder: '我认为...（请结合资料说明理由）', text: this.userOpinion })
            .width('100%').height(80).fontSize(14).backgroundColor('#F5F5F7').borderRadius(10).padding(10)
            .onChange((value: string) => { this.userOpinion = value })

          Row() {
            Button('支持观点A').fontSize(13).fontColor('#1A73E8').backgroundColor('#E3F2FD').borderRadius(8)
              .onClick(() => { this.userVerdict = 'a' })
            Button('支持观点B').fontSize(13).fontColor('#FF6D00').backgroundColor('#FFF3E0').borderRadius(8).margin({ left: 12 })
              .onClick(() => { this.userVerdict = 'b' })
            Button('综合观点').fontSize(13).fontColor('#34C759').backgroundColor('#E8F5E9').borderRadius(8).margin({ left: 12 })
              .onClick(() => { this.userVerdict = 'synthesis' })
          }
          .width('100%').margin({ top: 8 })

          Button('提交我的观点').width('100%').height(40).fontSize(15).fontColor('#FFFFFF')
            .backgroundColor('#1A73E8').borderRadius(10).margin({ top: 12 })
            .onClick(() => {
              if (this.userOpinion.trim().length > 0 && this.userVerdict.length > 0) {
                if (this.onOpinionSubmit) this.onOpinionSubmit(this.topic.id, this.userOpinion, this.userVerdict)
              }
            })
        }
        .width('100%')
      } else {
        Column() {
          Text('✅ 你已提交观点').fontSize(14).fontColor('#34C759').fontWeight(FontWeight.Bold).margin({ bottom: 8 })
          Text(this.topic.userOpinion).fontSize(13).fontColor('#3C3C43').width('100%')
            .padding(12).backgroundColor('#F5F5F7').borderRadius(10)
        }
        .width('100%')
      }
    }
    .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16)
    .shadow({ radius: 6, color: 'rgba(0,0,0,0.04)', offsetX: 0, offsetY: 2 }).margin({ bottom: 12 })
  }
}
