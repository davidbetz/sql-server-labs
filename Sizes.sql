SELECT
t.name, i.name, p.rows, total_pages, a.used_pages, a.data_pages
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.partitions p ON i.index_id = p.index_id AND t.object_id = p.object_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE total_pages > 0
ORDER BY total_pages desc