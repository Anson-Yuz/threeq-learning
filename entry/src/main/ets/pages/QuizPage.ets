import router from '@ohos.router';
import { BloomQuizCard } from '../components/BloomQuizCard';
import { QuizQuestion, QuizRecord, BloomLevel } from '../models/CourseModel';
import { AiApiService } from '../services/AiApiService';
import { UserProgressStore } from '../stores/UserProgressStore';
import { Logger } from '../utils/Utils';

@Entry
@Component
export struct QuizPage {
  @State courseId: string = '';
  @State questions: QuizQuestion[] = [];
  @State isLoading: boolean = true;
  @State currentQuestionIndex: number = 0;
  @State completedCount: number = 0;
  @State showResults: boolean = false;
  @State resultsFeedback: string = '';
  private progressStore: UserProgressStore = new UserProgressStore();
  private submittedAnswers: Map<string, string> = new Map();

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    if (params && params['courseId']) {
      this.courseId = params['courseId'];
      this.loadAllQuestions();
    }
  }

  build() {
    Column() {
      this.TopBar()
      if (this.questions.length > 0) {
        Progress({ value: this.completedCount, total: this.questions.length, type: ProgressType.Linear })
          .width('100%').color('#5856D6').style({ strokeWidth: 4 })
      }
      Scroll() {
        Column() {
          if (this.isLoading) {
            this.LoadingView()
          } else if (this.showResults) {
            this.ResultView()
          } else if (this.questions.length > 0) {
            BloomQuizCard({
              question: this.questions[this.currentQuestionIndex],
              index: this.currentQuestionIndex,
              total: this.questions.length,
              onAnswerSubmit: (qid: string, ans: string) => {
                this.handleSubmit(qid, ans);
              }
            })
            this.NavButton()
          }
        }
        .width('100%').padding({ left: 16, right: 16, bottom: 40 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%').backgroundColor('#F2F2F7')
  }

  @Builder TopBar() {
    Row() {
      Text('<-').fontSize(24).fontColor('#1A73E8').onClick(() => { router.back() })
      Text('Third Question: Quiz').fontSize(17).fontWeight(FontWeight.Bold).fontColor('#1D1D1F')
        .layoutWeight(1).textAlign(TextAlign.Center)
      Text(this.completedCount.toString() + '/' + this.questions.length.toString())
        .fontSize(14).fontColor('#8E8E93')
    }
    .width('100%').padding({ left: 16, right: 16, top: 50, bottom: 10 })
  }

  @Builder LoadingView() {
    Column() {
      LoadingProgress().width(36).height(36).color('#5856D6')
      Text('Generating quiz...').fontSize(14).fontColor('#8E8E93').margin({ top: 10 })
    }
    .width('100%').padding(40).backgroundColor('#FFFFFF').borderRadius(12).margin({ top: 10 })
  }

  @Builder NavButton() {
    if (this.currentQuestionIndex < this.questions.length - 1) {
      Button('Next')
        .width('100%').height(44).fontSize(15).fontColor('#FFFFFF')
        .backgroundColor('#5856D6').borderRadius(10).margin({ top: 16 })
        .onClick(() => { this.currentQuestionIndex++ })
    } else if (this.completedCount === this.questions.length) {
      Button('View Results')
        .width('100%').height(48).fontSize(16).fontColor('#FFFFFF')
        .backgroundColor('#34C759').borderRadius(12).margin({ top: 16 })
        .onClick(() => { this.finishQuiz() })
    } else {
      Button('Done: ' + this.completedCount.toString() + '/' + this.questions.length.toString())
        .width('100%').height(44).fontSize(15).fontColor('#8E8E93')
        .backgroundColor('#E5E5EA').borderRadius(10).margin({ top: 16 })
        .enabled(false)
    }
  }

  @Builder ResultView() {
    Column() {
      Text('Quiz Complete!').fontSize(22).fontWeight(FontWeight.Bold).fontColor('#1D1D1F')
        .margin({ top: 30, bottom: 16 })
      Text(this.resultsFeedback).fontSize(14).fontColor('#3C3C43').lineHeight(22)
        .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(12).margin({ bottom: 20 })
      Button('View Report')
        .width('100%').height(48).fontSize(16).fontColor('#FFFFFF').backgroundColor('#34C759').borderRadius(12)
        .onClick(() => { router.pushUrl({ url: 'pages/ReportPage', params: { courseId: this.courseId } }) })
      Button('Back to Course')
        .width('100%').height(48).fontSize(16).fontColor('#1A73E8').backgroundColor('#E3F2FD').borderRadius(12)
        .margin({ top: 12 })
        .onClick(() => { router.back() })
    }
    .width('100%').padding({ left: 16, right: 16 })
  }

  loadAllQuestions(): void {
    AiApiService.generateQuiz(this.courseId).then((res) => {
      if (res.code === 200 && res.data) {
        const data = res.data as Record<string, Object>;
        this.questions = (data['questions'] as QuizQuestion[]) || [];
      } else {
        this.questions = this.makeMockQuestions();
      }
      this.isLoading = false;
    }).catch(() => {
      this.questions = this.makeMockQuestions();
      this.isLoading = false;
    });
  }

  handleSubmit(qid: string, ans: string): void {
    this.submittedAnswers.set(qid, ans);
    this.completedCount = this.submittedAnswers.size;
    const q = this.questions.find((item: QuizQuestion) => item.id === qid);
    if (q) {
      const record: QuizRecord = {
        id: 'qr_' + Date.now().toString(),
        courseId: this.courseId,
        questionText: q.questionText,
        bloomLevel: q.bloomLevel,
        userAnswer: ans,
        answerSource: 'user_input',
        aiReferenceUsed: false,
        score: 0,
        maxScore: q.points,
        dimensions: { conceptAccuracy: 0, logic: 0, application: 0, reflection: 0, expression: 0 },
        feedback: '',
        improvementTips: '',
        createdAt: new Date().toISOString()
      };
      this.progressStore.addQuizRecord(record);
    }
  }

  finishQuiz(): void {
    this.resultsFeedback = 'You answered ' + this.completedCount.toString() + ' questions. Check the report page for full evaluation.';
    this.showResults = true;
  }

  makeMockQuestions(): QuizQuestion[] {
    const cid = this.courseId;
    return [
      { id: 'q1', courseId: cid, bloomLevel: BloomLevel.REMEMBER,
        questionText: 'List the 3 most important concepts in this field.',
        questionType: 'short_answer', gradingRubric: 'Accuracy', points: 10 },
      { id: 'q2', courseId: cid, bloomLevel: BloomLevel.UNDERSTAND,
        questionText: 'Explain the core principles in your own words with an example.',
        questionType: 'essay', gradingRubric: 'Depth', points: 20 },
      { id: 'q3', courseId: cid, bloomLevel: BloomLevel.APPLY,
        questionText: 'Describe how you would apply this knowledge to a real project.',
        questionType: 'essay', gradingRubric: 'Feasibility', points: 20 },
      { id: 'q4', courseId: cid, bloomLevel: BloomLevel.ANALYZE,
        questionText: 'Compare two different approaches and analyze pros and cons.',
        questionType: 'essay', gradingRubric: 'Analysis depth', points: 20 },
      { id: 'q5', courseId: cid, bloomLevel: BloomLevel.EVALUATE,
        questionText: 'Evaluate whether ThreeQ Learning Machine meets high-efficiency learning standards.',
        questionType: 'essay', gradingRubric: 'Critical thinking', points: 15 },
      { id: 'q6', courseId: cid, bloomLevel: BloomLevel.CREATE,
        questionText: 'Design a new project or tool that extends this field based on your learning.',
        questionType: 'project', gradingRubric: 'Innovation', points: 15 }
    ];
  }
}
