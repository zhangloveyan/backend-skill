# 项目开发规范

> 本文件定义项目核心规范、开发流程和 Skill 使用指南。

## 文档版本

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2025-01-15 | 初始版本 |

---

## 1. 项目信息

```yaml
项目名称: {project-name}
基础包名: com.{company}.{project}
```

如果已有项目开发，则通过读取目录文件确定 project-name、company、project 等信息。

如果是新项目，则需要用户输入 project-name、company、project 等信息。

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
├── service/impl/        # 服务层
├── mapper/              # 数据访问
├── entity/              # 实体类
├── model/request/       # 请求DTO
├── model/response/      # 响应DTO
└── enums/               # 枚举类
```

---

## 2. 命名规范

### 2.1 Java 命名

| 类型 | 规则 | 示例 |
|------|------|------|
| 类名 | 大驼峰 | `UserService` |
| 方法名 | 小驼峰 | `getUserById` |
| 变量名 | 小驼峰 | `userId` |
| 常量名 | 大写下划线 | `MAX_PAGE_SIZE` |

### 2.2 类命名约定

| 类型 | 格式 |
|------|------|
| 实体类 | `{Entity}` |
| Mapper | `{Entity}Mapper` |
| Service | `{Entity}Service` / `{Entity}ServiceImpl` |
| Controller | `{Entity}Controller` |
| 请求DTO | `{Entity}CreateRequest` / `{Entity}UpdateRequest` / `{Entity}QueryRequest` |
| 响应DTO | `{Entity}Response` |

### 2.3 数据库命名

| 类型 | 规则 | 示例 |
|------|------|------|
| 表名 | 小写下划线，单数 | `user`, `order_item` |
| 字段名 | 小写下划线 | `user_id`, `create_time` |
| 主键 | `id` | `id BIGINT` |
| 外键 | `{关联表}_id` | `user_id` |
| 索引 | `idx_{表名}_{字段}` | `idx_user_phone` |

### 2.4 通用字段

每张业务表必须包含：`id`, `create_by`, `create_time`, `update_by`, `update_time`, `del_flag`

---

## 3. 接口规范

> 详细规范见 `/gen-api` 的 reference.md

### 3.1 URL 格式

```
/{项目}/{端类型}/v{版本}/{模块}/{资源}
```

端类型：`web`(管理后台) | `api`(App) | `open`(开放) | `callback`(回调) | `internal`(内部)

### 3.2 RESTful CRUD

| 操作 | 方法 | 路径 |
|------|------|------|
| 列表/分页 | GET | `/{module}` |
| 详情 | GET | `/{module}/{id}` |
| 创建 | POST | `/{module}` |
| 更新 | PUT | `/{module}/{id}` |
| 删除 | DELETE | `/{module}/{id}` |

### 3.3 响应格式

```json
{"code": 0, "message": "成功", "data": {}, "timestamp": 1704067200000}
```

错误码：`0`成功 | `10000-19999`认证 | `20000+`业务模块 | `90000-99999`系统

---

## 4. 开发流程

### 4.1 完整流程

```
需求输入 → 需求分析 → 需求澄清 → 方案设计 → 方案确认
    ↓
任务拆分 → 代码开发 → 自检 → 代码审查 → 完成
```

### 4.2 需求规模判断

| 规模 | 特征 | 流程 |
|------|------|------|
| 简单 | 改字段、加接口、修Bug | 直接开发 |
| 中等 | 新模块、新功能 | 简化流程 |
| 复杂 | 跨模块、架构调整 | 完整流程 |

注：不管规模程度，最终都需要用户确认后开发，禁止不确认直接开发。

---

## 5. 禁止事项

### 5.1 安全红线

- 禁止明文存储密码（必须使用 BCrypt）
- 禁止日志打印敏感信息（密码、手机号、身份证、银行卡）
- 禁止 SQL 字符串拼接（必须使用参数化查询 `#{}`）
- 禁止信任前端传入的用户ID（必须从 Token 获取）
- 禁止未校验的用户输入直接入库（必须使用 @Validated）

### 5.2 性能红线

- 禁止循环内查询数据库（N+1 问题，必须批量查询或 JOIN）
- 禁止深度分页（offset > 10000，必须使用游标分页）
- 禁止不带条件的全表查询
- 禁止单次查询超过 1000 条不分批处理

### 5.3 代码禁忌

- 禁止在循环中打印日志
- 禁止使用 `System.out.println`
- 禁止捕获异常后不处理（空 catch）
- 禁止硬编码魔法值（必须使用常量或枚举）
- 禁止方法超过 50 行不拆分
- 禁止类超过 500 行不拆分

### 5.4 Git 禁忌

- 禁止提交敏感文件（.env、密钥、credentials）
- 禁止直接 push 到 master/main
- 禁止 `--force` 推送

---

## 6. 日志规范

```java
log.info("[类名.方法名] 操作描述, 参数={}", value);
```

| 级别 | 场景 |
|------|------|
| ERROR | 系统错误、影响业务的异常 |
| WARN | 潜在问题、可恢复异常 |
| INFO | 关键业务流程、重要操作 |
| DEBUG | 调试信息 |

---

## 7. Git 提交规范

```
<type>: <subject>
```

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

## 8. Skill 索引

### 8.1 快速决策

```
新功能开发？     → /analyze      需求变更？       → /change
继续开发？       → /resume       修Bug？          → /fix
查看任务？       → /task         代码审查？       → /review
生成SQL？        → /gen-sql      代码重构？       → /refactor
生成CRUD？       → /gen-crud     部署？           → /deploy
加接口？         → /gen-api      查看公共类？     → /common
加枚举？         → /gen-enum
生成测试？       → /gen-test
```

### 8.2 调用顺序

**新模块开发：** `/analyze` → `/task` → `/gen-sql` → `/gen-crud` → `/gen-test` → `/review`

**新增接口：** `/analyze`(简化) → `/gen-api` → `/review`
