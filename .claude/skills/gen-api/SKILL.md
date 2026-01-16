---
name: gen-api
description: 在已有模块中添加单个接口。用于已有模块需要新增接口、非标准CRUD接口（导出、统计、审批等）。
---

# 生成单个接口

## 适用场景

- 已有模块追加接口
- 非标准 CRUD 接口（导出、统计、状态变更、审批等）

---

## 输入参数

| 参数 | 必填 | 说明 | 示例 |
|------|------|------|------|
| 模块名 | 是 | 已有模块 | `user` |
| 端类型 | 是 | Web/App/Open | `Web` |
| HTTP方法 | 是 | GET/POST/PUT/DELETE | `POST` |
| 路径 | 是 | 接口路径 | `/export` |
| 功能描述 | 是 | 中文描述 | `导出用户` |

---

## 常用接口模板

### 批量删除

```java
@ApiLog("批量删除{description}")
@Operation(summary = "批量删除")
@PostMapping("/batch-delete")
public R<Void> batchDelete(@RequestBody @Validated BatchDeleteRequest request) {
    {entity}Service.batchDelete(request.getIds());
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
public R<{Entity}StatsResponse> stats({Entity}StatsRequest request) {
    return R.success({entity}Service.getStats(request));
}
```

### 审批操作

```java
@ApiLog("审批{description}")
@Operation(summary = "审批")
@PutMapping("/{id}/approve")
public R<Void> approve(@PathVariable Long id, @RequestBody @Validated ApproveRequest request) {
    {entity}Service.approve(id, request);
    return R.success();
}
```

---

## 自检清单

- [ ] 接口路径符合 RESTful 规范（参考 CLAUDE.md）
- [ ] HTTP 方法正确（查询用 GET，操作用 POST/PUT/DELETE）
- [ ] Service 方法有日志记录
- [ ] 写操作有 `@ApiLog` 注解
- [ ] 参数校验完整（使用 `@Validated`）

---

## 相关文档

- [接口示例](examples.md)
- 请求/响应规范见 `/common`

---

## 注意事项

1. **复用现有 DTO** - 能用现有的就不新建
2. **方法命名** - 动词开头，见名知意
3. **事务控制** - 多表操作加 `@Transactional`
