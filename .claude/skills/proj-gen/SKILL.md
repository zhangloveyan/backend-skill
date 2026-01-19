---
name: proj-gen
description: 代码生成统一入口。生成 SQL、CRUD、API、枚举等代码。
---

# 代码生成

> 统一入口，根据参数生成不同类型的代码。

## 使用方式

```
/gen sql      - 生成建表 SQL
/gen crud     - 生成完整 CRUD 代码
/gen api      - 生成单个接口
/gen enum     - 生成枚举类
/gen          - 自动模式（读取技术方案文档）
```

---

## 自动模式

当存在技术方案文档时，直接执行 `/gen`，自动：
1. 读取 `docs/design/{YYYYMMDD}_{中文模块名}.md`
2. 提取表结构、实体、接口等信息
3. 按顺序生成：SQL → Entity → Mapper → Service → Controller → DTO

**触发时机**：任务拆分完成后，开始编码前。

**注意**：自动模式生成的是代码骨架，业务逻辑仍需手动实现。

---

## 1. 生成 SQL (`/gen sql`)

### 输入参数

| 参数 | 必填 | 说明 | 示例 |
|------|------|------|------|
| 表名 | 是 | 小写下划线 | `feedback` |
| 表描述 | 是 | 中文 | `建议反馈` |
| 业务字段 | 是 | 字段列表 | |

### 字段类型、通用字段与建表模板

参考 [SQL 字段类型参考](templates/sql-reference.md)

---

## 2. 生成 CRUD (`/gen crud`)

### 输入参数

| 参数 | 必填 | 说明 | 示例 |
|------|------|------|------|
| 模块名 | 是 | 小写 | `feedback` |
| 实体名 | 是 | 大驼峰 | `Feedback` |
| 表名 | 是 | 小写下划线 | `feedback` |
| 中文描述 | 是 | | `建议反馈` |
| 端类型 | 是 | Web/App/Both | |

### 生成文件清单

```
core/{module}/
├── entity/{Entity}.java
├── mapper/{Entity}Mapper.java
├── service/{Entity}Service.java
└── service/impl/{Entity}ServiceImpl.java

admin/  (Web端)
├── controller/{Entity}Controller.java
├── service/{Entity}ManageService.java
├── service/impl/{Entity}ManageServiceImpl.java
└── model/
    ├── request/{Entity}CreateRequest.java
    ├── request/{Entity}UpdateRequest.java
    ├── request/{Entity}QueryRequest.java
    └── response/{Entity}Response.java

api/  (App端)
├── controller/{Entity}Controller.java
├── service/{Entity}AppService.java
└── model/...
```

### 代码模板

- [Entity 模板](templates/entity.md)
- [Mapper 模板](templates/mapper.md)
- [Service 模板](templates/service.md)
- [Controller 模板](templates/controller.md)
- [DTO 模板](templates/dto.md)

---

## 3. 生成 API (`/gen api`)

### 输入参数

| 参数 | 必填 | 说明 | 示例 |
|------|------|------|------|
| 模块名 | 是 | 已有模块 | `user` |
| 端类型 | 是 | Web/App | `Web` |
| HTTP方法 | 是 | GET/POST/PUT/DELETE | `POST` |
| 路径 | 是 | 接口路径 | `/export` |
| 功能描述 | 是 | 中文 | `导出用户` |

### 常用接口模板

参考 [API 接口示例](templates/api-examples.md)

---

## 4. 生成枚举 (`/gen enum`)

### 输入参数

| 参数 | 必填 | 说明 | 示例 |
|------|------|------|------|
| 枚举名 | 是 | 大驼峰 | `FeedbackStatus` |
| 模块名 | 是 | 所属模块 | `feedback` |
| 描述 | 是 | 中文 | `反馈状态` |
| 枚举值 | 是 | code-desc | `0-待处理, 1-已处理` |

### 枚举模板

参考 [枚举模板](templates/enum.md)

---

## 自检清单

- [ ] 命名符合规范（参考 CLAUDE.md）
- [ ] 通用字段完整
- [ ] 必填字段有校验注解
- [ ] 写操作有 `@ApiLog`
- [ ] 接口路径符合 RESTful
- [ ] 每个字段有注释/Schema

