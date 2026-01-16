## Constants 全局常量

```java
package com.{company}.{project}.common.constant;

/**
 * 全局常量
 */
public class Constants {

    // ========== 缓存时间（秒） ==========
    public static final long CACHE_1_MINUTE = 60;
    public static final long CACHE_5_MINUTES = 300;
    public static final long CACHE_30_MINUTES = 1800;
    public static final long CACHE_1_HOUR = 3600;
    public static final long CACHE_1_DAY = 86400;

    // ========== 分页 ==========
    public static final int DEFAULT_PAGE_NO = 1;
    public static final int DEFAULT_PAGE_SIZE = 10;
    public static final int MAX_PAGE_SIZE = 100;

    // ========== 状态 ==========
    public static final int STATUS_DISABLE = 0;
    public static final int STATUS_ENABLE = 1;

    // ========== 删除标记 ==========
    public static final int DEL_FLAG_NORMAL = 0;
    public static final int DEL_FLAG_DELETED = 1;
}
```

---

## 