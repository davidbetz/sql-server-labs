SET NOCOUNT ON
USE master;
GO

IF DATABASEPROPERTYEX('XmlQuery', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE XmlQuery SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE XmlQuery;
END
GO

CREATE DATABASE XmlQuery;
GO

ALTER DATABASE XmlQuery SET RECOVERY SIMPLE;
GO

USE XmlQuery;
GO

CREATE TABLE dbo.Project
(
Id int,
Details XML
);
GO

INSERT INTO Project (Id, Details)
VALUES
(1,
N'<Project Name="Project1">
<Tasks>
<Task Name="T1"><CoreValue>Apple</CoreValue></Task>
<Task Name="T2"><CoreValue>Banana</CoreValue></Task>
</Tasks>
</Project>
'),
(2,
N'<Project Name="Project1">
<Tasks>
<Task Name="T3"><CoreValue>Orange</CoreValue></Task>
<Task Name="T4"><CoreValue>Pear</CoreValue></Task>
</Tasks>
</Project>
');
GO

--true
SELECT Project.Details.query('//Task/CoreValue="Apple"') as true
FROM Project
WHERE Project.Id = 1;
GO

--false
SELECT Project.Details.query('//Task/CoreValue="NotHere"') as false
FROM Project
WHERE Project.Id = 1;
GO

--true
SELECT Project.Details.query('//Task/CoreValue="Banana"') as true
FROM Project
WHERE Project.Id = 1;
GO

USE master;
GO

IF DATABASEPROPERTYEX('XmlQuery', 'Status') IS NOT NULL DROP DATABASE XmlQuery;
GO