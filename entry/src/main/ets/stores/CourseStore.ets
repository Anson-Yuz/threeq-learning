import { CourseModel, CourseStage, ThreeQStep } from '../models/CourseModel';

/**
 * 课程状态管理 Store
 * 管理所有课程的状态、进度流转
 */
@Observed
export class CourseStore {
  courses: CourseModel[] = [];
  currentCourseId: string = '';
  loading: boolean = false;

  constructor(userId: string) {
    this.loadCourses(userId);
  }

  async loadCourses(userId: string): Promise<void> {
    this.loading = true;
    // 优先从本地加载，后续同步远端
    this.courses = [];
    this.loading = false;
  }

  createCourse(question: string, userId: string): CourseModel {
    const newCourse: CourseModel = {
      id: `course_${Date.now()}`,
      userId: userId,
      title: this.extractTitle(question),
      question: question,
      stage: CourseStage.CREATED,
      step: ThreeQStep.QUESTION_1_MIND_MODEL,
      stepProgress: 0,
      totalProgress: 0,
      materialCount: { ai: 0, user: 0 },
      abilities: {
        conceptUnderstanding: 0,
        criticalThinking: 0,
        practicalTransfer: 0,
        expressionLogic: 0
      },
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      lastStudyTime: new Date().toISOString()
    };

    this.courses.unshift(newCourse);
    this.currentCourseId = newCourse.id;
    return newCourse;
  }

  // 从问题中提取课程标题
  private extractTitle(question: string): string {
    const patterns = [
      /如何(?:快速)?(?:掌握|学习|入门|理解)(.+?)(?:[？?]|$)/,
      /(.+?)是什么(?:[？?]|$)/,
      /(?:怎样|怎么)(.+?)(?:[？?]|$)/,
    ];
    for (const p of patterns) {
      const m = question.match(p);
      if (m) {
        return m[1].trim();
      }
    }
    // fallback: 取问题前20字
    return question.length > 20 ? question.substring(0, 20) + '...' : question;
  }

  // 获取当前课程
  getCurrentCourse(): CourseModel | undefined {
    return this.courses.find(c => c.id === this.currentCourseId);
  }

  // 更新课程阶段
  updateStep(courseId: string, step: ThreeQStep, progress: number): void {
    const course = this.courses.find(c => c.id === courseId);
    if (course) {
      course.step = step;
      course.stepProgress = progress;
      course.totalProgress = this.calcTotalProgress(step, progress);
      course.stage = CourseStage.ACTIVE;
      course.updatedAt = new Date().toISOString();
    }
  }

  // 完成课程
  completeCourse(courseId: string): void {
    const course = this.courses.find(c => c.id === courseId);
    if (course) {
      course.stage = CourseStage.COMPLETED;
      course.totalProgress = 100;
      course.updatedAt = new Date().toISOString();
    }
  }

  // 归档课程
  archiveCourse(courseId: string): void {
    const course = this.courses.find(c => c.id === courseId);
    if (course) {
      course.stage = CourseStage.ARCHIVED;
      course.updatedAt = new Date().toISOString();
    }
  }

  // 获取活跃课程列表
  getActiveCourses(): CourseModel[] {
    return this.courses
      .filter(c => c.stage !== CourseStage.ARCHIVED)
      .sort((a, b) => new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime());
  }

  // 计算总进度
  private calcTotalProgress(step: ThreeQStep, stepProgress: number): number {
    const stepWeights: Record<number, number> = {
      1: 0.3,   // 心智模型 30%
      2: 0.3,   // 争议挖掘 30%
      3: 0.3,   // 深度测评 30%
      4: 0.1    // 报告 10%
    };
    const prevProgress = step <= 1 ? 0 : stepWeights[step - 1] || 0;
    return Math.round((prevProgress + stepWeights[step] * stepProgress / 100) * 100);
  }
}
