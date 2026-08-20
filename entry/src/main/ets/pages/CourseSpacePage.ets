import router from '@ohos.router';
import { CourseStore } from '../stores/CourseStore';
import { ThreeQuestionStepper } from '../components/ThreeQuestionStepper';
import { KnowledgeGraphView } from '../components/KnowledgeGraphView';
import { DebateCompareCard } from '../components/DebateCompareCard';
import { AbilityRadar } from '../components/AbilityRadar';
import { SourceTag } from '../components/SourceTag';
import { CourseModel, ThreeQStep, MindModel, DebateTopic, Material, CourseStage } from '../models/CourseModel';
import { AiApiService } from '../services/AiApiService';
import { Logger } from '../utils/Utils';

@Entry
@Component
export struct CourseSpacePage {
  @State courseId: string = '';
  @State course: CourseModel | undefined = undefined;
  @State currentStep: ThreeQStep = ThreeQStep.QUESTION_1_MIND_MODEL;
  @State step1Progress: number = 0;
  @State step2Progress: number = 0;
  @State step3Progress: number = 0;
  @State mindModel: MindModel | undefined = undefined;
  @State mindModelLoading: boolean = false;
  @State debateTopics: DebateTopic[] = [];
  @State debateLoading: boolean = false;
  private courseStore: CourseStore = new CourseStore('user_default');

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    if (params && params['courseId']) {
      this.courseId = params['courseId'];
      this.course = this.courseStore.courses.find(c => c.id === this.courseId);
      if (this.course) {
        this.currentStep = this.course.step;
        this.step1Progress = this.currentStep > ThreeQStep.QUESTION_1_MIND_MODEL ? 100 : 0;
        this.step2Progress = this.currentStep > ThreeQStep.QUESTION_2_DEBATE ? 100 : 0;
        this.step3Progress = this.currentStep > ThreeQStep.QUESTION_3_QUIZ ? 100 : 0;
      }
    }
    if (this.currentStep === ThreeQStep.QUESTION_1_MIND_MODEL) {
      this.loadMindModel();
    }
  }

  build() {
    Column() {
      this.TopBar()
      ThreeQuestionStepper({
        currentStep: this.currentStep,
        step1Progress: this.step1Progress,
        step2Progress: this.step2Progress,
        step3Progress: this.step3Progress
      })
      Scroll() {
        Column() {
          if (this.currentStep === ThreeQStep.QUESTION_1_MIND_MODEL) {
            this.QuestionOneContent()
          }
          if (this.currentStep === ThreeQStep.QUESTION_2_DEBATE) {
            this.QuestionTwoContent()
          }
          if (this.currentStep === ThreeQStep.QUESTION_3_QUIZ) {
            this.QuestionThreeContent()
          }
          if (this.currentStep === ThreeQStep.REPORT) {
            this.ReportContent()
          }
          this.BottomButtons()
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 30 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F2F7')
  }

  @Builder TopBar() {
    Row() {
      Text('←')
        .fontSize(24)
        .fontColor('#1A73E8')
        .onClick(() => { router.back() })
      Text(this.course ? this.course.title : '课程空间')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1D1D1F')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      Text('📤')
        .fontSize(20)
        .onClick(() => { router.pushUrl({ url: 'pages/MaterialUploadPage', params: { courseId: this.courseId } }) })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 50, bottom: 10 })
  }

  @Builder QuestionOneContent() {
    Column() {
      Text('第一问：这个领域的核心心智模型是什么？')
        .fontSize(14)
        .fontColor('#1A73E8')
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10, bottom: 10 })
      if (this.mindModelLoading) {
        this.LoadingView('正在分析资料，提取心智模型...')
      } else if (this.mindModel) {
        KnowledgeGraphView({ nodes: this.mindModel.nodes, edges: this.mindModel.edges })
          .margin({ bottom: 12 })
        Column() {
          Text('你是否理解以上核心概念？')
            .fontSize(14)
            .fontColor('#3C3C43')
            .margin({ bottom: 10 })
          Row() {
            Button('✋ 有些不懂 → 标记复习')
              .fontSize(13)
              .fontColor('#FF9500')
              .backgroundColor('#FFF3E0')
              .borderRadius(10)
              .layoutWeight(1)
            Button('✅ 我已理解 → 下一步')
              .fontSize(13)
              .fontColor('#FFFFFF')
              .backgroundColor('#1A73E8')
              .borderRadius(10)
              .layoutWeight(1)
              .margin({ left: 12 })
              .onClick(() => {
                this.currentStep = ThreeQStep.QUESTION_2_DEBATE;
                this.step1Progress = 100;
                this.courseStore.updateStep(this.courseId, ThreeQStep.QUESTION_2_DEBATE, 0);
                this.loadDebateTopics();
              })
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
      } else {
        this.LoadingView('点击下方按钮生成心智模型')
      }
    }
    .width('100%')
  }

  @Builder QuestionTwoContent() {
    Column() {
      Text('第二问：这个领域有哪些关键争议和不同观点？')
        .fontSize(14)
        .fontColor('#FF6D00')
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10, bottom: 10 })
      if (this.debateLoading) {
        this.LoadingView('正在分析多方资料，挖掘争议点...')
      } else if (this.debateTopics.length > 0) {
        ForEach(this.debateTopics, (topic: DebateTopic) => {
          DebateCompareCard({ topic: topic })
        })
        if (this.allDebatesDone()) {
          Row() {
            Text('✅ 所有争议点已回应')
              .fontSize(14)
              .fontColor('#34C759')
          }
          .margin({ top: 10 })
        }
      } else {
        this.LoadingView('点击下方按钮生成学术争议分析')
      }
    }
    .width('100%')
  }

  @Builder QuestionThreeContent() {
    Column() {
      Text('第三问：接下来进入深度测评，请独立作答')
        .fontSize(14)
        .fontColor('#5856D6')
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10, bottom: 10 })
      Column() {
        Text('💡 测评基于布鲁姆六层级认知模型')
          .fontSize(13)
          .fontColor('#8E8E93')
          .margin({ bottom: 8 })
        Text('记忆 → 理解 → 应用 → 分析 → 评价 → 创造')
          .fontSize(12)
          .fontColor('#1A73E8')
          .margin({ bottom: 16 })
        Text('⚠️ 请独立完成，不要复制AI答案')
          .fontSize(13)
          .fontColor('#FF3B30')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })
        Button('进入测评')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#5856D6')
          .borderRadius(12)
          .onClick(() => { router.pushUrl({ url: 'pages/QuizPage', params: { courseId: this.courseId } }) })
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
    }
    .width('100%')
  }

  @Builder ReportContent() {
    Column() {
      Text('学习报告')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1D1D1F')
        .margin({ top: 10, bottom: 10 })
      Column() {
        Text('📊 课程学习已完成')
          .fontSize(15)
          .fontColor('#34C759')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })
        Text('查看完整学习报告、能力雷达图、答题原始记录')
          .fontSize(13)
          .fontColor('#8E8E93')
          .margin({ bottom: 20 })
        Button('查看学习报告')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#34C759')
          .borderRadius(12)
          .onClick(() => { router.pushUrl({ url: 'pages/ReportPage', params: { courseId: this.courseId } }) })
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
    }
    .width('100%')
  }

  @Builder BottomButtons() {
    Row() {
      if (this.currentStep === ThreeQStep.QUESTION_1_MIND_MODEL) {
        Button(this.mindModel ? '🔄 重新生成' : '⚡ 生成心智模型')
          .width('100%')
          .height(44)
          .fontSize(15)
          .fontColor('#FFFFFF')
          .backgroundColor('#1A73E8')
          .borderRadius(10)
          .onClick(() => { this.loadMindModel() })
      } else if (this.currentStep === ThreeQStep.QUESTION_2_DEBATE) {
        Row() {
          if (this.allDebatesDone()) {
            Button('✅ 完成争议分析 → 下一步')
              .width('100%')
              .height(44)
              .fontSize(15)
              .fontColor('#FFFFFF')
              .backgroundColor('#FF6D00')
              .borderRadius(10)
              .onClick(() => {
                this.currentStep = ThreeQStep.QUESTION_3_QUIZ;
                this.step2Progress = 100;
                this.courseStore.updateStep(this.courseId, ThreeQStep.QUESTION_3_QUIZ, 0);
              })
          } else {
            Button('🔄 重新生成争议')
              .layoutWeight(1)
              .height(44)
              .fontSize(15)
              .fontColor('#FFFFFF')
              .backgroundColor('#FF6D00')
              .borderRadius(10)
              .onClick(() => { this.loadDebateTopics() })
            Button('跳过 → 进入测评')
              .layoutWeight(1)
              .height(44)
              .fontSize(15)
              .fontColor('#8E8E93')
              .backgroundColor('#E5E5EA')
              .borderRadius(10)
              .margin({ left: 10 })
              .onClick(() => {
                this.currentStep = ThreeQStep.QUESTION_3_QUIZ;
                this.step2Progress = 50;
                this.courseStore.updateStep(this.courseId, ThreeQStep.QUESTION_3_QUIZ, 0);
              })
          }
        }
        .width('100%')
      }
    }
    .width('100%')
    .margin({ top: 20 })
  }

  @Builder LoadingView(text: string) {
    Column() {
      LoadingProgress().width(36).height(36).color('#1A73E8')
      Text(text).fontSize(14).fontColor('#8E8E93').margin({ top: 10 })
    }
    .width('100%')
    .padding(40)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: 10 })
  }

  allDebatesDone(): boolean {
    return this.debateTopics.every((t: DebateTopic) => t.userOpinion && t.userOpinion.length > 0);
  }

  loadMindModel(): void {
    this.mindModelLoading = true;
    AiApiService.generateMindModel(this.courseId).then((res) => {
      if (res.code === 200 && res.data) {
        this.mindModel = res.data as MindModel;
        this.step1Progress = 80;
      } else {
        this.mindModel = this.makeMockMindModel();
        this.step1Progress = 80;
      }
      this.mindModelLoading = false;
    }).catch(() => {
      this.mindModel = this.makeMockMindModel();
      this.step1Progress = 80;
      this.mindModelLoading = false;
    });
  }

  loadDebateTopics(): void {
    this.debateLoading = true;
    AiApiService.generateDebate(this.courseId).then((res) => {
      if (res.code === 200 && res.data) {
        const data = res.data as Record<string, Object>;
        if (data['debates']) {
          this.debateTopics = data['debates'] as DebateTopic[];
        }
      } else {
        this.debateTopics = this.makeMockDebates();
      }
      this.debateLoading = false;
    }).catch(() => {
      this.debateTopics = this.makeMockDebates();
      this.debateLoading = false;
    });
  }

  makeMockMindModel(): MindModel {
    const title = this.course ? this.course.title : '核心领域';
    return {
      courseId: this.courseId,
      nodes: [
        { id: '1', label: title, description: '顶层框架', level: 0, sources: [], status: 'unread' },
        { id: '2', label: '基础概念', description: '基础知识', parentId: '1', level: 1, sources: [], status: 'unread' },
        { id: '3', label: '核心原理', description: '运行机制', parentId: '1', level: 1, sources: [], status: 'unread' },
        { id: '4', label: '实践应用', description: '动手环节', parentId: '1', level: 1, sources: [], status: 'unread' },
        { id: '5', label: '进阶话题', description: '深入方向', parentId: '1', level: 1, sources: [], status: 'unread' }
      ],
      edges: [
        { from: '1', to: '2', relation: '包含' },
        { from: '1', to: '3', relation: '包含' },
        { from: '1', to: '4', relation: '包含' },
        { from: '1', to: '5', relation: '包含' }
      ],
      generatedAt: new Date().toISOString()
    };
  }

  makeMockDebates(): DebateTopic[] {
    const topic = this.course ? this.course.title : '该领域';
    return [
      {
        id: 'd1',
        topic: topic + '的核心方法是否存在争议？',
        sideA: '传统方法论强调系统学习基础理论，循序渐进',
        sideB: '现代方法强调项目驱动、快速迭代、在实践中学习',
        evidenceA: ['教材1'],
        evidenceB: ['博客1']
      },
      {
        id: 'd2',
        topic: '学习路径：广度优先还是深度优先？',
        sideA: '先建立全局视野再深入细节，避免迷失方向',
        sideB: '深入一个方向建立基础能力后再扩展更高效',
        evidenceA: ['论文1'],
        evidenceB: ['社区讨论1']
      }
    ];
  }
}
