USE master;

;WITH
OriginalData(data) 
AS (
	SELECT convert(xml, st.target_data) from sys.dm_xe_sessions s
	INNER JOIN sys.dm_xe_session_targets st ON s.address = st.event_session_Address
	WHERE s.name = 'system_health'
),
TransformData([Event], [Time], [SQLStatement])
AS
(
	SELECT
	t.e.value('@name', 'sysname') as [Event]
	,t.e.value('@timestamp', 'datetime') as [Time]
	,t.e.value('(data[@name="xml_report"]/value)[1]', 'nvarchar(max)') as [SQLStatement]
	FROM OriginalData CROSS APPLY OriginalData.data.nodes('/RingBufferTarget/event') as t(e)
)
SELECT [Time], CAST([SQLStatement] as xml) FROM TransFormdata
WHERE [Event] = 'xml_deadlock_report';
GO