/**
 * 日期工具
 */
export class DateUtil {
  static format(date: string | Date, pattern: string = 'YYYY-MM-DD HH:mm'): string {
    const d = typeof date === 'string' ? new Date(date) : date;
    const y = d.getFullYear().toString();
    const m = (d.getMonth() + 1).toString().padStart(2, '0');
    const day = d.getDate().toString().padStart(2, '0');
    const h = d.getHours().toString().padStart(2, '0');
    const min = d.getMinutes().toString().padStart(2, '0');
    const s = d.getSeconds().toString().padStart(2, '0');

    return pattern
      .replace('YYYY', y)
      .replace('MM', m)
      .replace('DD', day)
      .replace('HH', h)
      .replace('mm', min)
      .replace('ss', s);
  }

  static relative(date: string | Date): string {
    const now = Date.now();
    const then = typeof date === 'string' ? new Date(date).getTime() : date.getTime();
    const diff = now - then;
    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (minutes < 1) return '刚刚';
    if (minutes < 60) return `${minutes}分钟前`;
    if (hours < 24) return `${hours}小时前`;
    if (days < 7) return `${days}天前`;
    return this.format(date, 'MM-DD HH:mm');
  }

  static nowISO(): string {
    return new Date().toISOString();
  }
}

/**
 * 验证工具
 */
export class Validator {
  static isNotEmpty(value: string): boolean {
    return value !== undefined && value !== null && value.trim().length > 0;
  }

  static minLength(value: string, min: number): boolean {
    return value.trim().length >= min;
  }

  static isValidQuestion(question: string): boolean {
    return this.isNotEmpty(question) && this.minLength(question, 3);
  }

  static isValidAnswer(answer: string): boolean {
    return this.isNotEmpty(answer) && this.minLength(answer, 1);
  }
}

/**
 * 日志工具
 */
import hilog from '@ohos.hilog';

export class Logger {
  private static readonly DOMAIN = 0x0001;
  private static readonly TAG = 'ThreeQ';

  static info(module: string, message: string): void {
    hilog.info(this.DOMAIN, this.TAG, `[${module}] ${message}`);
  }

  static warn(module: string, message: string): void {
    hilog.warn(this.DOMAIN, this.TAG, `[${module}] ${message}`);
  }

  static error(module: string, message: string): void {
    hilog.error(this.DOMAIN, this.TAG, `[${module}] ${message}`);
  }
}
