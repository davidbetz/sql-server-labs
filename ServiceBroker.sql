USE master;
GO

IF DATABASEPROPERTYEX('ServiceBroker', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE ServiceBroker SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ServiceBroker;
END
GO

CREATE DATABASE ServiceBroker;
GO

USE ServiceBroker;
GO

--select name, is_broker_enabled, service_broker_guid from sys.databases;

CREATE QUEUE ReceiveQueue
GO

-- DEFAULT is built in service contract
CREATE SERVICE Receiver
    ON QUEUE ReceiveQueue ([DEFAULT])
GO

CREATE QUEUE SenderQueue
GO

CREATE SERVICE Sender
    ON QUEUE SenderQueue
GO

DECLARE @h uniqueidentifier;
BEGIN TRY
    BEGIN DIALOG CONVERSATION @h
        FROM SERVICE Sender
        TO SERVICE 'Receiver'
        WITH ENCRYPTION = OFF;

        SEND ON CONVERSATION @h ('Hello World');
END TRY
BEGIN CATCH
    PRINT error_message()
END CATCH;
GO

DECLARE @h uniqueidentifier;
DECLARE @m varchar(max);
RECEIVE TOP(1) @h = CONVERSATION_HANDLE, @m=cast(message_body AS varchar(max)) FROM ReceiveQueue;
PRINT @m;
END CONVERSATION @H;
GO

DECLARE @h uniqueidentifier;
DECLARE @m varchar(max);
RECEIVE TOP(1) @h = CONVERSATION_HANDLE, @m=cast(message_body AS varchar(max)) FROM SenderQueue;
PRINT @m;
END CONVERSATION @h;
GO

--select * from sys.conversation_endpoints

DROP SERVICE Sender;
DROP SERVICE Receiver;
DROP QUEUE SenderQueue;
DROP QUEUE ReceiveQueue;
GO

USE master;
GO

IF DATABASEPROPERTYEX('ServiceBroker', 'Status') IS NOT NULL
BEGIN
	ALTER DATABASE ServiceBroker SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ServiceBroker;
END
GO