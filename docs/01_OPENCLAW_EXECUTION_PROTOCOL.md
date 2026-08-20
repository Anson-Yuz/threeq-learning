# OpenClaw 执行协议

## 1. 协作目标

OpenClaw 负责具体实施升级任务。Codex 通过 GitHub Issue、PR、优化日志评论查看进度、提出审查意见和补充方案。

所有沟通以 GitHub 为准，避免口头信息丢失。

## 2. GitHub 初始化要求

项目上传 GitHub 后必须完成：

1. 创建 `main` 分支并保护。
2. 创建 `develop` 分支作为集成分支。
3. 启用 Issue。
4. 启用 Pull Request。
5. 添加 Issue 模板和 PR 模板。
6. 配置标签。
7. 配置 GitHub Actions。
8. 禁止直接提交到 `main`。

推荐标签：

- `area:ui`
- `area:harmonyos`
- `area:architecture`
- `area:feature`
- `area:offline`
- `area:sync`
- `area:testing`
- `area:docs`
- `area:ops`
- `priority:p0`
- `priority:p1`
- `priority:p2`
- `status:openclaw-working`
- `status:blocked`
- `status:needs-review`
- `status:accepted`

## 3. Issue 规则

每个任务必须有独立 Issue。

Issue 必须包含：

1. 背景。
2. 范围。
3. 非目标。
4. HarmonyOS 组件和 API 约束。
5. UI 要求。
6. 数据和接口要求。
7. 验收标准。
8. 测试要求。
9. 风险。
10. 优化日志区。

任务拆分粒度：

- 一个页面改造一个 Issue。
- 一个核心业务闭环一个 Issue。
- 一个自动化能力一个 Issue。
- 一个文档包一个 Issue。

## 4. 优化日志格式

OpenClaw 每次阶段性提交进展时，在对应 Issue 下追加评论：

```markdown
## 优化日志

时间：YYYY-MM-DD HH:mm
执行者：OpenClaw
关联分支：
关联 PR：

### 本次完成
- 

### 涉及文件
- 

### HarmonyOS 规范检查
- ArkUI 原生组件：
- ArkTS 类型：
- 状态管理：
- 权限与隐私：
- 资源管理：

### 自动化验证
- lint：
- 单元测试：
- UI 自动化：
- 构建：

### 截图/录屏
- 

### 风险与阻塞
- 

### 下一步
- 
```

Codex 只根据这些日志和 PR diff 进行审查，不依赖线下口头说明。

## 5. PR 规则

每个 PR 必须：

1. 关联 Issue。
2. 控制变更范围。
3. 包含截图或录屏，UI 改造必须提供。
4. 包含自动化验证结果。
5. 说明 HarmonyOS 组件选择。
6. 说明是否影响数据结构、接口或权限。
7. 不提交签名证书、密钥、账号 token。

PR 合并前必须满足：

- CI 通过。
- 没有 P0/P1 未解决评论。
- 用户手册或开发文档同步更新。
- 优化日志完整。

## 6. 分支命名

推荐：

```text
feature/ui-home-material3
feature/ui-course-center
feature/practice-flow
feature/mistake-review
feature/offline-sync
feature/learning-report
feature/github-actions
docs/user-manual
fix/sync-retry
```

Codex 自动改造分支可使用：

```text
codex/<short-task-name>
```

## 7. 阶段性里程碑

### M0：仓库与协作机制

完成：

- GitHub 仓库。
- Issue 模板。
- PR 模板。
- README。
- AGENTS.md。
- 文档目录。

### M1：现状审计

完成：

- 架构审计。
- 页面审计。
- 功能审计。
- 接口审计。
- 自动化缺口审计。

### M2：设计系统

完成：

- 主题 token。
- 公共组件。
- 页面模板。
- 交互状态规范。

### M3：核心页面改造

完成：

- 首页。
- 课程中心。
- 练习页。
- 错题本。
- 学习报告。
- 设置中心。

### M4：学习闭环

完成：

- 任务。
- 学习。
- 练习。
- 错题。
- 复习。
- 报告。

### M5：自动化与发布

完成：

- CI。
- 自动化测试。
- 构建产物。
- 发布说明。
- 回滚预案。

## 8. Codex 审查标准

Codex 审查时重点看：

1. 是否符合 HarmonyOS 生态和 ArkUI 写法。
2. 是否有 Android/Web 思维硬搬问题。
3. 是否存在不可维护的大组件。
4. 是否破坏状态管理边界。
5. 是否遗漏异常态和离线态。
6. 是否有敏感信息泄露。
7. 是否有自动化验证。
8. 是否更新用户手册。
9. UI 是否符合 Google 风格但不违背鸿蒙体验。

