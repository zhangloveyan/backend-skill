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

### Entity 实体类

```java
@Data
@TableName("{table_name}")
@Schema(description = "{description}")
public class {Entity} implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    // 业务字段

    // 通用字段
    private String createBy;
    @TableField(fill = FieldFill.INSERT)
    private Date createTime;
    private String updateBy;
    @TableField(fill = FieldFill.UPDATE)
    private Date updateTime;
    @TableLogic
    private Integer delFlag;
}
```

### Controller (Web端) - RESTful风格

```java
@Tag(name = "{description}管理")
@RestController
@RequestMapping("/{project}/web/v1/{module}")
@RequiredArgsConstructor
public class {Entity}Controller {

    private final {Entity}Service {entity}Service;

    @Operation(summary = "列表/分页查询")
    @GetMapping
    public R<IPage<{Entity}Response>> list({Entity}QueryRequest request) {
        return R.success({entity}Service.pageQuery(request));
    }

    @Operation(summary = "获取详情")
    @GetMapping("/{id}")
    public R<{Entity}Response> detail(@PathVariable Long id) {
        return R.success({entity}Service.getDetail(id));
    }

    @ApiLog("创建{description}")
    @Operation(summary = "创建")
    @PostMapping
    public R<Long> create(@RequestBody @Validated {Entity}CreateRequest request) {
        return R.success({entity}Service.create(request));
    }

    @ApiLog("更新{description}")
    @Operation(summary = "更新")
    @PutMapping("/{id}")
    public R<Void> update(@PathVariable Long id, @RequestBody @Validated {Entity}UpdateRequest request) {
        {entity}Service.update(id, request);
        return R.success();
    }

    @ApiLog("删除{description}")
    @Operation(summary = "删除")
    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable Long id) {
        {entity}Service.deleteById(id);
        return R.success();
    }
}
```

### Controller (App端) - RESTful风格

```java
@Tag(name = "{description}")
@RestController
@RequestMapping("/{project}/api/v1/{module}")
@RequiredArgsConstructor
public class {Entity}AppController {

    private final {Entity}Service {entity}Service;

    @Operation(summary = "列表查询")
    @GetMapping
    public R<List<{Entity}Response>> list({Entity}QueryRequest request) {
        return R.success({entity}Service.list(request));
    }

    @Operation(summary = "获取详情")
    @GetMapping("/{id}")
    public R<{Entity}Response> detail(@PathVariable Long id) {
        return R.success({entity}Service.getDetail(id));
    }
}
```

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
