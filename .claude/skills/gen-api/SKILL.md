---
name: gen-api
description: 在已有模块中添加单个接口。用于已有模块需要新增接口、不需要完整CRUD只加特定功能。
---

# 生成单个接口

## 输入参数

| 参数 | 必填 | 说明 | 示例 |
|------|------|------|------|
| 模块名 | 是 | 已有模块 | `user` |
| 端类型 | 是 | Web/App/Open | `Web` |
| HTTP方法 | 是 | GET/POST/PUT/DELETE | `POST` |
| 路径 | 是 | 接口路径 | `/export` |
| 功能描述 | 是 | 中文描述 | `导出用户` |

---

## RESTful 风格路径

> 参考 CLAUDE.md「接口规范」章节

```
/{project}/{端类型}/v1/{module}/{resource}
```

| 操作 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 列表/分页 | GET | `/` | 根路径 |
| 详情 | GET | `/{id}` | 资源ID |
| 创建 | POST | `/` | 根路径 |
| 更新 | PUT | `/{id}` | 资源ID |
| 删除 | DELETE | `/{id}` | 资源ID |
| 批量删除 | POST | `/batch-delete` | 特殊操作 |
| 导出 | GET | `/export` | 特殊操作 |
| 状态变更 | PUT | `/{id}/status` | 子资源操作 |

---

## 常用接口模板

### 批量删除

```java
@ApiLog("批量删除{description}")
@Operation(summary = "批量删除")
@PostMapping("/batch-delete")
public R<Void> batchDelete(@RequestBody List<Long> ids) {
    {entity}Service.batchDelete(ids);
    return R.success();
}
```

### 状态变更

```java
@ApiLog("更新{description}状态")
@Operation(summary = "更新状态")
@PutMapping("/{id}/status")
public R<Void> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
    {entity}Service.updateStatus(id, status);
    return R.success();
}
```

### 导出

```java
@ApiLog("导出{description}")
@Operation(summary = "导出")
@GetMapping("/export")
public void export({Entity}QueryRequest request, HttpServletResponse response) {
    {entity}Service.export(request, response);
}
```

### 统计查询

```java
@Operation(summary = "统计数据")
@GetMapping("/stats")
public R<{Entity}StatsResponse> stats() {
    return R.success({entity}Service.getStats());
}
```

---

## 自检清单

- [ ] 接口路径符合 RESTful 规范
- [ ] HTTP 方法正确
- [ ] Service 方法有日志
- [ ] 写操作有 `@ApiLog`
- [ ] 参数校验完整

---

## 注意事项

1. **复用现有 DTO** - 能用现有的就不新建
2. **方法命名** - 动词开头，见名知意
3. **事务控制** - 多表操作加 `@Transactional`
