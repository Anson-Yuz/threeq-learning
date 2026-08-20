import router from '@ohos.router';
import { AbilityRadar } from '../components/AbilityRadar';
import { LearningReport, QuizRecord, AbilityScores } from '../models/CourseModel';
import { AiApiService } from '../services/AiApiService';
import { UserProgressStore } from '../stores/UserProgressStore';
import { Logger } from '../utils/Utils';

@Entry
@Component
export struct ReportPage {
  @State courseId: string = '';
  @State report: LearningReport | undefined = undefined;
  @State isLoading: boolean = true;
  @State quizRecords: QuizRecord[] = [];
  private progressStore: UserProgressStore = new UserProgressStore();

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    if (params && params['courseId']) {
      this.courseId = params['courseId'];
      this.quizRecords = this.progressStore.getCourseRecords(this.courseId);
      this.loadReport();
    }
  }

  build() {
    Column() {
      this.TopBar()
      if (this.isLoading) {
        Column() {
          LoadingProgress().width(36).height(36).color('#1A73E8')
          Text('生成学习报告中...').fontSize(14).fontColor('#8E8E93').margin({ top: 10 })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            this.ScoreCard()
            if (this.report) {
              AbilityRadar({ scores: this.report.abilityScores }).margin({ bottom: 12 })
            }
            this.SuggestionCard()
            this.PlanCard()
            this.AnswerRecordsCard()
          }
          .width('100%').padding({ left: 16, right: 16, bottom: 30 })
        }
        .layoutWeight(1).scrollBar(BarState.Off)
      }
    }
    .width('100%').height('100%').backgroundColor('#F2F2F7')
  }

  @Builder TopBar() {
    Row() {
      Text('←').fontSize(24).fontColor('#1A73E8').onClick(() => { router.back() })
      Text('学习报告').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1D1D1F')
        .layoutWeight(1).textAlign(TextAlign.Center)
    }
    .width('100%').padding({ left: 16, right: 16, top: 50, bottom: 10 })
  }

  @Builder ScoreCard() {
    Column() {
      Text('学习综合评价').fontSize(14).fontColor('#8E8E93')
      Text((this.report ? this.report.totalScore.toString() : '0') + ' 分')
        .fontSize(40).fontWeight(FontWeight.Bold).fontColor('#1A73E8')
    }
    .width('100%').padding(20).backgroundColor('#FFFFFF').borderRadius(16)
    .margin({ top: 10, bottom: 12 })
    .shadow({ radius: 6, color: 'rgba(0,0,0,0.04)', offsetX: 0, offsetY: 2 })
  }

  @Builder SuggestionCard() {
    Column() {
      Text('AI 学习建议').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1D1D1F').margin({ bottom: 10 })
      Text(this.report ? this.report.aiSuggestions : '暂无建议').fontSize(14).fontColor('#3C3C43').lineHeight(22)
    }
    .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16).margin({ bottom: 12 })
  }

  @Builder PlanCard() {
    Column() {
      Text('改进计划').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1D1D1F').margin({ bottom: 10 })
      Text(this.report ? this.report.improvementPlan : '暂无计划').fontSize(14).fontColor('#3C3C43').lineHeight(22)
    }
    .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16).margin({ bottom: 12 })
  }

  @Builder AnswerRecordsCard() {
    Column() {
      Row() {
        Text('原始答题记录').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1D1D1F')
        Blank()
        Text(this.quizRecords.length.toString() + '条').fontSize(12).fontColor('#8E8E93')
      }
      .width('100%').margin({ bottom: 10 })
      if (this.quizRecords.length === 0) {
        Text('暂无答题记录').fontSize(13).fontColor('#C7C7CC')
      } else {
        ForEach(this.quizRecords, (record: QuizRecord, idx: number) => {
          Column() {
            Row() {
              Text((idx + 1).toString() + '. ').fontSize(13).fontColor('#8E8E93')
              Text(record.questionText).fontSize(13).fontColor('#1D1D1F').layoutWeight(1).maxLines(2)
            }
            Text('用户答案：').fontSize(11).fontColor('#FF9500').margin({ top: 6 })
            Text(record.userAnswer).fontSize(12).fontColor('#3C3C43').lineHeight(18)
              .padding(8).backgroundColor('#FFF9E6').borderRadius(8).width('100%').margin({ top: 4 })
            Row() {
              Text('得分：').fontSize(11).fontColor('#8E8E93')
              Text(record.score.toString() + '/' + record.maxScore.toString())
                .fontSize(12).fontColor('#1A73E8').fontWeight(FontWeight.Bold)
            }
            .margin({ top: 8 })
          }
          .width('100%').padding(12).backgroundColor('#F8F8FA').borderRadius(10).margin({ bottom: 8 })
        })
      }
    }
    .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16).margin({ bottom: 30 })
  }

  loadReport(): void {
    AiApiService.getReport(this.courseId).then((res) => {
      if (res.code === 200 && res.data) {
        this.report = res.data as LearningReport;
      } else {
        this.report = this.makeReport();
      }
      this.isLoading = false;
    }).catch(() => {
      this.report = this.makeReport();
      this.isLoading = false;
    });
  }

  makeReport(): LearningReport {
    const records = this.quizRecords;
    const totalScore = records.length > 0
      ? Math.round(records.reduce((sum, r) => sum + (r.score / r.maxScore * 100), 0) / records.length)
      : 0;
    return {
      id: 'report_' + this.courseId,
      courseId: this.courseId,
      totalScore: totalScore,
      abilityScores: {
        conceptUnderstanding: 0,
        criticalThinking: 0,
        practicalTransfer: 0,
        expressionLogic: 0
      },
      aiSuggestions: '根据你的答题情况，建议继续深化概念理解，加强实践应用和批判性思维训练。',
      quizRecords: records,
      debateRecords: [],
      rawQuestions: records.map(r => r.questionText),
      improvementPlan: '1. 每周复习核心概念\n2. 完成3个实践项目\n3. 参与社区讨论和争议辩论\n4. 定期自测并记录错题',
      generatedAt: new Date().toISOString()
    };
  }
}
