# Controller 模板

## Web端 Controller (管理后台)

```java
package com.{company}.{project}.admin.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.{company}.{project}.common.annotation.ApiLog;
import com.{company}.{project}.common.core.R;
import com.{company}.{project}.{module}.model.request.*;
import com.{company}.{project}.{module}.model.response.{Entity}Response;
import com.{company}.{project}.{module}.service.{Entity}Service;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * {description}管理
 *
 * @author {author}
 * @since {date}
 */
@Slf4j
@Tag(name = "{description}管理")
@RestController
@RequestMapping("/{project}/web/v1/{module}")
@RequiredArgsConstructor
public class {Entity}Controller {

    private final {Entity}Service {entity}Service;

    @Operation(summary = "分页查询{description}")
    @GetMapping
    public R<IPage<{Entity}Response>> page({Entity}QueryRequest request) {
        return R.success({entity}Service.pageQuery(request));
    }

    @Operation(summary = "获取{description}详情")
    @GetMapping("/{id}")
    public R<{Entity}Response> detail(
            @Parameter(description = "ID") @PathVariable Long id) {
        return R.success({entity}Service.getDetail(id));
    }

    @ApiLog("创建{description}")
    @Operation(summary = "创建{description}")
    @PostMapping
    public R<Long> create(@RequestBody @Validated {Entity}CreateRequest request) {
        return R.success({entity}Service.create(request));
    }

    @ApiLog("更新{description}")
    @Operation(summary = "更新{description}")
    @PutMapping("/{id}")
    public R<Void> update(
            @Parameter(description = "ID") @PathVariable Long id,
            @RequestBody @Validated {Entity}UpdateRequest request) {
        {entity}Service.update(id, request);
        return R.success();
    }

    @ApiLog("删除{description}")
    @Operation(summary = "删除{description}")
    @DeleteMapping("/{id}")
    public R<Void> delete(@Parameter(description = "ID") @PathVariable Long id) {
        {entity}Service.deleteById(id);
        return R.success();
    }

    @ApiLog("批量删除{description}")
    @Operation(summary = "批量删除{description}")
    @PostMapping("/batch-delete")
    public R<Void> batchDelete(@RequestBody List<Long> ids) {
        {entity}Service.removeByIds(ids);
        return R.success();
    }
}
```

---

## App端 Controller (移动端)

```java
package com.{company}.{project}.api.controller;

import com.{company}.{project}.common.core.R;
import com.{company}.{project}.{module}.model.request.*;
import com.{company}.{project}.{module}.model.response.{Entity}Response;
import com.{company}.{project}.{module}.service.{Entity}Service;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * {description}
 *
 * @author {author}
 * @since {date}
 */
@Slf4j
@Tag(name = "{description}")
@RestController
@RequestMapping("/{project}/api/v1/{module}")
@RequiredArgsConstructor
public class {Entity}AppController {

    private final {Entity}Service {entity}Service;

    @Operation(summary = "获取{description}列表")
    @GetMapping
    public R<List<{Entity}Response>> list({Entity}QueryRequest request) {
        return R.success({entity}Service.list(request));
    }

    @Operation(summary = "获取{description}详情")
    @GetMapping("/{id}")
    public R<{Entity}Response> detail(
            @Parameter(description = "ID") @PathVariable Long id) {
        return R.success({entity}Service.getDetail(id));
    }
}
```

---

## 注意事项

1. **路径规范** - URL 遵循 `/{project}/{端类型}/v{版本}/{module}` 格式
2. **日志注解** - 写操作（创建、更新、删除）必须添加 `@ApiLog`
3. **参数校验** - 请求体使用 `@Validated` 触发校验
4. **响应包装** - 统一使用 `R` 类包装响应
5. **端类型区分**
   - Web端：完整 CRUD，包含批量操作
   - App端：通常只有查询接口，写操作按需添加
