REVERT;
GO

IF (SELECT COUNT(*) FROM sys.server_principals WHERE name = 'UserA') > 0 DROP USER UserA;
IF (SELECT COUNT(*) FROM sys.server_principals WHERE name = 'UserA') > 0 DROP LOGIN UserA;
IF (SELECT COUNT(*) FROM sys.server_principals WHERE name = 'SpecialDBARole') > 0 DROP SERVER ROLE SpecialDBARole;
GO

CREATE SERVER ROLE [SpecialDBARole] AUTHORIZATION securityadmin;
GO

CREATE LOGIN UserA WITH PASSWORD = '!@E(@#fj902323m9-';
GO

CREATE USER UserA FOR LOGIN UserA;
GO

ALTER SERVER ROLE [SpecialDBARole] ADD MEMBER UserA;
GO

GRANT VIEW SERVER STATE, VIEW ANY DATABASE TO [SpecialDBARole];
GO

EXECUTE AS USER = 'UserA';
GO

SELECT CURRENT_USER as 'CURRENT_USER';
GO

CREATE LOGIN UserB WITH PASSWORD = '!@E(@#fj902323m9-';
GO

SELECT * FROM sys.databases
GO

REVERT;
GO

IF (SELECT COUNT(*) FROM sys.server_principals WHERE name = 'UserA') > 0 DROP USER UserA;
IF (SELECT COUNT(*) FROM sys.server_principals WHERE name = 'UserA') > 0 DROP LOGIN UserA;
IF (SELECT COUNT(*) FROM sys.server_principals WHERE name = 'SpecialDBARole') > 0 DROP SERVER ROLE SpecialDBARole;
GO