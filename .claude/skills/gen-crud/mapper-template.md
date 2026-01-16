# Mapper 模板

## Mapper 接口

```java
package com.{company}.{project}.{module}.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.{company}.{project}.{module}.entity.{Entity};
import org.apache.ibatis.annotations.Mapper;

/**
 * {description} Mapper
 *
 * @author {author}
 * @since {date}
 */
@Mapper
public interface {Entity}Mapper extends BaseMapper<{Entity}> {

}
```

## Mapper XML

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.{company}.{project}.{module}.mapper.{Entity}Mapper">

    <resultMap id="BaseResultMap" type="com.{company}.{project}.{module}.entity.{Entity}">
        <id property="id" column="id"/>
        <!-- 业务字段 -->
        <result property="name" column="name"/>
        <result property="status" column="status"/>
        <!-- 通用字段 -->
        <result property="createBy" column="create_by"/>
        <result property="createTime" column="create_time"/>
        <result property="updateBy" column="update_by"/>
        <result property="updateTime" column="update_time"/>
        <result property="delFlag" column="del_flag"/>
    </resultMap>

    <sql id="Base_Column_List">
        id, name, status, create_by, create_time, update_by, update_time, del_flag
    </sql>

</mapper>
```

## JSON 字段映射

```xml
<result property="images" column="images"
    typeHandler="com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler"/>
```
