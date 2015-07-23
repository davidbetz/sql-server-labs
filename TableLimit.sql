USE master;
GO

IF DATABASEPROPERTYEX('TableLimit', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE TableLimit SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE TableLimit;
END
GO

CREATE DATABASE TableLimit;
GO

USE TableLimit;
GO

CREATE TABLE RowTooLarge (
	ID INT NOT NULL,
	Column1 CHAR(8000) NULL, -- VARCHAR would be allowed for BOTH of these
	Column2 CHAR(8000) NULL
) ON [Primary];
GO

CREATE TABLE ExceedsColumnMax (
	Column1 CHAR(8192)
) ON [Primary];
GO

CREATE TABLE AccountingForMaxDataTypeSize (
	Column1 CHAR(8000),
	Column2 CHAR(192) /* 8192 - 8000 */
) ON [Primary];
GO

CREATE TABLE AccountingForPageHeader (
	Column1 CHAR(8000),
	Column3 CHAR(96) /* 8192 - 8000 - 96 */
) ON [Primary];
GO

CREATE TABLE AccountingForRowOffsetHeader (
	Column1 CHAR(8000),
	Column3 CHAR(60) /* 8192 - 8000 - 96 - 36 */
) ON [Primary];
GO

CREATE TABLE AccountingForRowOverhead (
	Column1 CHAR(8000),
	Column3 CHAR(53) /* 8192 - 8000 - 96 - 36 - 7 */
) ON [Primary];
GO