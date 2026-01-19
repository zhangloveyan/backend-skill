# 请求规范

## 请求头

| Header | 说明 | 必填 | 示例 |
|--------|------|------|------|
| Content-Type | 内容类型 | 是 | `application/json` |
| Authorization | 认证令牌 | 是* | `Bearer {token}` |
| X-Request-Id | 请求追踪ID | 否 | `uuid` |
| X-Client-Version | 客户端版本 | 否 | `1.0.0` |
| X-Platform | 平台标识 | 否 | `ios`, `android`, `web` |

> *Authorization 在需要登录的接口中必填

---

## 查询参数（GET 请求）

### 分页参数

```
GET /toy/web/v1/user?pageNo=1&pageSize=10
```

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| pageNo | int | 1 | 页码，从 1 开始 |
| pageSize | int | 10 | 每页数量，最大 100 |

### 筛选参数

```
GET /toy/web/v1/user?status=1&keyword=张三
```

### 排序参数

```
GET /toy/web/v1/user?sortField=createTime&sortOrder=desc
```

| 参数 | 说明 | 可选值 |
|------|------|--------|
| sortField | 排序字段 | 字段名 |
| sortOrder | 排序方向 | `asc`, `desc` |

### 时间范围

```
GET /toy/web/v1/order?startTime=2024-01-01&endTime=2024-12-31
```

---

## 请求体（POST/PUT 请求）

### 创建请求

```json
POST /toy/web/v1/user
Content-Type: application/json

{
    "username": "zhangsan",
    "phone": "13800138000",
    "email": "zhangsan@example.com",
    "status": 1
}
```

### 更新请求

```json
PUT /toy/web/v1/user/123
Content-Type: application/json

{
    "username": "zhangsan_new",
    "phone": "13800138001"
}
```

### 批量操作

```json
POST /toy/web/v1/user/batch-delete
Content-Type: application/json

{
    "ids": [1, 2, 3, 4, 5]
}
```

---

## 注意事项

1. **Content-Type** - POST/PUT 请求必须设置为 `application/json`
2. **Token 传递** - 放在 Authorization 头，格式 `Bearer {token}`
3. **分页限制** - pageSize 最大 100，防止一次查询过多数据
4. **时间格式** - 统一使用 `yyyy-MM-dd` 或 `yyyy-MM-dd HH:mm:ss`
