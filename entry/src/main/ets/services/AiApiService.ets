/**
 * 三问高效学习机 — API 配置
 * 后端运行地址，根据实际部署修改
 */
export class ApiConfig {
  static readonly BASE_URL: string = 'http://10.0.2.2:8000'; // 模拟器访问本机
  static readonly TIMEOUT: number = 30000;

  static getUrl(path: string): string {
    return `${this.BASE_URL}${path}`;
  }
}

/**
 * API 响应基础结构
 */
export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
}

/**
 * HTTP 请求封装
 */
import http from '@ohos.net.http';
import { Logger } from '../utils/Utils';

export class AiApiService {
  static async request<T>(method: http.RequestMethod, path: string, body?: object): Promise<ApiResponse<T>> {
    const url = ApiConfig.getUrl(path);

    try {
      const httpRequest = http.createHttp();
      const headers: Record<string, string> = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };

      const options: http.HttpRequestOptions = {
        method: method,
        header: headers,
        connectTimeout: ApiConfig.TIMEOUT,
        readTimeout: ApiConfig.TIMEOUT
      };

      if (body) {
        options.extraData = JSON.stringify(body);
      }

      Logger.info('AiApiService', `${method} ${path}`);
      const response = await httpRequest.request(url, options);
      httpRequest.destroy();

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as ApiResponse<T>;
        return result;
      } else {
        Logger.error('AiApiService', `HTTP ${response.responseCode}: ${response.result}`);
        return {
          code: response.responseCode,
          message: `请求失败: ${response.responseCode}`,
          data: null as T
        };
      }
    } catch (error) {
      Logger.error('AiApiService', `Request failed: ${JSON.stringify(error)}`);
      return {
        code: 500,
        message: '网络请求异常',
        data: null as T
      };
    }
  }

  // ===== 课程 API =====
  static async createCourse(question: string, userId: string): Promise<ApiResponse<object>> {
    return this.request(http.RequestMethod.POST, '/api/course/create', { userQuestion: question, userId });
  }

  static async getCourse(courseId: string): Promise<ApiResponse<object>> {
    return this.request(http.RequestMethod.GET, `/api/course/${courseId}`);
  }

  static async listCourses(userId: string): Promise<ApiResponse<object>> {
    return this.request(http.RequestMethod.GET, `/api/course/list/${userId}`);
  }

  // ===== 三问 API =====
  static async generateMindModel(courseId: string): Promise<ApiResponse<object>> {
    return this.request(http.RequestMethod.POST, '/api/threeq/mind-model', { courseId });
  }

  static async generateDebate(courseId: string): Promise<ApiResponse<object>> {
    return this.request(http.RequestMethod.POST, '/api/threeq/debate', { courseId });
  }

  static async submitDebateOpinion(courseId: string, topicId: string, opinion: string): Promise<ApiResponse<object>> {
    return this.request(http.RequestMethod.POST, '/api/threeq/submit-debate-opinion', { courseId, topicId, opinion });
  }

  // ===== 测评 API =====
  static async generateQuiz(courseId: string): Promise<ApiResponse<object>> {
    return this.request(http.RequestMethod.POST, '/api/quiz/generate', { courseId });
  }

  static async submitAnswer(quizData: object): Promise<ApiResponse<object>> {
    return this.request(http.RequestMethod.POST, '/api/quiz/submit-answer', quizData);
  }

  // ===== 报告 API =====
  static async generateReport(courseId: string): Promise<ApiResponse<object>> {
    return this.request(http.RequestMethod.POST, '/api/report/generate', { courseId });
  }

  static async getReport(courseId: string): Promise<ApiResponse<object>> {
    return this.request(http.RequestMethod.GET, `/api/report/${courseId}`);
  }

  // ===== 资料 API =====
  static async uploadMaterial(courseId: string, fileUri: string): Promise<ApiResponse<object>> {
    return this.request(http.RequestMethod.POST, '/api/material/upload', { courseId, fileUri });
  }

  static async listMaterials(courseId: string): Promise<ApiResponse<object>> {
    return this.request(http.RequestMethod.GET, `/api/material/list/${courseId}`);
  }

  static async crawlMaterials(courseId: string): Promise<ApiResponse<object>> {
    return this.request(http.RequestMethod.POST, '/api/material/crawl', { courseId });
  }
}
