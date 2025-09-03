-- Demonstration script for audit system functionality
-- This script tests the audit triggers and views with sample operations

USE security_project;

-- Set current user context for audit logging
SET @current_user_id = (SELECT user_id FROM Users WHERE username = 'admin');

-- Test INSERT operation and audit logging
INSERT INTO Products(product_name, price, stock_quantity, description, created_by, updated_by)
VALUES ('USB-C Hub', 2499.00, 50, '6-in-1 adapter', @current_user_id, @current_user_id);

-- Test UPDATE operation and audit logging
UPDATE Products
SET price = 2299.00, stock_quantity = 48, updated_by = @current_user_id
WHERE product_name = 'USB-C Hub';

-- Test DELETE operation and audit logging
DELETE FROM Products
WHERE product_name = 'USB-C Hub';

-- Display recent audit log entries
SELECT log_id, timestamp, user_id, action_type, table_name, record_id, status, details
FROM AuditLogs
ORDER BY log_id DESC
LIMIT 20;

-- Show user activity summary
SELECT * FROM vw_UserActivitySummary;

-- Display product audit trail
SELECT * FROM vw_ProductAuditTrail ORDER BY timestamp DESC LIMIT 20;

-- Check for any failed login attempts
SELECT * FROM vw_FailedLoginAttempts LIMIT 20;

-- Final verification queries
SELECT * FROM AuditLogs ORDER BY log_id DESC LIMIT 20;
SELECT * FROM vw_UserActivitySummary;
SELECT * FROM vw_ProductAuditTrail ORDER BY timestamp DESC LIMIT 20;
SELECT * FROM vw_FailedLoginAttempts LIMIT 20;
