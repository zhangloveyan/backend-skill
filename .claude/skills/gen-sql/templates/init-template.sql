-- ============================================================
-- 数据库初始化脚本
-- 项目: {project}
-- 创建时间: {date}
-- ============================================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `{project}` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `{project}`;

-- ============================================================
-- 系统表
-- ============================================================

-- 用户表
CREATE TABLE IF NOT EXISTS `sys_user` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `username` VARCHAR(50) NOT NULL COMMENT '用户名',
    `password` VARCHAR(100) NOT NULL COMMENT '密码',
    `nickname` VARCHAR(50) COMMENT '昵称',
    `phone` VARCHAR(20) COMMENT '手机号',
    `email` VARCHAR(100) COMMENT '邮箱',
    `avatar` VARCHAR(500) COMMENT '头像',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态 (1-启用, 0-禁用)',
    `create_by` VARCHAR(64) NOT NULL COMMENT '创建人',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(64) COMMENT '更新人',
    `update_time` DATETIME COMMENT '更新时间',
    `del_flag` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '删除标记',
    PRIMARY KEY (`id`),
    UNIQUE INDEX `uk_sys_user_username` (`username`),
    INDEX `idx_sys_user_phone` (`phone`),
    INDEX `idx_sys_user_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统用户';

-- 初始化管理员账号（密码: admin123，BCrypt加密）
INSERT INTO `sys_user` (`username`, `password`, `nickname`, `status`, `create_by`)
VALUES ('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '管理员', 1, 'system');

-- ============================================================
-- 业务表（按需添加）
-- ============================================================

-- 示例：建议反馈表
-- CREATE TABLE IF NOT EXISTS `feedback` (
--     ...
-- );
