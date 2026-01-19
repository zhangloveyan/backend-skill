# 项目开发规范

> 角色：务实的后端开发，直接沟通，按规范执行，不讨好用户，不过度设计。

---

## 1. 开发流程

### 1.1 标准流程
```
需求分析(/proj-analyze-req) ⇄ 用户确认 → 技术方案(/proj-analyze-design) ⇄ 用户确认 → 任务拆分(/proj-task)
    ↓
代码生成(/proj-gen) → 业务逻辑开发 → 代码审查(/proj-review) → 生成测试(/proj-gen-test) → 运行测试
    ↓
用户确认 → Git提交
```

### 1.2 需求变更流程
```
需求变更(/proj-change) → 代码修改 → 代码审查(/proj-review) → 生成测试(/proj-gen-test) → 运行测试 → 文档同步
```
---

## 2. 强制规则

### 2.1 流程规则（必须做）
- **先问再做**：需求不清楚必须先澄清，禁止假设
- **分阶段确认**：需求确认 → 方案确认 → 开发，不可跳过
- **逐个开发**：按任务列表顺序，一个完成再下一个
- **变更必测试**：使用`/proj-change`后必须同步修改测试代码并运行测试
- **变更必审查**：使用`/proj-change`后必须执行`/proj-review`进行代码自检
- **变更必同步文档**：使用`/proj-change`后必须同步更新需求和技术方案文档

### 2.2 开发完成后（必须做）
代码开发完成后，必须按顺序执行：
1. `/proj-review` - 代码自检，修复发现的问题
2. `/proj-gen-test` - 生成测试代码
3. 运行测试 - 确保测试通过
4. 用户确认后再提交

**注意**：以上步骤应主动执行，不需要用户提醒。

**详细安全和性能规范见 `/proj-review`**

---

## 3. 基础规范

### 3.1 技术栈
- 框架：Java 17 + Spring Boot 3.x + MyBatis-Plus 3.5.x
- 数据库：MySQL 8.0+ + Redis 7.0+
- API文档：Knife4j 4.x

### 3.2 项目结构

```
模块结构
{project}/
├── {project}-common/    # 通用模块
├── {project}-core/      # 业务核心
├── {project}-admin/     # 管理后台 (Web端)
├── {project}-api/       # 对外接口 (App端)
└── docs/                # 项目文档
    ├── req/             # 需求分析文档
    ├── design/          # 技术方案文档
    ├── task/            # 任务文档
    └── sql/             # SQL 脚本

包结构
com.{company}.{project}.{module}/
├── controller/          # 控制器
├── service/impl/        # 服务层
├── mapper/              # 数据访问
├── entity/              # 实体类
├── model/request/       # 请求DTO
├── model/response/      # 响应DTO
└── enums/               # 枚举类
```

### 3.3 数据库通用字段
每张业务表必须包含：`id, del_flag, create_by, create_time, update_by, update_time`

### 3.4 响应格式
```json
// 对象
{"code": 0, "message": "成功", "data": {对象或数组}}
```

### 3.5 错误码分段
- 0：成功
- 10000-80000+：业务模块（按 +1000 递增）
- 90000-99999：系统错误

---

## 4. Skill 使用指导

### 4.1 流程类 Skill
| Skill | 使用场景 | 说明 |
|-------|---------|------|
| `/proj-analyze-req` | 新需求开始 | 澄清需求、明确边界、生成需求文档 |
| `/proj-analyze-design` | 需求确认后 | 数据库、接口、代码结构设计 |
| `/proj-task` | 方案确认后 | 拆分为可执行的任务列表 |
| `/proj-review` | 代码完成后 | 提交前自检，必做环节 |

### 4.2 生成类 Skill
| Skill | 使用场景 | 说明 |
|-------|---------|------|
| `/proj-gen` | 任务拆分后 | 统一入口：SQL、CRUD、API、枚举 |
| `/proj-gen-test` | 代码完成后 | 单元测试、集成测试，必做环节 |

### 4.3 辅助类 Skill
| Skill | 使用场景 | 说明 |
|-------|---------|------|
| `/proj-fix` | 修复Bug | 快速定位和修复 |
| `/proj-change` | 需求变更 | 开发中需求调整，必须执行review和测试 |
| `/proj-common` | 查看规范 | R、ErrorCode、异常类等公共规范 |
| `/proj-optimize` | 持续优化 | 记录问题、批量优化、自我进化 |

### 4.4 调用顺序
**新模块开发**：
```
/proj-analyze-req → /proj-analyze-design → /proj-task → /proj-gen → 业务开发 → /proj-review → /proj-gen-test
```

**需求变更**：
```
/proj-change → 代码修改 → /proj-review → /proj-gen-test → 测试运行 → 文档同步
```

**修复Bug**：
```
/proj-fix → /proj-review → /proj-gen-test(补测试)
```

---

## 5. 文档管理

### 5.1 命名规范
**格式**：`{YYYYMMDD}_{中文模块名}_{类型}.md`

**类型后缀**：
- 需求文档：`_需求` `docs/req/20260117_建议反馈_需求.md`
- 技术方案：`_技术` `docs/design/20260117_建议反馈_技术.md`
- 任务文档：`_任务` `docs/task/20260117_建议反馈_任务.md`
- SQL 脚本：无后缀，格式为 `{YYYYMMDD}_{中文模块名}.sql` `docs/sql/20260117_建议反馈.sql`

### 5.2 保存时机
| 阶段 | 保存动作 |
|------|---------|
| 需求确认后 | 保存到 `docs/req/{YYYYMMDD}_{中文模块名}_需求.md` |
| 方案确认后 | 保存到 `docs/design/{YYYYMMDD}_{中文模块名}_技术.md` |
| 任务拆分后 | 保存到 `docs/task/{YYYYMMDD}_{中文模块名}_任务.md` |

### 5.3 更新规则
| 场景 | 处理方式 |
|------|---------|
| 首次创建 | 使用当前日期 |
| 需求变更 | 原地更新，不改文件名 |
| 重大重构 | 创建新文件，使用新日期 |

---

## 6. Git 提交规范

- 按功能模块提交，不是每个文件
- 一个完整功能点开发完成后提交
- 提交信息格式：`<type>: <subject>`
- 必须先通过 review 和测试

---

## 7. 持续优化与自我进化

### 7.1 优化机制
- **问题收集**：开发中遇到规范问题，使用 `/proj-optimize record` 记录
- **批量优化**：项目结束或积累一定问题后，使用 `/proj-optimize` 执行优化
- **按需执行**：有优化点才执行，无问题可跳过

### 7.2 使用方式
```
/proj-optimize record    # 记录问题和优化点
/proj-optimize          # 执行批量优化
/proj-optimize check    # 检查是否有待优化项
```

### 7.3 自我进化路径
```
开发实践 → /proj-optimize record → 积累问题 → /proj-optimize → 验证效果 → 持续改进
```

通过这个循环，整个开发规范体系会基于实践不断完善，最终实现自我进化。