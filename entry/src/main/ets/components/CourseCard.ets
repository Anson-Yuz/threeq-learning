import { CourseModel, CourseStage, ThreeQStep } from '../models/CourseModel';
import { DateUtil } from '../utils/Utils';

@Component
export struct CourseCard {
  @Prop course: CourseModel;
  onCardClick?: (courseId: string) => void;

  build() {
    Column() {
      Row() {
        Text(this.course.title).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1D1D1F')
          .layoutWeight(1).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
        if (this.course.stage === CourseStage.COMPLETED) {
          Text('已完成').fontSize(11).fontColor('#34C759').padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor('#E8F5E9').borderRadius(10)
        }
      }
      .width('100%').margin({ bottom: 10 })

      Text(this.course.question).fontSize(12).fontColor('#8E8E93').maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ bottom: 12 })

      Row() {
        Progress({ value: this.course.totalProgress, total: 100, type: ProgressType.Linear })
          .width('60%').color('#1A73E8').style({ strokeWidth: 6 })
        Text(`${this.course.totalProgress}%`).fontSize(12).fontColor('#1A73E8').margin({ left: 8 })
      }
      .width('100%').margin({ bottom: 10 })

      Row() {
        Row() {
          Image($r('app.media.app_icon')).width(14).height(14)
          Text(`${this.course.materialCount.ai + this.course.materialCount.user}份资料`).fontSize(10).fontColor('#8E8E93').margin({ left: 4 })
        }
        Blank()
        Text(DateUtil.relative(this.course.lastStudyTime || this.course.updatedAt)).fontSize(10).fontColor('#C7C7CC')
      }
      .width('100%')
    }
    .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.06)', offsetX: 0, offsetY: 2 }).margin({ bottom: 12 })
    .onClick(() => { if (this.onCardClick) this.onCardClick(this.course.id) })
  }
}
