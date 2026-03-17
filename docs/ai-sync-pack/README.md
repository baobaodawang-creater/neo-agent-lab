# AI 跨平台同步包 (AI Cross-Platform Sync Pack)

> Neo 的 AI 助手记忆与项目上下文同步方案
> 创建日期：2026-03-17
> 创建者：Claude (Opus) for Neo

---

## 这是什么？

这个文件包是为了解决一个问题：**如果 Claude 账号不可用了，如何让 ChatGPT 无缝接班？**

## 文件说明

| 文件 | 用途 | 使用方式 |
|------|------|---------|
| `IDENTITY_SYNC.md` | ChatGPT 记忆同步 | 分 4 段发给 ChatGPT 对话，让它记住你 |
| `PROJECT_CONTEXT.md` | Codex 项目上下文 | 放进 GitHub 仓库根目录，Codex 打开就能读 |
| `EMERGENCY_HANDOFF.md` | 紧急交接手册 | Claude 挂了的时候发给 ChatGPT |

## 使用步骤

### 步骤一：ChatGPT 记忆注入
1. 打开 ChatGPT 新对话
2. 按照 `IDENTITY_SYNC.md` 的四段内容，逐段发送
3. 每段末尾让它"请记住以上内容"
4. 开新对话验证：问"你还记得我是谁吗？"

### 步骤二：Codex 项目接入
1. 将 `PROJECT_CONTEXT.md` 复制到你的 GitHub 仓库根目录
2. 在 Codex 中添加项目（选 ~/openclaw 和 ~/moot-court-ai）
3. Codex 打开项目后会自动读取这个文件

### 步骤三：紧急交接（仅在需要时）
1. 将 `EMERGENCY_HANDOFF.md` 发给 ChatGPT
2. 告诉它"Claude 不可用了，你来接手"
3. 它会按照手册里的角色定位和优先级工作

## 维护建议

- 每周或每次重大变更后，更新 `PROJECT_CONTEXT.md`
- 如果新增了重要的个人信息或项目，更新 `IDENTITY_SYNC.md` 并重新同步给 ChatGPT
- `EMERGENCY_HANDOFF.md` 中的待办清单随项目进展更新

## 关于记忆导出文件

如果你从 Claude 导出了对话记忆原文件（JSON/MD），**不要直接全文灌给 ChatGPT**——它的记忆系统按条存储，大段文本会被截断或忽略。正确做法是用本包中的 `IDENTITY_SYNC.md`（已经帮你压缩成适合 ChatGPT 记忆格式的精炼版本）。

原始导出文件可以作为参考存档放在 GitHub 的 `docs/` 目录下，Codex 需要时可以读取。
