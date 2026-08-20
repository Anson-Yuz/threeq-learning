import { Material } from '../models/CourseModel';

/**
 * 资料来源标签组件
 * 区分 AI 补充资料和用户上传资料
 */
@Component
export struct SourceTag {
  @Prop sourceType: 'ai_crawled' | 'user_uploaded';
  @Prop url?: string;
  @Prop label?: string;

  build() {
    Row() {
      if (this.sourceType === 'ai_crawled') {
        Text('🤖')
          .fontSize(12)
        Text(this.label || 'AI补充')
          .fontSize(10)
          .fontColor('#1A73E8')
          .margin({ left: 4 })
      } else {
        Text('📎')
          .fontSize(12)
        Text(this.label || '用户上传')
          .fontSize(10)
          .fontColor('#34C759')
          .margin({ left: 4 })
      }

      if (this.url) {
        Text('来源')
          .fontSize(9)
          .fontColor('#8E8E93')
          .margin({ left: 6 })
      }
    }
    .padding({ left: 8, right: 8, top: 3, bottom: 3 })
    .backgroundColor(this.sourceType === 'ai_crawled' ? '#E3F2FD' : '#E8F5E9')
    .borderRadius(6)
  }
}
