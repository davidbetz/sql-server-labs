--http://stackoverflow.com/questions/1098554/sql-server-how-to-make-server-check-all-its-check-constraints

DBCC CHECKCONSTRAINTS WITH ALL_CONSTRAINTS --This reports any data that violates constraints.

--This reports all constraints that are not trusted
SELECT OBJECT_NAME(parent_object_id) AS table_name, name, is_disabled  
FROM sys.check_constraints 
WHERE is_not_trusted = 1
UNION ALL
SELECT OBJECT_NAME(parent_object_id) AS table_name, name, is_disabled  
FROM sys.foreign_keys
WHERE is_not_trusted = 1
ORDER BY table_name