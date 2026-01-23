# 项目开发规范与 Claude Skills

> 基于 Java Spring Boot 的企业级项目开发规范，配套 Claude Code 技能集，实现标准化、自动化的开发流程。

## 📋 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2025-01-15 | 初始版本 |
| v1.1 | 2025-01-16 | 新增 4.3 强制执行规则章节 |
| v1.2 | 2025-01-16 | 重构 /analyze 为两阶段流程（需求分析 + 技术方案） |
| v2.1 | 2026-01-16 | 完善开发流程，增加 review/test 必做环节 |
| v2.2 | 2026-01-17 | 完善需求变更流程，强化测试和文档同步 |
| v3.0 | 2026-01-19 | 添加持续优化 claude、skill |
| v3.1 | 2026-01-20 | 修改为全流程任务，防止中断后无法继续 |
| v3.2 | 2026-01-23 | 新增 proj-resume 技能，完善中断恢复机制 |

## 🎯 项目概述

本项目提供了一套完整的 Java Spring Boot 项目开发规范，包含：

- **标准化开发流程**：从需求分析到代码提交的完整流程
- **Claude Skills 技能集**：13 个专业技能，覆盖开发全生命周期
- **代码生成模板**：Entity、Service、Controller 等标准模板
- **质量保证体系**：代码审查、测试生成、安全检查

### 技术栈

- **框架**：Java 17 + Spring Boot 3.x + MyBatis-Plus 3.5.x
- **数据库**：MySQL 8.0+ + Redis 7.0+
- **API文档**：Knife4j 4.x
- **测试框架**：JUnit 5 + Mockito + AssertJ

## 🚀 快速开始

### 1. 安装 Claude Code

```bash
# 安装 Claude Code CLI
npm install -g @anthropic/claude-code

# 初始化项目
claude-code init
```

### 2. 导入技能集

将本项目的 `.claude/skills` 目录复制到你的项目根目录：

```bash
cp -r project-standards/.claude/skills your-project/.claude/
```

### 3. 开始开发

使用标准开发流程：

```bash
# 1. 需求分析
/proj-analyze-req

# 2. 技术方案设计
/proj-analyze-design

# 3. 任务拆分
/proj-task

# 4. 代码生成
/proj-gen

# 5. 代码审查
/proj-review

# 6. 生成测试
/proj-gen-test
```

## 🛠️ Claude Skills 技能集

### 流程类技能

| 技能 | 描述 | 使用场景 |
|------|------|----------|
| `/proj-analyze-req` | 需求分析与确认 | 新需求开始，澄清需求、明确边界 |
| `/proj-analyze-design` | 技术方案设计 | 需求确认后，设计数据库、接口、代码结构 |
| `/proj-task` | 任务管理 | 方案确认后拆分任务，跟踪开发进度 |
| `/proj-review` | 代码审查 | 代码完成后自检，安全性能检查 |

### 生成类技能

| 技能 | 描述 | 使用场景 |
|------|------|----------|
| `/proj-gen` | 代码生成统一入口 | 生成 SQL、Entity、Service、Controller |
| `/proj-gen-test` | 测试代码生成 | 生成单元测试和集成测试 |

### 辅助类技能

| 技能 | 描述 | 使用场景 |
|------|------|----------|
| `/proj-fix` | Bug 快速修复 | 线上问题快速定位和修复 |
| `/proj-change` | 需求变更处理 | 开发过程中需求调整 |
| `/proj-common` | 公共规范查看 | 查看响应格式、错误码等规范 |
| `/proj-deploy` | 部署配置生成 | 生成 Docker、Nginx 配置 |
| `/proj-refactor` | 代码重构指南 | 改善代码质量，消除代码坏味道 |
| `/proj-optimize` | 持续优化 | 记录问题，批量优化，自我进化 |
| `/proj-resume` | 中断后快速恢复开发进度 | 对话中断后继续开发、新会话接续之前的工作 |

## 📁 项目结构

```
project-standards/
├── CLAUDE.md                    # 核心开发规范文档
├── README.md                    # 项目说明文档
└── .claude/skills/              # Claude Skills 技能集
    ├── proj-analyze-req/        # 需求分析技能
    │   ├── SKILL.md
    │   └── templates/
    ├── proj-analyze-design/     # 技术方案设计技能
    │   ├── SKILL.md
    │   └── templates/
    ├── proj-gen/                # 代码生成技能
    │   ├── SKILL.md
    │   └── templates/
    │       ├── entity.md        # Entity 模板
    │       ├── service.md       # Service 模板
    │       ├── controller.md    # Controller 模板
    │       ├── dto.md           # DTO 模板
    │       └── sql-reference.md # SQL 参考
    ├── proj-review/             # 代码审查技能
    │   ├── SKILL.md
    │   └── templates/
    ├── proj-gen-test/           # 测试生成技能
    │   ├── SKILL.md
    │   └── templates/
    ├── proj-resume/             # 开发进度恢复技能
    │   └── SKILL.md
    ├── proj-common/             # 公共规范
    │   ├── SKILL.md
    │   ├── response.md          # 响应格式规范
    │   ├── errorcode.md         # 错误码规范
    │   └── exception.md         # 异常处理规范
    └── [其他技能目录...]
```

## 🔄 标准开发流程

### 新功能开发

```mermaid
graph LR
    A[需求分析] --> B[用户确认]
    B --> C[技术方案]
    C --> D[用户确认]
    D --> E[任务拆分]
    E --> F[代码生成]
    F --> G[业务开发]
    G --> H[代码审查]
    H --> I[生成测试]
    I --> J[运行测试]
    J --> K[用户确认]
    K --> L[Git提交]
```

