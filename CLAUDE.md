# 项目开发规范

> 本文件定义项目核心规范、开发流程和 Skill 使用指南。

## 1. 项目信息

```yaml
项目名称: {project-name}
基础包名: com.{company}.{project}
```

### 1.1 技术栈

| 类别 | 技术 | 版本 |
|------|------|------|
| JDK | OpenJDK / Temurin | 17+ |
| 框架 | Spring Boot | 3.x |
| ORM | MyBatis-Plus | 3.5.x |
| 数据库 | MySQL | 8.0+ |
| 缓存 | Redis | 7.0+ |
| API文档 | Knife4j | 4.x |

### 1.2 模块结构

```
{project}/
├── {project}-common/    # 通用模块
├── {project}-core/      # 业务核心
├── {project}-admin/     # 管理后台 (Web端)
└── {project}-api/       # 对外接口 (App端)
```

### 1.3 包结构

```
com.{company}.{project}.{module}/
├── controller/          # 控制器
├── service/             # 服务接口
│   └── impl/            # 服务实现
├── mapper/              # 数据访问
├── entity/              # 实体类
├── model/
│   ├── request/         # 请求DTO
│   └── response/        # 响应DTO
└── enums/               # 枚举类
```

---

## 2. 命名规范

### 2.1 Java 命名

| 类型 | 规则 | 示例 |
|------|------|------|
| 类名 | 大驼峰 | `UserService`, `OrderController` |
| 方法名 | 小驼峰 | `getUserById`, `createOrder` |
| 变量名 | 小驼峰 | `userId`, `orderList` |
| 常量名 | 大写下划线 | `MAX_PAGE_SIZE` |
| 包名 | 小写 | `com.example.user` |

### 2.2 类命名约定

| 类型 | 格式 | 示例 |
|------|------|------|
| 实体类 | `{Entity}` | `User` |
| Mapper | `{Entity}Mapper` | `UserMapper` |
| Service接口 | `{Entity}Service` | `UserService` |
| Service实现 | `{Entity}ServiceImpl` | `UserServiceImpl` |
| Controller | `{Entity}Controller` | `UserController` |
| 创建请求 | `{Entity}CreateRequest` | `UserCreateRequest` |
| 更新请求 | `{Entity}UpdateRequest` | `UserUpdateRequest` |
| 查询请求 | `{Entity}QueryRequest` | `UserQueryRequest` |
| 响应 | `{Entity}Response` | `UserResponse` |

### 2.3 数据库命名

| 类型 | 规则 | 示例 |
|------|------|------|
| 表名 | 小写下划线，单数 | `user`, `order_item` |
| 字段名 | 小写下划线 | `user_id`, `create_time` |
| 主键 | `id` | `id BIGINT` |
| 外键 | `{关联表}_id` | `user_id` |
| 索引 | `idx_{表名}_{字段}` | `idx_user_phone` |
| 唯一索引 | `uk_{表名}_{字段}` | `uk_user_email` |

### 2.4 通用字段

每张业务表必须包含：

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | BIGINT | 主键，自增 |
| `create_by` | VARCHAR(64) | 创建人 |
| `create_time` | DATETIME | 创建时间 |
| `update_by` | VARCHAR(64) | 更新人 |
| `update_time` | DATETIME | 更新时间 |
| `del_flag` | TINYINT(1) | 删除标记 |

---

## 3. 接口规范

### 3.1 URL 格式

```
/{项目}/{端类型}/v{版本}/{模块}/{资源}
```

### 3.2 端类型

| 端类型 | 说明 | 示例 |
|--------|------|------|
| `web` | 管理后台 | `/toy/web/v1/user` |
| `api` | App/小程序 | `/toy/api/v1/user/profile` |
| `open` | 开放接口 | `/toy/open/v1/oauth/token` |
| `callback` | 回调接口 | `/toy/callback/v1/payment/notify` |
| `internal` | 内部接口 | `/toy/internal/v1/device/command` |

### 3.3 RESTful CRUD 路径

```
GET    /{module}                # 列表/分页查询
GET    /{module}/{id}           # 详情
POST   /{module}                # 创建
PUT    /{module}/{id}           # 更新
DELETE /{module}/{id}           # 删除
POST   /{module}/batch-delete   # 批量删除
```

### 3.4 URL 命名规则

- 动作由 HTTP 方法表达，URL 不写 create/update/delete
- 资源用名词，不用动词
- 多单词用连字符分隔

### 3.5 统一响应格式

```json
{
    "code": 0,
    "message": "成功",
    "data": { },
    "timestamp": 1704067200000
}
```

### 3.5 错误码分段

| 范围 | 模块 |
|------|------|
| 0 | 成功 |
| 10000-19999 | 认证/权限 |
| 20000-29999 | 用户模块 |
| 30000-39999 | 订单模块 |
| 40000-49999 | 商品模块 |
| 50000-59999 | 支付模块 |
| 90000-99999 | 系统/通用 |

