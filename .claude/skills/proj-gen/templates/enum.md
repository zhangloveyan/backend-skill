# 枚举模板

## 标准枚举模板

```java
@Getter
@AllArgsConstructor
public enum {EnumName} {

    {VALUE1}({code1}, "{desc1}"),
    {VALUE2}({code2}, "{desc2}"),
    ;

    @EnumValue
    private final Integer code;
    private final String desc;

    public static {EnumName} of(Integer code) {
        if (code == null) return null;
        for ({EnumName} item : values()) {
            if (item.getCode().equals(code)) return item;
        }
        return null;
    }
}
```

---

## 常用枚举示例

```java
// 状态
DISABLE(0, "禁用"), ENABLE(1, "启用")

// 是否
NO(0, "否"), YES(1, "是")

// 审核
PENDING(0, "待审核"), APPROVED(1, "已通过"), REJECTED(2, "已拒绝")
```
