-- Audit system implementation with triggers and views
-- This script sets up comprehensive audit logging for the RBAC system

USE security_project;

-- Business table for demonstration purposes
CREATE TABLE IF NOT EXISTS Products (
  product_id     INT AUTO_INCREMENT PRIMARY KEY,
  product_name   VARCHAR(255) NOT NULL,
  price          DECIMAL(10,2) NOT NULL,
  stock_quantity INT NOT NULL,
  description    TEXT,
  created_by     INT,
  updated_by     INT,
  created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (created_by) REFERENCES Users(user_id),
  FOREIGN KEY (updated_by) REFERENCES Users(user_id)
);

-- Remove existing triggers before recreation
DROP TRIGGER IF EXISTS trg_products_after_insert;
DROP TRIGGER IF EXISTS trg_products_after_update;
DROP TRIGGER IF EXISTS trg_products_after_delete;

CREATE TRIGGER trg_products_after_insert
AFTER INSERT ON Products
FOR EACH ROW
INSERT INTO AuditLogs(
  timestamp, user_id, action_type, table_name, record_id,
  new_value, ip_address, status, details
)
VALUES (
  NOW(), @current_user_id, 'INSERT', 'Products', NEW.product_id,
  JSON_OBJECT('product_id', NEW.product_id, 'product_name', NEW.product_name, 'price', NEW.price, 'stock', NEW.stock_quantity),
  '127.0.0.1', 'SUCCESS', CONCAT('Inserted product: ', NEW.product_name)
);

CREATE TRIGGER trg_products_after_update
AFTER UPDATE ON Products
FOR EACH ROW
INSERT INTO AuditLogs(
  timestamp, user_id, action_type, table_name, record_id,
  old_value, new_value, ip_address, status, details
)
VALUES (
  NOW(), @current_user_id, 'UPDATE', 'Products', NEW.product_id,
  JSON_OBJECT('product_name', OLD.product_name, 'price', OLD.price, 'stock', OLD.stock_quantity),
  JSON_OBJECT('product_name', NEW.product_name, 'price', NEW.price, 'stock', NEW.stock_quantity),
  '127.0.0.1', 'SUCCESS', CONCAT('Updated product: ', NEW.product_name)
);

CREATE TRIGGER trg_products_after_delete
AFTER DELETE ON Products
FOR EACH ROW
INSERT INTO AuditLogs(
  timestamp, user_id, action_type, table_name, record_id,
  old_value, ip_address, status, details
)
VALUES (
  NOW(), @current_user_id, 'DELETE', 'Products', OLD.product_id,
  JSON_OBJECT('product_id', OLD.product_id, 'product_name', OLD.product_name, 'price', OLD.price, 'stock', OLD.stock_quantity),
  '127.0.0.1', 'SUCCESS', CONCAT('Deleted product: ', OLD.product_name)
);

-- Create views for audit analysis and reporting
CREATE OR REPLACE VIEW vw_UserActivitySummary AS
SELECT
  COALESCE(u.username, '(unknown)') AS username,
  al.action_type,
  COUNT(al.log_id) AS total_actions,
  MIN(al.timestamp) AS first_action,
  MAX(al.timestamp) AS last_action
FROM AuditLogs al
LEFT JOIN Users u ON al.user_id = u.user_id
GROUP BY COALESCE(u.username, '(unknown)'), al.action_type
ORDER BY username, total_actions DESC;

CREATE OR REPLACE VIEW vw_FailedLoginAttempts AS
SELECT log_id, timestamp, user_id, ip_address, details
FROM AuditLogs
WHERE action_type = 'LOGIN_FAIL'
ORDER BY timestamp DESC;

CREATE OR REPLACE VIEW vw_SensitiveDataAccess AS
SELECT al.timestamp, u.username, al.action_type, al.table_name, al.record_id, al.ip_address, al.details
FROM AuditLogs al
LEFT JOIN Users u ON al.user_id = u.user_id
WHERE al.table_name IN ('Users','Products')
  AND al.action_type IN ('SELECT','UPDATE','DELETE')
ORDER BY al.timestamp DESC;

CREATE OR REPLACE VIEW vw_ProductAuditTrail AS
SELECT al.timestamp, u.username, al.action_type, al.old_value, al.new_value, al.details
FROM AuditLogs al
LEFT JOIN Users u ON al.user_id = u.user_id
WHERE al.table_name = 'Products'
ORDER BY al.timestamp ASC;

-- Create performance indexes for audit queries
CREATE INDEX idx_users_username          ON Users(username);
CREATE INDEX idx_users_email             ON Users(email);
CREATE INDEX idx_roles_name              ON Roles(role_name);
CREATE INDEX idx_permissions_name        ON Permissions(permission_name);

CREATE INDEX idx_audit_timestamp         ON AuditLogs(timestamp);
CREATE INDEX idx_audit_user_id           ON AuditLogs(user_id);
CREATE INDEX idx_audit_action_type       ON AuditLogs(action_type);
CREATE INDEX idx_audit_table_name        ON AuditLogs(table_name);

-- Verify audit system components
SHOW TRIGGERS LIKE 'Products';
SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';
SHOW INDEX FROM AuditLogs;