---

## 4. 开发流程

### 4.1 完整流程

```
需求输入 → 需求分析 → 需求澄清 → 方案设计 → 方案确认
    ↓
任务拆分 → 代码开发 → 自检 → 完成
```

### 4.2 流程说明

| 阶段 | 说明 | 产出 |
|------|------|------|
| 需求输入 | 用户描述需求 | - |
| 需求分析 | 识别功能点、模块、技术要点 | - |
| 需求澄清 | 不明确项与用户确认 | - |
| 方案设计 | 输出完整方案 | `docs/方案/{功能}.md` |
| 方案确认 | 用户确认方案 | - |
| 任务拆分 | 生成任务清单 | `docs/TASK.md` |
| 代码开发 | 按任务逐项开发 | 代码文件 |
| 自检 | 检查代码质量 | - |
| 完成 | 更新任务状态 | - |

### 4.3 需求规模判断

| 规模 | 特征 | 流程 |
|------|------|------|
| 简单 | 改字段、加接口、修Bug | 直接开发 |
| 中等 | 新模块、新功能 | 简化流程（可跳过方案文档） |
| 复杂 | 跨模块、架构调整 | 完整流程 |

---

## 5. Skill 使用指南

### 5.1 快速决策

```
想做新功能？     → /analyze
想继续开发？     → /resume
想加个接口？     → /gen-api
想建新表？       → /gen-sql
想生成CRUD？     → /gen-crud
想加枚举？       → /gen-enum
想部署？         → /deploy
需求有变更？     → /change
要修Bug？        → /fix
```

### 5.2 Skill 清单

| Skill | 职责 | 阶段 |
|-------|------|------|
| `/analyze` | 需求分析、澄清、方案设计 | 需求阶段 |
| `/task` | 创建/更新/查看任务 | 任务管理 |
| `/resume` | 读取任务继续开发 | 恢复开发 |
| `/gen-sql` | 生成建表SQL | 代码生成 |
| `/gen-crud` | 生成完整CRUD代码 | 代码生成 |
| `/gen-api` | 生成单个接口 | 代码生成 |
| `/gen-enum` | 生成枚举类 | 代码生成 |
| `/deploy` | Docker/Nginx配置 | 部署 |
| `/change` | 处理需求变更 | 变更管理 |
| `/fix` | Bug修复（简化流程） | 维护 |

### 5.3 调用顺序

**新模块开发：**
```
/analyze → /task → /gen-sql → /gen-crud
```

**新增接口：**
```
/analyze（简化） → /gen-api
```

**需求变更：**
```
/change → /task（更新）
```

**中断恢复：**
```
/resume → 继续开发
```

---

## 6. 禁止事项

### 6.1 安全红线

- 禁止明文存储密码
- 禁止日志打印敏感信息（密码、完整手机号、身份证、银行卡）
- 禁止 SQL 拼接（使用参数化查询）
- 禁止信任前端传入的用户ID（从Token获取）

### 6.2 代码禁忌

- 禁止在循环中打印日志
- 禁止使用 `System.out.println`
- 禁止捕获异常后不处理
- 禁止硬编码魔法值（使用常量）
- 禁止使用 `SELECT *`

### 6.3 Git 禁忌

- 禁止提交 `.env`、密钥等敏感文件
- 禁止直接 push 到 master/main
- 禁止 `--force` 推送（除非明确要求）

---

## 7. 日志规范

### 7.1 格式

```java
log.info("[类名.方法名] 操作描述, 参数1={}, 参数2={}", value1, value2);
```

### 7.2 级别

| 级别 | 场景 |
|------|------|
| ERROR | 系统错误、影响业务的异常 |
| WARN | 潜在问题、可恢复异常 |
| INFO | 关键业务流程、重要操作 |
| DEBUG | 调试信息、开发阶段 |

---

## 8. Git 提交规范

### 8.1 格式

```
<type>: <subject>
```

### 8.2 类型

| 类型 | 说明 |
|------|------|
| feat | 新功能 |
| fix | 修复Bug |
| docs | 文档变更 |
| style | 代码格式 |
| refactor | 重构 |
| test | 测试 |
| chore | 构建/工具 |

---

## 9. 文档索引

| 文档 | 路径 | 说明 |
|------|------|------|
| 开发规范 | `docs/01-开发规范.md` | 数据库/日志/注释/安全/Git |
| 接口规范 | `docs/02-接口规范.md` | URL/响应/错误码 |
| 代码模板 | `docs/03-代码模板.md` | CRUD模板 |
| 公共类规范 | `docs/04-公共类规范.md` | R/异常/工具类 |
| Docker部署 | `docs/05-Docker部署.md` | 部署配置 |
