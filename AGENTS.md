# AGENTS.md — OpenClaw 协作规范

## 项目

三问高效学习机 — ThreeQ Learning Machine
HarmonyOS ArkTS + Python FastAPI 后端

## 目录结构

```
ThreeQStudyMachine_HarmonyOS/
├── AppScope/                 # 应用全局配置
├── entry/                    # 主模块
│   └── src/main/ets/
│       ├── entryability/     # 应用入口
│       ├── pages/            # 页面（8个）
│       ├── components/       # 组件（7个）
│       ├── models/           # 数据模型
│       ├── services/         # API 服务
│       ├── stores/           # 状态管理
│       └── utils/            # 工具类
├── hvigor/                   # 构建配置
├── docs/                     # 升级方案文档
├── .github/                  # Issue/PR 模板
├── AGENTS.md                 # 本文件
├── README.md                 # 项目说明
├── FIX_LOG.md                # 修复记录
└── oh-package.json5          # 依赖配置
```

## 升级方案

完整方案见 `docs/00_UPGRADE_MASTER_PLAN.md`，分 6 个阶段：

| 阶段 | 内容 | 状态 |
|------|------|------|
| Phase 0 | 仓库初始化与基线建立 | 🔄 进行中 |
| Phase 1 | 现状审计 | ⏳ 待开始 |
| Phase 2 | 设计系统与 UI 改造 | ⏳ 待开始 |
| Phase 3 | 业务闭环 | ⏳ 待开始 |
| Phase 4 | 离线与同步 | ⏳ 待开始 |
| Phase 5 | 自动化工程 | ⏳ 待开始 |
| Phase 6 | 文档与发布 | ⏳ 待开始 |

## 技术栈

- **前端：** HarmonyOS ArkTS (API 9) + ArkUI
- **后端：** Python FastAPI + SQLite + ChromaDB
- **构建：** DevEco Studio + Hvigor
- **UI 风格：** Google Material Design 3 视觉语言 + ArkUI 原生组件

## 代码规范

详见 `docs/02_HARMONYOS_CODE_STANDARDS.md`，核心原则：

1. ArkTS 类型明确，禁止无理由 `any`
2. 页面组件不超过合理长度，复杂页面拆分
3. 公共组件无业务副作用
4. 网络/存储/权限/日志统一封装
5. 资源使用主题 token，禁止大量硬编码
6. 异常进入统一错误模型
7. 敏感信息不入日志

## Git 规范

- `main` — 稳定发布（保护分支）
- `develop` — 集成分支
- `feature/*` — 功能分支
- `fix/*` — 缺陷修复
- `docs/*` — 文档更新

提交信息格式：`<type>(<scope>): <description>`

type: feat / fix / docs / style / refactor / test / chore

## 执行方式

1. 每个升级点对应 GitHub Issue
2. 每个 Issue 有验收标准
3. 每次 PR 前写优化日志
4. PR 说明改动范围、截图、验证结果
