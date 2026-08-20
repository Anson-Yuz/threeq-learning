import { QuizRecord, AbilityScores } from '../models/CourseModel';

/**
 * 用户进度状态管理
 */
@Observed
export class UserProgressStore {
  quizRecords: QuizRecord[] = [];
  abilityScores: AbilityScores = {
    conceptUnderstanding: 0,
    criticalThinking: 0,
    practicalTransfer: 0,
    expressionLogic: 0
  };
  totalQuizzes: number = 0;
  completedQuizzes: number = 0;

  // 添加答题记录（仅保存用户原始答案）
  addQuizRecord(record: QuizRecord): void {
    // 强制标记为用户输入
    record.answerSource = 'user_input';
    this.quizRecords.push(record);
    this.completedQuizzes++;

    // 更新能力评分
    this.recalculateAbilities();
  }

  // 获取某课程的所有答题记录
  getCourseRecords(courseId: string): QuizRecord[] {
    return this.quizRecords.filter(r => r.courseId === courseId);
  }

  // 重新计算能力维度
  private recalculateAbilities(): void {
    if (this.quizRecords.length === 0) return;

    const sums = { conceptAccuracy: 0, logic: 0, application: 0, reflection: 0, expression: 0 };
    let count = 0;

    for (const record of this.quizRecords) {
      sums.conceptAccuracy += record.dimensions.conceptAccuracy;
      sums.logic += record.dimensions.logic;
      sums.application += record.dimensions.application;
      sums.reflection += record.dimensions.reflection;
      sums.expression += record.dimensions.expression;
      count++;
    }

    this.abilityScores = {
      conceptUnderstanding: Math.round(sums.conceptAccuracy / count),
      criticalThinking: Math.round((sums.logic + sums.reflection) / (2 * count)),
      practicalTransfer: Math.round(sums.application / count),
      expressionLogic: Math.round(sums.expression / count)
    };
  }

  // 获取错题集
  getWrongAnswers(courseId?: string): QuizRecord[] {
    const records = courseId
      ? this.quizRecords.filter(r => r.courseId === courseId)
      : this.quizRecords;
    return records.filter(r => r.score < r.maxScore * 0.6);
  }

  // 清空记忆（用于重置）
  clear(): void {
    this.quizRecords = [];
    this.abilityScores = {
      conceptUnderstanding: 0,
      criticalThinking: 0,
      practicalTransfer: 0,
      expressionLogic: 0
    };
    this.completedQuizzes = 0;
  }
}
