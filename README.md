# 三问高效学习机 — ThreeQ Learning Machine

> 面向AI时代大学生的柔性课程构建与认知闭环训练工具

## 项目概述

学生只需提出一个学习问题，系统自动生成课程空间，并按"三问法"完成学习闭环。

## 三问学习法

1. **第一问：核心心智模型** — 这个领域的底层逻辑是什么？
2. **第二问：学术争议挖掘** — 这个领域有哪些关键争议和不同观点？
3. **第三问：深度测评** — 我是否真的理解，并能迁移应用？

## 技术栈

| 层级 | 技术 |
|------|------|
| 前端 | HarmonyOS ArkTS + ArkUI (API 9) |
| 后端 | Python FastAPI + AI Agents |
| 数据库 | SQLite + ChromaDB |
| AI | OpenAI-compatible API (DeepSeek等) |

## 快速开始

### 前端

1. 用 DevEco Studio 打开项目
2. 同步依赖
3. 运行到模拟器或真机

### 后端

```bash
cd D:\Dev\Project\threeq-ai-server
pip install -r requirements.txt
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

## 工程结构

```
entry/src/main/ets/
├── pages/            # 8个页面
│   ├── HomePage.ets           # 首页-课程生成
│   ├── CourseSpacePage.ets    # 课程空间-三问工作台
│   ├── QuizPage.ets           # 测评页
│   ├── ReportPage.ets         # 学习报告
│   ├── ProfilePage.ets        # 个人中心
│   ├── MaterialUploadPage.ets # 资料上传
│   ├── MindModelPage.ets      # 心智模型
│   └── DebatePage.ets         # 争议讨论
├── components/       # 7个组件
├── models/           # 数据模型
├── services/         # API服务
├── stores/           # 状态管理
└── utils/            # 工具类
```

## 评分要点（60% + 40%）

### 60% — 三问高效学习法
- ✅ 三个步骤显性独立展示（步骤条 + 独立内容区）
- ✅ 柔性课程生成（任意问题 → 课程空间）
- ✅ 学生自主组件知识 + AI 补充资料
- ✅ ArkTS 原生开发

### 40% — 评价报告
- ✅ 用户原始答案完整记录（answerSource: user_input）
- ✅ AI 评价维度分层（概念/逻辑/应用/反思/表达）
- ✅ 报告包含原始对话记录

## 升级计划

本项目正在进行全面升级，详见 [docs/00_UPGRADE_MASTER_PLAN.md](docs/00_UPGRADE_MASTER_PLAN.md)。

## 许可证

课程作业项目，仅供学习交流。
