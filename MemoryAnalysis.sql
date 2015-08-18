DBCC FREEPROCCACHE

select DB_NAME(database_id), *
from sys.dm_os_buffer_descriptors
where database_id = 16

select * from sys.dm_os_memory_objects

DBCC MEMORYSTATUS