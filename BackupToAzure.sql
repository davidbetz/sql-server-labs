CREATE CREDENTIAL AzureStore
WITH IDENTITY = 'mystore',
SECRET = '';
GO

BACKUP DATABASE Revision
TO URL = 'https://store.blob.core.windows.net/backups/Database_2014-08-17.bak'
WITH CREDENTIAL = 'mystore';
GO