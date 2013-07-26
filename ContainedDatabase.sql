USE master;
GO

IF DATABASEPROPERTYEX('ContainedDB', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE ContainedDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ContainedDB;
END
GO

IF(SELECT COUNT(*) FROM sys.server_principals WHERE name = 'ContainedLogin') > 0 DROP LOGIN ContainedLogin;
GO

CREATE DATABASE ContainedDB;
GO

ALTER DATABASE ContainedDB SET RECOVERY SIMPLE;
GO

USE ContainedDB;
GO

CREATE TABLE A (Id int IDENTITY, A int, B char(10));
GO

INSERT INTO A SELECT 100*RAND(), 'Hello';
INSERT INTO A SELECT 100*RAND(), 'There';
INSERT INTO A SELECT 100*RAND(), 'Hello';
INSERT INTO A SELECT 100*RAND(), 'World';
GO

SELECT Id, A, B FROM A;
GO

sp_configure 'contained database authentication', 1
RECONFIGURE
GO

ALTER DATABASE ContainedDB SET CONTAINMENT = PARTIAL
GO

CREATE LOGIN ContainedLogin WITH PASSWORD = '(@#F23fj89023j9-23f23o'
GO

CREATE USER ContainedUser FOR LOGIN ContainedLogin
GO

-- will make the name "ContainedLogin"
--sp_migrate_user_to_contained N'ContainedUser', N'copy_login_name', N'do_not_disable_login'

-- will keep the name as "ContainedUser"
sp_migrate_user_to_contained N'ContainedUser', N'keep_name', N'do_not_disable_login'
GO

USE master;
GO

IF DATABASEPROPERTYEX('ContainedDB', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE ContainedDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ContainedDB;
END
GO