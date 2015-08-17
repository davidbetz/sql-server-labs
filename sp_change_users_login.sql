EXEC sp_change_users_login 'UPDATE_ONE','MyDbUser','MyDbUser'


sp_change_users_login @action='update_one', @usernamepattern= 'MyDbUser', @loginname='MyDbLogin'