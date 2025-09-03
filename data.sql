
-- Initial data setup for RBAC system
-- This script populates the database with roles, permissions, and sample users

USE security_project;

-- Define system roles
INSERT INTO Roles (role_name) VALUES 
('Admin'), ('Auditor'), ('DataEntry'), ('Guest')
ON DUPLICATE KEY UPDATE role_name = VALUES(role_name);

-- Define system permissions
INSERT INTO Permissions (permission_name) VALUES
('READ_USERS'),
('CREATE_USERS'),
('UPDATE_USERS'),
('DELETE_USERS'),
('READ_PRODUCTS'),
('CREATE_PRODUCTS'),
('UPDATE_PRODUCTS'),
('DELETE_PRODUCTS'),
('READ_AUDIT_LOGS')
ON DUPLICATE KEY UPDATE permission_name = VALUES(permission_name);

-- Configure role-permission mappings
-- Admin role has all permissions
INSERT INTO RolePermissions (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM Roles r CROSS JOIN Permissions p
WHERE r.role_name = 'Admin'
ON DUPLICATE KEY UPDATE permission_id = VALUES(permission_id);

-- Auditor role can read users and audit logs
INSERT INTO RolePermissions (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM Roles r JOIN Permissions p
  ON p.permission_name IN ('READ_USERS','READ_AUDIT_LOGS')
WHERE r.role_name = 'Auditor'
ON DUPLICATE KEY UPDATE permission_id = VALUES(permission_id);

-- DataEntry role can manage products
INSERT INTO RolePermissions (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM Roles r JOIN Permissions p
  ON p.permission_name IN ('READ_PRODUCTS','CREATE_PRODUCTS','UPDATE_PRODUCTS')
WHERE r.role_name = 'DataEntry'
ON DUPLICATE KEY UPDATE permission_id = VALUES(permission_id);

-- Guest role has read-only access to products
INSERT INTO RolePermissions (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM Roles r JOIN Permissions p
  ON p.permission_name IN ('READ_PRODUCTS')
WHERE r.role_name = 'Guest'
ON DUPLICATE KEY UPDATE permission_id = VALUES(permission_id);

-- Create sample users with hashed passwords
INSERT INTO Users (username, password_hash, email) VALUES
('admin',      SHA2('Admin@123',256),      'admin@example.com'),
('auditor1',   SHA2('Auditor@123',256),    'auditor1@example.com'),
('dataentry1', SHA2('DataEntry@123',256),  'dataentry1@example.com'),
('guest1',     SHA2('Guest@123',256),      'guest1@example.com')
ON DUPLICATE KEY UPDATE email = VALUES(email);

-- Assign roles to users
INSERT INTO UserRoles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM Users u JOIN Roles r ON r.role_name='Admin'
WHERE u.username='admin'
ON DUPLICATE KEY UPDATE role_id = VALUES(role_id);

INSERT INTO UserRoles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM Users u JOIN Roles r ON r.role_name='Auditor'
WHERE u.username='auditor1'
ON DUPLICATE KEY UPDATE role_id = VALUES(role_id);

INSERT INTO UserRoles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM Users u JOIN Roles r ON r.role_name='DataEntry'
WHERE u.username='dataentry1'
ON DUPLICATE KEY UPDATE role_id = VALUES(role_id);

INSERT INTO UserRoles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM Users u JOIN Roles r ON r.role_name='Guest'
WHERE u.username='guest1'
ON DUPLICATE KEY UPDATE role_id = VALUES(role_id);

-- Verify data insertion
SELECT 'Roles' t, COUNT(*) c FROM Roles
UNION ALL SELECT 'Permissions', COUNT(*) FROM Permissions
UNION ALL SELECT 'Users', COUNT(*) FROM Users
UNION ALL SELECT 'UserRoles', COUNT(*) FROM UserRoles
UNION ALL SELECT 'RolePermissions', COUNT(*) FROM RolePermissions;

SELECT * FROM Roles;
SELECT * FROM Users;
