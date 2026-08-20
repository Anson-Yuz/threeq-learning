import { CourseModel, ThreeQStep } from '../models/CourseModel';

/**
 * 三问步骤进度条组件
 * 显示：[1 心智模型] → [2 争议挖掘] → [3 深度测评] → [📊 报告]
 */
@Component
export struct ThreeQuestionStepper {
  @Prop currentStep: ThreeQStep = ThreeQStep.QUESTION_1_MIND_MODEL;
  @Prop step1Progress: number = 0;
  @Prop step2Progress: number = 0;
  @Prop step3Progress: number = 0;

  build() {
    Row() {
      // 步骤1
      this.StepItem(1, '心智模型', this.currentStep === ThreeQStep.QUESTION_1_MIND_MODEL,
        this.getStepStatus(ThreeQStep.QUESTION_1_MIND_MODEL))

      // 连线
      this.Connector(this.isStepDone(ThreeQStep.QUESTION_1_MIND_MODEL))

      // 步骤2
      this.StepItem(2, '争议挖掘', this.currentStep === ThreeQStep.QUESTION_2_DEBATE,
        this.getStepStatus(ThreeQStep.QUESTION_2_DEBATE))

      // 连线
      this.Connector(this.isStepDone(ThreeQStep.QUESTION_2_DEBATE))

      // 步骤3
      this.StepItem(3, '深度测评', this.currentStep === ThreeQStep.QUESTION_3_QUIZ,
        this.getStepStatus(ThreeQStep.QUESTION_3_QUIZ))

      // 连线
      this.Connector(this.isStepDone(ThreeQStep.QUESTION_3_QUIZ))

      // 报告
      this.StepItem(4, '学习报告', this.currentStep === ThreeQStep.REPORT,
        this.getStepStatus(ThreeQStep.REPORT))
    }
    .width('100%')
    .padding({ top: 12, bottom: 12, left: 8, right: 8 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  @Builder StepItem(num: number, label: string, isActive: boolean, status: string) {
    Column() {
      Text(num.toString())
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(isActive ? '#FFFFFF' : (status === 'done' ? '#FFFFFF' : '#8E8E93'))
        .width(32)
        .height(32)
        .borderRadius(16)
        .backgroundColor(isActive ? '#1A73E8' : (status === 'done' ? '#34C759' : '#E5E5EA'))
        .textAlign(TextAlign.Center)
      Text(label)
        .fontSize(10)
        .fontColor(isActive ? '#1A73E8' : '#8E8E93')
        .margin({ top: 4 })
        .maxLines(1)
      if (isActive) {
        Text(`${this.getStepProgress(num)}%`)
          .fontSize(9)
          .fontColor('#1A73E8')
          .margin({ top: 2 })
      }
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder Connector(isDone: boolean) {
    Divider()
      .width(16)
      .height(2)
      .color(isDone ? '#34C759' : '#E5E5EA')
      .margin({ bottom: 20 })
  }

  private getStepStatus(step: ThreeQStep): string {
    if (this.currentStep > step) return 'done';
    if (this.currentStep === step) return 'active';
    return 'waiting';
  }

  private isStepDone(step: ThreeQStep): boolean {
    return this.currentStep > step;
  }

  private getStepProgress(num: number): number {
    if (num === 1) return this.step1Progress;
    if (num === 2) return this.step2Progress;
    if (num === 3) return this.step3Progress;
    return 0;
  }
}
