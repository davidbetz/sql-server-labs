USE master;
GO

IF DATABASEPROPERTYEX('TDE', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE TDE SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE TDE;
END
GO

IF(SELECT COUNT(*) FROM sys.certificates where name = 'MyCert') > 0
BEGIN
	DROP CERTIFICATE MyCert;
	DROP MASTER KEY;
END
GO

CREATE MASTER KEY ENCRYPTION BY PASSWORD = '*@#423$FH23n23f80230';
GO

CREATE CERTIFICATE MyCert WITH SUBJECT = 'Taco Burrito Enchilada';
GO

BACKUP CERTIFICATE MyCert
TO FILE = 'H:\_DATA\MyCert.cer'
WITH PRIVATE KEY
(
	FILE = 'H:\_DATA\MyPrivateKey.key',
	ENCRYPTION BY PASSWORD = 'ANOTHER_*(!@E(!@JE@!)12jm22j9,'
);
GO

CREATE DATABASE TDE
ON PRIMARY (
    NAME='TDE_Data',
    FILENAME='H:\_DATA\TDE.MDF',
    SIZE = 250MB
)
LOG ON (
    NAME = 'TDE_Log',
    FILENAME = 'C:\_LOG\TDE.LDF',
    SIZE = 10MB,
    FILEGROWTH=10%
);
GO

USE TDE;
GO

CREATE TABLE A (Id int IDENTITY, A int, B char(10));
GO

INSERT INTO A SELECT 100 * RAND(), 'Hello';
INSERT INTO A SELECT 100 * RAND(), 'There';
INSERT INTO A SELECT 100 * RAND(), 'Hello';
INSERT INTO A SELECT 100 * RAND(), 'World';
GO

SELECT Id, A, B FROM A;
GO

CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_128
ENCRYPTION BY SERVER CERTIFICATE MyCert;
GO

--+ need this BY PASSWORD for Cert2 to be created; previous BY CERTIFICATE does not work
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '#@R)*I#@FM2j-in3m2-i';
GO

ALTER DATABASE TDE SET ENCRYPTION ON;
GO

CREATE PROC GetData
AS
SELECT Id, A, B FROM A;
GO

CREATE CERTIFICATE Cert2
WITH SUBJECT = 'New Data';
GO

ADD SIGNATURE TO GetData BY CERTIFICATE Cert2;

/*
-- ON SERVER03, after copying files...

CREATE MASTER KEY ENCRYPTION BY PASSWORD = '*@#423$FH23n23f80230';
GO

CREATE CERTIFICATE MyCert
FROM FILE = 'p:\MyCert.cer'
WITH PRIVATE KEY
(
	FILE = 'p:\MyPrivateKey.key',
	DECRYPTION BY PASSWORD = 'ANOTHER_*(!@E(!@JE@!)12jm22j9,'
);
GO

*/

USE master;
GO

IF DATABASEPROPERTYEX('TDE', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE TDE SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE TDE;
END
GO