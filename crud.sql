-- Stored procedures for RBAC system operations
-- This script provides CRUD operations for user and role management

USE security_project;

-- Clean up existing procedures before recreation
DROP PROCEDURE IF EXISTS sp_create_user;
DROP PROCEDURE IF EXISTS sp_get_user_permissions;
DROP PROCEDURE IF EXISTS sp_update_user_email;
DROP PROCEDURE IF EXISTS sp_delete_user;
DROP PROCEDURE IF EXISTS sp_create_role;
DROP PROCEDURE IF EXISTS sp_grant_permission_to_role;
DROP PROCEDURE IF EXISTS sp_revoke_permission_from_role;
DROP PROCEDURE IF EXISTS sp_assign_role;
DROP PROCEDURE IF EXISTS sp_revoke_role;

-- Create new user with hashed password
CREATE PROCEDURE sp_create_user(IN p_username VARCHAR(50), IN p_plainpass VARCHAR(255), IN p_email VARCHAR(100))
INSERT INTO Users(username, password_hash, email)
VALUES(p_username, SHA2(p_plainpass,256), p_email);

-- Retrieve all permissions for a specific user through their roles
CREATE PROCEDURE sp_get_user_permissions(IN p_username VARCHAR(50))
SELECT DISTINCT p.permission_name
FROM Users u
JOIN UserRoles ur ON u.user_id = ur.user_id
JOIN Roles r ON ur.role_id = r.role_id
JOIN RolePermissions rp ON r.role_id = rp.role_id
JOIN Permissions p ON rp.permission_id = p.permission_id
WHERE u.username = p_username
ORDER BY p.permission_name;

-- Update user email address
CREATE PROCEDURE sp_update_user_email(IN p_username VARCHAR(50), IN p_email VARCHAR(100))
UPDATE Users SET email = p_email WHERE username = p_username;

-- Remove user from system
CREATE PROCEDURE sp_delete_user(IN p_username VARCHAR(50))
DELETE FROM Users WHERE username = p_username;

-- Create new role
CREATE PROCEDURE sp_create_role(IN p_role VARCHAR(50))
INSERT INTO Roles(role_name) VALUES(p_role);

-- Grant specific permission to a role
CREATE PROCEDURE sp_grant_permission_to_role(IN p_role VARCHAR(50), IN p_perm VARCHAR(100))
INSERT INTO RolePermissions(role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM Roles r, Permissions p
WHERE r.role_name = p_role AND p.permission_name = p_perm
ON DUPLICATE KEY UPDATE permission_id = VALUES(permission_id);

-- Remove permission from a role
CREATE PROCEDURE sp_revoke_permission_from_role(IN p_role VARCHAR(50), IN p_perm VARCHAR(100))
DELETE rp FROM RolePermissions rp
JOIN Roles r ON rp.role_id = r.role_id
JOIN Permissions p ON rp.permission_id = p.permission_id
WHERE r.role_name = p_role AND p.permission_name = p_perm;

-- Assign role to user
CREATE PROCEDURE sp_assign_role(IN p_username VARCHAR(50), IN p_role VARCHAR(50))
INSERT INTO UserRoles(user_id, role_id)
SELECT u.user_id, r.role_id
FROM Users u, Roles r
WHERE u.username = p_username AND r.role_name = p_role
ON DUPLICATE KEY UPDATE role_id = VALUES(role_id);

-- Remove role from user
CREATE PROCEDURE sp_revoke_role(IN p_username VARCHAR(50), IN p_role VARCHAR(50))
DELETE ur FROM UserRoles ur
JOIN Users u ON ur.user_id = u.user_id
JOIN Roles r ON ur.role_id = r.role_id
WHERE u.username = p_username AND r.role_name = p_role;

-- Display all stored procedures in current database
SHOW PROCEDURE STATUS WHERE Db = DATABASE();

-- Test procedures with sample data
CALL sp_create_user('demo_user','Demo@123','demo@example.com');
CALL sp_assign_role('demo_user','Guest');
CALL sp_get_user_permissions('demo_user');
