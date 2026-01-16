# Service 模板

## Service 接口

```java
package com.{company}.{project}.{module}.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.{company}.{project}.{module}.entity.{Entity};
import com.{company}.{project}.{module}.model.request.*;
import com.{company}.{project}.{module}.model.response.{Entity}Response;
import java.util.List;

/**
 * {description}服务接口
 *
 * @author {author}
 * @since {date}
 */
public interface {Entity}Service extends IService<{Entity}> {

    /**
     * 创建
     */
    Long create({Entity}CreateRequest request);

    /**
     * 更新
     */
    void update(Long id, {Entity}UpdateRequest request);

    /**
     * 删除
     */
    void deleteById(Long id);

    /**
     * 获取详情
     */
    {Entity}Response getDetail(Long id);

    /**
     * 列表查询
     */
    List<{Entity}Response> list({Entity}QueryRequest request);

    /**
     * 分页查询
     */
    IPage<{Entity}Response> pageQuery({Entity}QueryRequest request);
}
```

## Service 实现类

```java
package com.{company}.{project}.{module}.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.{company}.{project}.common.core.ErrorCode;
import com.{company}.{project}.common.exception.BusinessException;
import com.{company}.{project}.common.security.LoginUser;
import com.{company}.{project}.common.security.LoginUserHolder;
import com.{company}.{project}.{module}.entity.{Entity};
import com.{company}.{project}.{module}.mapper.{Entity}Mapper;
import com.{company}.{project}.{module}.model.request.*;
import com.{company}.{project}.{module}.model.response.{Entity}Response;
import com.{company}.{project}.{module}.service.{Entity}Service;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;

/**
 * {description}服务实现类
 *
 * @author {author}
 * @since {date}
 */
@Slf4j
@Service
public class {Entity}ServiceImpl extends ServiceImpl<{Entity}Mapper, {Entity}> implements {Entity}Service {

    @Override
    public Long create({Entity}CreateRequest request) {
        log.info("[{Entity}Service.create] 创建{description}, request={}", request);

        LoginUser loginUser = LoginUserHolder.get();

        {Entity} entity = BeanUtil.copyProperties(request, {Entity}.class);
        entity.setCreateBy(loginUser.getUsername());

        this.save(entity);

        log.info("[{Entity}Service.create] {description}创建成功, id={}", entity.getId());
        return entity.getId();
    }

    @Override
    public void update(Long id, {Entity}UpdateRequest request) {
        log.info("[{Entity}Service.update] 更新{description}, id={}, request={}", id, request);

        {Entity} entity = this.getById(id);
        if (entity == null) {
            throw new BusinessException(ErrorCode.DATA_NOT_EXIST);
        }

        LoginUser loginUser = LoginUserHolder.get();

        BeanUtil.copyProperties(request, entity);
        entity.setUpdateBy(loginUser.getUsername());

        this.updateById(entity);

        log.info("[{Entity}Service.update] {description}更新成功, id={}", id);
    }

    @Override
    public void deleteById(Long id) {
        log.info("[{Entity}Service.deleteById] 删除{description}, id={}", id);

        {Entity} entity = this.getById(id);
        if (entity == null) {
            throw new BusinessException(ErrorCode.DATA_NOT_EXIST);
        }

        this.removeById(id);

        log.info("[{Entity}Service.deleteById] {description}删除成功, id={}", id);
    }

    @Override
    public {Entity}Response getDetail(Long id) {
        log.info("[{Entity}Service.getDetail] 获取{description}详情, id={}", id);

        {Entity} entity = this.getById(id);
        if (entity == null) {
            throw new BusinessException(ErrorCode.DATA_NOT_EXIST);
        }

        return convertToResponse(entity);
    }

    @Override
    public List<{Entity}Response> list({Entity}QueryRequest request) {
        log.info("[{Entity}Service.list] 查询{description}列表, request={}", request);

        List<{Entity}> list = this.lambdaQuery()
                .like(StrUtil.isNotBlank(request.getKeyword()), {Entity}::getName, request.getKeyword())
                .eq(request.getStatus() != null, {Entity}::getStatus, request.getStatus())
                .orderByDesc({Entity}::getCreateTime)
                .list();

        return list.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public IPage<{Entity}Response> pageQuery({Entity}QueryRequest request) {
        log.info("[{Entity}Service.pageQuery] 分页查询{description}, request={}", request);

        Page<{Entity}> page = new Page<>(request.getPageNo(), request.getPageSize());

        IPage<{Entity}> entityPage = this.lambdaQuery()
                .like(StrUtil.isNotBlank(request.getKeyword()), {Entity}::getName, request.getKeyword())
                .eq(request.getStatus() != null, {Entity}::getStatus, request.getStatus())
                .orderByDesc({Entity}::getCreateTime)
                .page(page);

        return entityPage.convert(this::convertToResponse);
    }

    /**
     * 转换为响应对象
     */
    private {Entity}Response convertToResponse({Entity} entity) {
        return BeanUtil.copyProperties(entity, {Entity}Response.class);
    }
}
```

---

## 关联查询示例（避免 N+1）

```java
/**
 * 列表查询（带关联数据）
 *
 * ✗ 错误：循环内查询（N+1 问题）
 * for ({Entity} entity : list) {
 *     User user = userMapper.selectById(entity.getUserId());  // N 次查询
 * }
 *
 * ✓ 正确：批量查询
 */
@Override
public List<{Entity}Response> listWithUser({Entity}QueryRequest request) {
    // 1. 查询主表数据
    List<{Entity}> list = this.lambdaQuery()
            .eq(request.getStatus() != null, {Entity}::getStatus, request.getStatus())
            .list();

    if (list.isEmpty()) {
        return Collections.emptyList();
    }

    // 2. 批量查询关联数据
    Set<Long> userIds = list.stream()
            .map({Entity}::getUserId)
            .collect(Collectors.toSet());
    Map<Long, User> userMap = userMapper.selectBatchIds(userIds)
            .stream()
            .collect(Collectors.toMap(User::getId, Function.identity()));

    // 3. 组装结果
    return list.stream()
            .map(entity -> {
                {Entity}Response response = convertToResponse(entity);
                User user = userMap.get(entity.getUserId());
                if (user != null) {
                    response.setUserName(user.getName());
                }
                return response;
            })
            .collect(Collectors.toList());
}
```

---

## 批量操作示例

```java
/**
 * 批量删除
 */
@Override
@Transactional(rollbackFor = Exception.class)
public void batchDelete(List<Long> ids) {
    log.info("[{Entity}Service.batchDelete] 批量删除{description}, ids={}", ids);

    if (ids == null || ids.isEmpty()) {
        return;
    }

    // 分批处理，每批 500
    List<List<Long>> batches = Lists.partition(ids, 500);
    for (List<Long> batch : batches) {
        this.removeByIds(batch);
    }

    log.info("[{Entity}Service.batchDelete] 批量删除完成, count={}", ids.size());
}
```

---

## 注意事项

1. **日志规范** - 方法入口和出口都要记录日志，格式：`[类名.方法名] 操作描述, 参数={}`
2. **空值检查** - 查询结果为空时抛出 `BusinessException(ErrorCode.DATA_NOT_EXIST)`
3. **N+1 问题** - 禁止循环内查询数据库，必须使用批量查询
4. **批量操作** - 超过 500 条数据必须分批处理
5. **事务控制** - 批量写操作添加 `@Transactional`
