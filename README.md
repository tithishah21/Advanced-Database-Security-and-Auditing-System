# Advanced-Database-Security-and-Auditing-System
DBMS project - sem 5

📌 Project Description
- Advanced Database Security and Auditing System is a DBMS project designed to enforce security and accountability directly at the database layer. Traditional databases focus only on CRUD operations, but modern organizations also require authorization (who is allowed to do what) and auditing (who did what, when, and how).
- This project implements a Role-Based Access Control (RBAC) model where users are assigned roles (Admin, Auditor, DataEntry, Guest), and each role is mapped to a set of permissions. Instead of granting permissions directly to users, the database ensures actions flow through roles → permissions, making the system scalable and secure.
- To guarantee accountability, the project introduces Audit Logging through database triggers. Every critical operation such as INSERT, UPDATE, or DELETE on sensitive tables is automatically recorded in an AuditLogs table, capturing details like the timestamp, user, action type, affected table, old value, new value, status, and IP address.
- To make audit data easy to analyze, the system includes predefined views such as:
     - vw_UserActivitySummary – summarizes per-user activity
     - vw_ProductAuditTrail – shows detailed history of product changes
     - vw_FailedLoginAttempts – monitors failed login attempts
     - vw_SensitiveDataAccess – tracks access to sensitive entities
- The project also provides stored procedures for user/role/permission management, making it simple for administrators to create users, assign roles, and query effective permissions. Indexes on key audit columns ensure fast log analysis even at scale.
- Currently implemented in MySQL, the system demonstrates how database-level security and auditing can ensure compliance, transparency, and integrity. Future scope includes migration to NeonDB (Postgres cloud) for collaborative access, advanced encryption methods, and dashboards for real-time audit visualization.
