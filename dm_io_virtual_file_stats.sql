DECLARE @max int;
SELECT @max = max(file_id) FROM sys.database_files

DECLARE @i int = 1
WHILE @i <= @max
BEGIN
    SELECT *
    FROM sys.dm_io_virtual_file_stats(DB_ID(), @i)
    WHERE file_id = @i

    SET @i = @i + 1
END
