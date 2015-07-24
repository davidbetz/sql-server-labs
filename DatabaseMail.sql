USE msdb;
go
sp_send_dbmail @profile_name='prof01', @body='Full Backup Complete', @subject='Full Backup Complete', @recipients='me@example.org'
go

sp_send_dbmail @profile_name='prof01', @body='taco', @recipients='me2@example.org'
go

sp_send_dbmail @profile_name='prof01', @body='taco', @recipients='me3@example.org'
go

SELECT *
FROM sysmail_mailitems
GO

SELECT 
FROM sysmail_log
WHERE log_id > 23
GO