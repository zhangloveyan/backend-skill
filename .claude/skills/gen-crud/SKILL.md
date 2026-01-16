---
name: gen-crud
description: 生成完整的CRUD代码，包括Entity、Mapper、Service、DTO、Controller。用于新模块开发、需要完整的增删改查功能。
---

# 生成CRUD代码

## 输入参数

| 参数 | 必填 | 说明 | 示例 |
|------|------|------|------|
| 模块名 | 是 | 小写 | `feedback` |
| 实体名 | 是 | 大驼峰 | `Feedback` |
| 表名 | 是 | 小写下划线 | `feedback` |
| 中文描述 | 是 | | `建议反馈` |
| 业务字段 | 是 | 字段列表 | |
| 端类型 | 是 | Web/App/Both | |

---

## 生成文件清单

```
{module}/
├── entity/{Entity}.java
├── mapper/{Entity}Mapper.java
├── mapper/xml/{Entity}Mapper.xml
├── service/{Entity}Service.java
├── service/impl/{Entity}ServiceImpl.java
└── model/
    ├── request/
    │   ├── {Entity}CreateRequest.java
    │   ├── {Entity}UpdateRequest.java
    │   └── {Entity}QueryRequest.java
    └── response/
        └── {Entity}Response.java

admin/controller/{Entity}Controller.java      # Web端
api/controller/{Entity}AppController.java     # App端
```

---

## 代码模板

> 各层代码模板见同目录下的模板文件：

- [Entity 模板](entity-template.md)
- [Mapper 模板](mapper-template.md)
- [Service 模板](service-template.md)
- [DTO 模板](dto-template.md)
- [Controller 模板](controller-template.md)

---

## 自检清单

- [ ] Entity 字段与数据库表一致
- [ ] Entity 包含所有通用字段
- [ ] JSON 字段添加了 `JacksonTypeHandler`
- [ ] Mapper XML 的 namespace 正确
- [ ] Service 方法有日志记录
- [ ] DTO 必填字段有校验注解
- [ ] Controller 路径符合 RESTful 规范
- [ ] Controller 写操作有 `@ApiLog`

---

## 注意事项

1. **命名规范** - 参考 CLAUDE.md「命名规范」章节
2. **接口规范** - 参考 CLAUDE.md「接口规范」章节
3. **占位符替换** - 生成后替换 `{company}`, `{project}` 等
