DECLARE @var nvarchar(max) = 'asdfsdf';

SELECT TRY_PARSE(@var AS decimal(36,9))

SELECT
  IIF(TRY_PARSE(@var AS decimal(36,9)) IS NULL, 'True', 'False')
AS BadCast