---

## 详细模板文件

> 以下模板包含完整代码示例和注意事项：

| 模板 | 文件 | 说明 |
|------|------|------|
| SQL 建表 | [sql-reference.md](templates/sql-reference.md) | 字段类型、索引规范 |
| Entity 实体 | [entity.md](templates/entity.md) | 实体类模板 |
| Mapper 接口 | [mapper.md](templates/mapper.md) | 数据访问层 |
| Service 服务 | [service.md](templates/service.md) | 业务逻辑层 |
| Controller 控制器 | [controller.md](templates/controller.md) | 接口层 |
| DTO 传输对象 | [dto.md](templates/dto.md) | 请求响应对象 |
| 枚举类 | [enum.md](templates/enum.md) | 枚举定义 |

---

## 命名规范详细说明

### 基础命名规则

| 类型 | 规则 | 示例 |
|------|------|------|
| 类名 | 大驼峰 | `UserService` |
| 方法/变量 | 小驼峰 | `getUserById` |
| 常量 | 大写下划线 | `MAX_PAGE_SIZE` |
| 表名 | 小写下划线，单数 | `user`, `order_item` |
| 字段名 | 小写下划线 | `user_id`, `create_time` |

### 类命名约定

| 类型 | 格式 | 示例 |
|------|------|------|
| 实体类 | `{Entity}` | `User`, `FeedbackType` |
| Mapper | `{Entity}Mapper` | `UserMapper` |
| Service 接口 | `{Entity}Service` | `UserService` |
| Service 实现 | `{Entity}ServiceImpl` | `UserServiceImpl` |
| Controller | `{Entity}Controller` | `UserController` |
| 请求DTO | `{Entity}CreateRequest` / `{Entity}UpdateRequest` | `UserCreateRequest` |
| 响应DTO | `{Entity}Response` | `UserResponse` |
| 枚举类 | `{业务}Status` / `{业务}Type` | `FeedbackStatus` |

---

## 接口规范详细说明

### URL 格式规范

**标准格式**：`/{项目}/{端类型}/v{版本}/{模块}/{资源}`

**端类型说明**：
- `web` - 管理后台
- `api` - App端/小程序
- `open` - 开放接口

**示例**：
- `/toy/api/v1/feedback` - 小程序反馈接口
- `/toy/web/v1/user` - 管理后台用户接口

### RESTful 路径规范

| 操作 | HTTP方法 | 路径格式 | 示例 |
|------|----------|----------|------|
| 列表查询 | GET | `/{module}` | `GET /toy/api/v1/feedback` |
| 详情查询 | GET | `/{module}/{id}` | `GET /toy/api/v1/feedback/123` |
| 创建 | POST | `/{module}` | `POST /toy/api/v1/feedback` |
| 更新 | PUT | `/{module}/{id}` | `PUT /toy/api/v1/feedback/123` |
| 删除 | DELETE | `/{module}/{id}` | `DELETE /toy/api/v1/feedback/123` |

### 响应格式规范

**统一响应格式**：
```json
{
  "code": 0,
  "message": "成功",
  "data": {}
}
```

**分页响应格式**：
```json
{
  "code": 0,
  "message": "成功",
  "data": {
    "records": [],
    "total": 100,
    "current": 1,
    "size": 20
  }
}
```
| Entity | [templates/entity.md](templates/entity.md) | 实体类完整模板 |
| Mapper | [templates/mapper.md](templates/mapper.md) | Mapper 接口和 XML |
| Service | [templates/service.md](templates/service.md) | Service 接口和实现，含关联查询示例 |
| Controller | [templates/controller.md](templates/controller.md) | Web/App 端控制器 |
| DTO | [templates/dto.md](templates/dto.md) | Request/Response，含校验注解示例 |
| Enum | [templates/enum.md](templates/enum.md) | 枚举类模板 |
| SQL参考 | [templates/sql-reference.md](templates/sql-reference.md) | 字段类型详细参考 |
| API示例 | [templates/api-examples.md](templates/api-examples.md) | 常用接口示例 |
