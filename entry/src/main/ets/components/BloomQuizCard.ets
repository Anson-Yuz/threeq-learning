import { QuizQuestion, BloomLevel } from '../models/CourseModel';

@Component
export struct BloomQuizCard {
  @Prop question: QuizQuestion;
  @Prop index: number = 0;
  @Prop total: number = 0;
  @State userAnswer: string = '';
  @State submitted: boolean = false;
  onAnswerSubmit?: (questionId: string, answer: string) => void;

  build() {
    Column() {
      Row() {
        Text(`第 ${this.index + 1}/${this.total} 题`).fontSize(13).fontColor('#8E8E93')
        Blank()
        Text(this.levelLabel(this.question.bloomLevel)).fontSize(12).fontColor('#FFFFFF')
          .padding({ left: 10, right: 10, top: 3, bottom: 3 })
          .backgroundColor(this.levelColor(this.question.bloomLevel))
          .borderRadius(10)
      }
      .width('100%').margin({ bottom: 10 })

      Text(this.question.questionText)
        .fontSize(15).fontColor('#1D1D1F').lineHeight(24).margin({ bottom: 12 }).width('100%')

      Text('📝 请独立回答，不要复制AI答案。我们会记录你的原始输入。')
        .fontSize(11).fontColor('#FF9500').margin({ bottom: 10 }).width('100%')

      if (!this.submitted) {
        TextArea({
          placeholder: this.answerPlaceholder(this.question.questionType),
          text: this.userAnswer
        })
          .width('100%')
          .height(this.question.questionType === 'essay' ? 160 : 100)
          .fontSize(14)
          .backgroundColor('#F5F5F7')
          .borderRadius(10)
          .padding(12)
          .onChange((value: string) => { this.userAnswer = value })

        if (this.question.choices && this.question.choices.length > 0) {
          Column() {
            ForEach(this.question.choices, (choice: string, ci: number) => {
              Row() {
                Text(`${String.fromCharCode(65 + ci)}. ${choice}`).fontSize(14).fontColor('#3C3C43')
                  .width('100%').padding({ top: 8, bottom: 8, left: 12, right: 12 })
                  .backgroundColor('#F5F5F7').borderRadius(8).margin({ top: 4 })
              }
              .width('100%')
              .onClick(() => { this.userAnswer = `${String.fromCharCode(65 + ci)}. ${choice}` })
            })
          }
          .width('100%').margin({ top: 8 })
        }

        Button('提交答案')
          .width('100%').height(42).fontSize(15).fontColor('#FFFFFF')
          .backgroundColor(this.userAnswer.trim().length > 0 ? '#1A73E8' : '#C7C7CC')
          .borderRadius(10).margin({ top: 14 })
          .enabled(this.userAnswer.trim().length > 0)
          .onClick(() => {
            if (this.userAnswer.trim().length > 0) {
              this.submitted = true
              if (this.onAnswerSubmit) this.onAnswerSubmit(this.question.id, this.userAnswer)
            }
          })
      } else {
        Row() {
          Text('✅ 答案已提交').fontSize(14).fontColor('#34C759').fontWeight(FontWeight.Bold)
          Text('（提交后可查看AI评价）').fontSize(12).fontColor('#8E8E93').margin({ left: 8 })
        }
      }
    }
    .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16)
    .shadow({ radius: 6, color: 'rgba(0,0,0,0.04)', offsetX: 0, offsetY: 2 }).margin({ bottom: 16 })
  }

  levelLabel(level: BloomLevel): string {
    if (level === 'remember') return '🧠 记忆'
    if (level === 'understand') return '💡 理解'
    if (level === 'apply') return '🔧 应用'
    if (level === 'analyze') return '🔍 分析'
    if (level === 'evaluate') return '⚖️ 评价'
    if (level === 'create') return '🚀 创造'
    return String(level)
  }

  levelColor(level: BloomLevel): string {
    if (level === 'remember') return '#007AFF'
    if (level === 'understand') return '#34C759'
    if (level === 'apply') return '#FF9500'
    if (level === 'analyze') return '#5856D6'
    if (level === 'evaluate') return '#FF2D55'
    if (level === 'create') return '#AF52DE'
    return '#1A73E8'
  }

  answerPlaceholder(type: string): string {
    if (type === 'code') return '请在此输入你的代码...'
    if (type === 'short_answer') return '请简要回答你的理解...'
    if (type === 'essay') return '请详细阐述你的观点和分析...'
    return '请输入你的答案...'
  }
}
