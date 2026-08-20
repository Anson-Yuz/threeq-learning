import { AbilityScores } from '../models/CourseModel';

@Component
export struct AbilityRadar {
  @Prop scores: AbilityScores = {
    conceptUnderstanding: 0,
    criticalThinking: 0,
    practicalTransfer: 0,
    expressionLogic: 0
  };
  @Prop chartSize: number = 200;

  build() {
    Column() {
      Text('能力维度')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1D1D1F')
        .margin({ bottom: 16 })

      Column() {
        this.DimensionBar('概念理解', '🧠', this.scores.conceptUnderstanding, '#1A73E8')
        this.DimensionBar('批判思维', '⚡', this.scores.criticalThinking, '#FF6D00')
        this.DimensionBar('实践迁移', '🎯', this.scores.practicalTransfer, '#34C759')
        this.DimensionBar('表达逻辑', '📝', this.scores.expressionLogic, '#5856D6')
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 6, color: 'rgba(0,0,0,0.04)', offsetX: 0, offsetY: 2 })
  }

  @Builder DimensionBar(label: string, icon: string, value: number, color: string) {
    Row() {
      Text(icon).fontSize(18).width(32)
      Text(label).fontSize(13).fontColor('#3C3C43').width(72)
      Progress({ value: value, total: 100, type: ProgressType.Linear })
        .layoutWeight(1).color(color).style({ strokeWidth: 8 })
      Text(value.toString()).fontSize(12).fontColor(color).fontWeight(FontWeight.Bold).width(32).textAlign(TextAlign.End)
    }
    .width('100%').height(34).margin({ top: 6, bottom: 6 })
  }
}
