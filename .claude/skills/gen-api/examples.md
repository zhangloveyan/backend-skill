# 接口示例

## Web 管理后台

```
# 标准 CRUD
GET    /toy/web/v1/user                   # 用户列表/分页
GET    /toy/web/v1/user/{id}              # 用户详情
POST   /toy/web/v1/user                   # 创建用户
PUT    /toy/web/v1/user/{id}              # 更新用户
DELETE /toy/web/v1/user/{id}              # 删除用户

# 扩展操作
POST   /toy/web/v1/user/batch-delete      # 批量删除
PUT    /toy/web/v1/user/{id}/status       # 启用/禁用
PUT    /toy/web/v1/user/{id}/reset-pwd    # 重置密码
GET    /toy/web/v1/user/export            # 导出用户
```

---

## App 移动端

```
# 个人中心
GET    /toy/api/v1/user/profile           # 获取个人信息
PUT    /toy/api/v1/user/profile           # 更新个人信息
PUT    /toy/api/v1/user/avatar            # 更新头像
PUT    /toy/api/v1/user/password          # 修改密码
PUT    /toy/api/v1/user/phone             # 绑定手机号
```

---

## 认证接口

```
# Web 端
POST   /toy/web/v1/auth/login             # 管理后台登录
POST   /toy/web/v1/auth/logout            # 退出登录
GET    /toy/web/v1/auth/info              # 获取登录信息

# App 端
POST   /toy/api/v1/auth/login/phone       # 手机号登录
POST   /toy/api/v1/auth/login/wechat      # 微信登录
POST   /toy/api/v1/auth/register          # 注册
POST   /toy/api/v1/auth/sms/send          # 发送验证码
```

---

## 开放接口

```
POST   /toy/open/v1/oauth/token           # 获取访问令牌
POST   /toy/open/v1/oauth/refresh         # 刷新令牌
GET    /toy/open/v1/user/{id}             # 获取用户信息
```

---

## 回调接口

```
POST   /toy/callback/v1/payment/notify    # 支付回调
POST   /toy/callback/v1/sms/status        # 短信状态回调
```

---

## 内部接口

```
POST   /toy/internal/v1/user/batch        # 批量查询用户
POST   /toy/internal/v1/notify/send       # 发送通知
```