### 需求变更流程

```mermaid
graph LR
    A[需求变更] --> B[代码修改]
    B --> C[代码审查]
    C --> D[生成测试]
    D --> E[运行测试]
    E --> F[文档同步]
```

## 📋 强制规则

### 流程规则（必须做）
- **先问再做**：需求不清楚必须先澄清，禁止假设
- **分阶段确认**：需求确认 → 方案确认 → 开发，不可跳过
- **逐个开发**：按任务列表顺序，一个完成再下一个
- **需求开始建档**：用户输入需求后必须创建全流程任务文档骨架
- **变更必测试**：使用`/proj-change`后必须同步修改测试代码并运行测试
- **变更必审查**：使用`/proj-change`后必须执行`/proj-review`进行代码自检
- **变更必同步文档**：使用`/proj-change`后必须同步更新需求和技术方案文档

### 需求分析规则（必须做）
- **文档边界**：需求文档描述"做什么"，技术文档描述"怎么做"
- **禁止内容**：需求文档不得包含数据库表设计、接口定义、技术架构、代码结构
- **流程图规范**：简单流程（≤3步）用文字，复杂流程用Mermaid图

### 技术方案规则（必须做）
- **接口设计**：必须包含完整的请求参数、响应格式、错误码

- **核心业务逻辑设计**：简单流程（≤3步）用文字，复杂流程用时序图、状态图、用例图、流程图描述，禁止写代码

### 任务跟踪规则（必须做）
- **实时更新任务状态**：每完成一个任务立即更新状态标记 `[ ]` → `[x]`
- **实时记录提交信息**：每完成一个任务立即在提交记录区域添加完成信息
- **支持中断恢复**：确保任务状态和提交记录完整，对话中断后能快速恢复进度
- **全流程可恢复**：任务文档必须包含流程状态总览、产物清单、上下文快照、下一步指令

### 代码生成规则（必须做）
- **优先使用代码生成工具**：必须使用 `/proj-gen` 生成代码，禁止手动编写
- **统一代码标准**：所有代码必须通过统一的生成工具保证格式一致性
- **生成顺序**：SQL → Entity → Mapper → DTO → Service → Controller

### 开发完成后（必须做）
代码开发完成后，必须按顺序执行：
1. `/proj-review` - 代码自检，修复发现的问题
2. `/proj-gen-test` - 生成测试代码
3. 运行测试 - 确保测试通过
4. 用户确认后再提交

**注意**：以上步骤应主动执行，不需要用户提醒。

## 🚪 强制检查机制（门禁）

### 开发门禁规则

| 门禁类型 | 检查条件 | 处理方式 |
|----------|----------|----------|
| **文档门禁** | 缺少全流程任务文档或上下文快照 | 只能补文档，禁止进入下一阶段 |
| **确认门禁** | 需求/方案未确认 | 禁止进入下一阶段 |
| **产物门禁** | 产物清单未记录对应输出 | 禁止进入下一阶段 |
| **模板门禁** | 未使用模板或 `/proj-gen` | 禁止生成代码 |
| **提交门禁** | 未完成审查和测试 | 禁止提交 |

## 🧪 测试规范

### 测试覆盖要求

| 层级 | 覆盖要求 |
|------|----------|
| Service | 核心业务逻辑 100% |
| Controller | 主要接口 80% |
| Utils | 工具方法 100% |

## 📚 文档管理

### 文档命名规范

**格式**：`{YYYYMMDD}_{中文模块名}_{类型}.md`

**类型后缀**：
- 需求文档：`_需求`
- 技术方案：`_技术`
- 任务文档：`_任务`

**示例**：
- `docs/req/20260117_建议反馈_需求.md`
- `docs/design/20260117_建议反馈_技术.md`
- `docs/task/20260117_建议反馈_任务.md`

## 🔧 使用示例

### 开发新功能

```bash
# 1. 开始需求分析
/proj-analyze-req
# 输入：用户需求描述
# 输出：需求分析文档

# 2. 设计技术方案
/proj-analyze-design
# 输入：确认的需求
# 输出：技术方案文档

# 3. 拆分开发任务
/proj-task
# 输入：技术方案
# 输出：任务清单

# 4. 生成代码骨架
/proj-gen
# 输入：技术方案
# 输出：Entity、Service、Controller 等

# 5. 开发业务逻辑
# 手动编写具体业务代码

# 6. 代码自检
/proj-review
# 输入：完成的代码
# 输出：审查报告和修复建议

# 7. 生成测试代码
/proj-gen-test
# 输入：业务代码
# 输出：单元测试和集成测试
```

### 处理需求变更

```bash
# 1. 记录需求变更
/proj-change
# 输入：变更内容
# 输出：影响分析和变更计划

# 2. 修改代码
# 根据变更计划修改相关代码

# 3. 重新审查
/proj-review

# 4. 更新测试
/proj-gen-test
```

### 恢复中断的开发

```bash
# 1. 恢复开发进度
/proj-resume
# 输入：无需输入
# 输出：当前开发状态和下一步指令

# 2. 继续开发
# 根据恢复信息继续完成当前任务

# 3. 更新任务状态
# 完成任务后及时更新状态标记
```

## 🤝 贡献指南

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙋‍♂️ 支持

如有问题或建议，请：

1. 查看 [CLAUDE.md](CLAUDE.md) 了解详细规范
2. 提交 [Issue](https://github.com/your-username/project-standards/issues)
3. 参与 [Discussions](https://github.com/your-username/project-standards/discussions)

---

**让开发更标准，让质量更可靠！** 🚀