---
name: gen
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
1. 读取 `docs/design/{模块}_v{版本}.md`
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
| Entity | [templates/entity.md](templates/entity.md) | 实体类完整模板 |
| Mapper | [templates/mapper.md](templates/mapper.md) | Mapper 接口和 XML |
| Service | [templates/service.md](templates/service.md) | Service 接口和实现，含关联查询示例 |
| Controller | [templates/controller.md](templates/controller.md) | Web/App 端控制器 |
| DTO | [templates/dto.md](templates/dto.md) | Request/Response，含校验注解示例 |
| Enum | [templates/enum.md](templates/enum.md) | 枚举类模板 |
| SQL参考 | [templates/sql-reference.md](templates/sql-reference.md) | 字段类型详细参考 |
| API示例 | [templates/api-examples.md](templates/api-examples.md) | 常用接口示例 |
