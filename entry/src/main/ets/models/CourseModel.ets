// ===== 课程状态枚举 =====
export enum CourseStage {
  NOT_CREATED = 'NOT_CREATED',
  CREATED = 'CREATED',
  ACTIVE = 'ACTIVE',
  COMPLETED = 'COMPLETED',
  ARCHIVED = 'ARCHIVED'
}

export enum ThreeQStep {
  QUESTION_1_MIND_MODEL = 1,
  QUESTION_2_DEBATE = 2,
  QUESTION_3_QUIZ = 3,
  REPORT = 4
}

// ===== 课程模型 =====
export interface CourseModel {
  id: string;
  userId: string;
  title: string;
  question: string;
  stage: CourseStage;
  step: ThreeQStep;
  stepProgress: number;   // 0-100
  totalProgress: number;  // 0-100
  materialCount: { ai: number; user: number };
  abilities: AbilityScores;
  createdAt: string;
  updatedAt: string;
  lastStudyTime?: string;
}

// ===== 能力维度 =====
export interface AbilityScores {
  conceptUnderstanding: number;  // 概念理解
  criticalThinking: number;     // 批判思维
  practicalTransfer: number;    // 实践迁移
  expressionLogic: number;      // 表达逻辑
}

// ===== 心智模型 =====
export interface MindNode {
  id: string;
  label: string;
  description: string;
  parentId?: string;
  level: number;
  sources: string[];
  status: 'understood' | 'confused' | 'unread';
}

export interface MindEdge {
  from: string;
  to: string;
  relation: string;
}

export interface MindModel {
  courseId: string;
  nodes: MindNode[];
  edges: MindEdge[];
  generatedAt: string;
}

// ===== 争议点 =====
export interface DebateTopic {
  id: string;
  topic: string;
  sideA: string;
  sideB: string;
  evidenceA: string[];
  evidenceB: string[];
  userOpinion?: string;
  userVerdict?: 'a' | 'b' | 'synthesis';
  evidenceCited?: string;
}

// ===== 测评题目 =====
export enum BloomLevel {
  REMEMBER = 'remember',
  UNDERSTAND = 'understand',
  APPLY = 'apply',
  ANALYZE = 'analyze',
  EVALUATE = 'evaluate',
  CREATE = 'create'
}

export const BloomLevelLabel: Record<BloomLevel, string> = {
  [BloomLevel.REMEMBER]: '记忆',
  [BloomLevel.UNDERSTAND]: '理解',
  [BloomLevel.APPLY]: '应用',
  [BloomLevel.ANALYZE]: '分析',
  [BloomLevel.EVALUATE]: '评价',
  [BloomLevel.CREATE]: '创造'
};

export interface QuizQuestion {
  id: string;
  courseId: string;
  bloomLevel: BloomLevel;
  questionText: string;
  questionType: 'short_answer' | 'choice' | 'essay' | 'code' | 'project';
  choices?: string[];
  correctAnswer?: string;
  gradingRubric: string;
  points: number;
}

export interface QuizAnswer {
  questionId: string;
  answerSource: 'user_input' | 'ai_assisted';
  userAnswer: string;
  aiReferenceUsed: boolean;
}

export interface QuizRecord {
  id: string;
  courseId: string;
  questionText: string;
  bloomLevel: BloomLevel;
  userAnswer: string;
  answerSource: 'user_input';
  aiReferenceUsed: boolean;
  score: number;
  maxScore: number;
  dimensions: {
    conceptAccuracy: number;
    logic: number;
    application: number;
    reflection: number;
    expression: number;
  };
  feedback: string;
  improvementTips: string;
  createdAt: string;
}

// ===== 学习报告 =====
export interface LearningReport {
  id: string;
  courseId: string;
  totalScore: number;
  abilityScores: AbilityScores;
  aiSuggestions: string;
  quizRecords: QuizRecord[];
  debateRecords: DebateTopic[];
  rawQuestions: string[];
  improvementPlan: string;
  generatedAt: string;
}

// ===== 学习资料 =====
export interface Material {
  id: string;
  courseId: string;
  title: string;
  content: string;
  sourceType: 'ai_crawled' | 'user_uploaded';
  sourceUrl?: string;
  filePath?: string;
  fileType?: 'pdf' | 'docx' | 'md' | 'txt';
  createdAt: string;
}
