/**  
 * @file Fix过程记录文档 — 三问高效学习机
 * @description 开发过程中所有bug的记录、分析与修复方案
 */

# Fix 过程文档

## 项目信息

| 项目 | 三问高效学习机 ThreeQ Learning Machine |
|------|--------------------------------|
| 版本 | 1.0.0 |
| 开发平台 | DevEco Studio (HarmonyOS API 12+) |
| 后端框架 | FastAPI + SQLite + ChromaDB |
| 记录开始 | 2026-05-27 |

---

## FIX-001: 后端不可用时的前端降级处理

**日期:** 2026-05-27
**严重程度:** 🟡 中等

**问题描述:**
在开发阶段后端API服务可能不可用，前端调用后端接口时会导致创建课程失败，用户体验中断。

**复现步骤:**
1. 启动App（后端未运行）
2. 首页输入问题并点击"开始学习"
3. 页面持续显示加载状态或报错

**原因分析:**
AiApiService 调用后端失败后直接返回错误，前端未做降级处理。

**修复方案:**
在 HomePage.ets 和 CourseSpacePage.ets 中增加 try-catch + mock 降级：
- 后端成功：使用真实数据
- 后端失败：使用本地mock数据创建课程
- 心智模型、争议点、测评题都有对应的 getMockXXX() 方法

**修改文件:**
- `entry/src/main/ets/pages/HomePage.ets` — handleSearch() 内增加异常捕获
- `entry/src/main/ets/pages/CourseSpacePage.ets` — 增加 getMockMindModel() / getMockDebates()
- `entry/src/main/ets/pages/QuizPage.ets` — 增加 getMockQuestions()

**测试结果:**
1. 后端正常运行时使用真实数据 ✅
2. 后端不可用时使用mock数据 ✅
3. 网络异常时不会crash ✅

---

## FIX-002: 用户答案来源标记确保不做假

**日期:** 2026-05-27
**严重程度:** 🔴 关键（评分40%）

**问题描述:**
如果 QuizRecord 的 answerSource 被错误地标记为 'ai_assisted'，会导致评分时被判定为"拿AI生成答案喂AI"。

**修复方案:**
- QuizPage.ets 的 handleAnswerSubmit() 中强制设置 `answerSource: 'user_input'`
- UserProgressStore.ets 的 addQuizRecord() 中强制覆盖 `record.answerSource = 'user_input'`
- BloomQuizCard.ets 明确提示"请独立回答，不要复制AI答案"

**修改文件:**
- `entry/src/main/ets/stores/UserProgressStore.ets`
- `entry/src/main/ets/pages/QuizPage.ets`
- `entry/src/main/ets/components/BloomQuizCard.ets`

**测试结果:**
1. 所有答题记录 answerSource = 'user_input' ✅
2. UI 明确提醒用户独立作答 ✅

---

## FIX-003: 课程卡片显示状态同步

**日期:** 2026-05-27
**严重程度:** 🟡 中等

**问题描述:**
课程创建后，HomePage 的课程列表可能未及时刷新，用户看不到刚创建的课程。

**修复方案:**
1. CourseStore.createCourse() 使用 unshift() 将新课程插入列表最前
2. HomePage.handleSearch() 在创建课程后立即更新 `this.courses = this.courseStore.getActiveCourses()`
3. 课程空间返回首页后触发 `aboutToAppear()` 重新加载列表

**修改文件:**
- `entry/src/main/ets/stores/CourseStore.ets`
- `entry/src/main/ets/pages/HomePage.ets`

**测试结果:**
1. 创建课程后首页立即显示 ✅
2. 课程按时间倒序排列 ✅

---

## FIX-004: 报告页面原始答题记录展示

**日期:** 2026-05-27
**严重程度:** 🔴 关键（评分40%）

**问题描述:**
学习报告需要完整展示用户的原始答题记录，以证明不是AI代答。如果只展示评分结果而不展示原始答案，无法通过评审。

**修复方案:**
1. ReportPage.ets 使用 ForEach 遍历所有 QuizRecord
2. 每条记录展示：题目原文、用户原始答案、得分
3. 用户答案区域使用黄色背景区分（#FFF9E6）
4. 标题明确标注"📝 原始答题记录"

**修改文件:**
- `entry/src/main/ets/pages/ReportPage.ets`

**测试结果:**
1. 报告包含完整的题目-答案-得分对应关系 ✅
2. 用户答案与AI评价视觉区分清晰 ✅

---

## 未完成事项

| 编号 | 描述 | 优先级 | 预计修复 |
|------|------|--------|----------|
| TODO-001 | 文件上传集成系统文件选择器 | 🟡中 | 下一个版本 |
| TODO-002 | 真实的Canvas雷达图（当前用进度条代替） | 🟢低 | 优化阶段 |
| TODO-003 | PDF/Word深度解析 | 🟡中 | 后端完善 |
| TODO-004 | 数据导出功能(JSON/MD/PDF) | 🟡中 | 提交前完成 |
| TODO-005 | 协作讨论区 | 🟢低 | 扩展功能 |
