USE master;
GO

IF DATABASEPROPERTYEX('OwnershipChaining', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE OwnershipChaining SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE OwnershipChaining;
END
GO

IF(SELECT COUNT(*) FROM sys.server_principals WHERE name = 'UserA') > 0 DROP LOGIN UserA;
IF(SELECT COUNT(*) FROM sys.server_principals WHERE name = 'UserB') > 0 DROP LOGIN UserB;
IF(SELECT COUNT(*) FROM sys.server_principals WHERE name = 'UserC') > 0 DROP LOGIN UserC;
GO

CREATE DATABASE OwnershipChaining;
GO

ALTER DATABASE OwnershipChaining SET RECOVERY SIMPLE;
GO

USE OwnershipChaining;
GO

CREATE SCHEMA Schema_A;
GO

CREATE TABLE Schema_A.TableA (Id int IDENTITY, A int, B char(10), IsActive bit);
GO

INSERT INTO Schema_A.TableA SELECT 100*RAND(), 'Hello', 1;
INSERT INTO Schema_A.TableA SELECT 100*RAND(), 'There', 0;
INSERT INTO Schema_A.TableA SELECT 100*RAND(), 'Hello', 0;
INSERT INTO Schema_A.TableA SELECT 100*RAND(), 'World', 1;
GO

CREATE LOGIN UserC WITH PASSWORD = '9023f92jf@#F@#23m';
GO

CREATE USER UserC FOR LOGIN UserC;
GO

CREATE PROCEDURE Schema_A.Purge
--WITH EXECUTE AS USER = 'dbo'
AS
DELETE FROM Schema_A.TableA WHERE IsActive = 0
GO

GRANT EXECUTE ON Schema_A.Purge TO UserC;
GO

EXECUTE AS user ='UserC'
GO

SELECT CURRENT_USER;
GO

Schema_A.Purge;
GO

-- UserC can't access
--SELECT * FROM Schema_A.TableA;
GO

REVERT
GO

-- Purge was sucessful
SELECT * FROM Schema_A.TableA;
GO

USE master;
GO

IF DATABASEPROPERTYEX('OwnershipChaining', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE OwnershipChaining SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE OwnershipChaining;
END
GO