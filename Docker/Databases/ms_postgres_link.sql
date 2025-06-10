USE [master]
GO

-- Drop the linked server if it already exists
IF EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.server_id != 0 AND srv.name = N'PG_LINKED_SERVER')
EXEC master.dbo.sp_dropserver 
    @server=N'PG_LINKED_SERVER', 
    @droplogins='droplogins';
GO

-- Add the linked server
EXEC master.dbo.sp_addlinkedserver
    @server = N'PG_LINKED_SERVER', -- The name you want to use for the linked server
    @srvproduct = N'PostgreSQL',   -- Can be any name, descriptive
    @provider = N'MSDASQL',        -- Provider for ODBC
    @datasrc = N'PgDockerDSN';     -- Name of your ODBC System DSN
                                   -- Ensure 'PgDockerDSN' is configured in the MSSQL container
                                   -- to point to the PostgreSQL container's IP/hostname and database.
GO

-- Add the login mapping for the linked server
EXEC master.dbo.sp_addlinkedsrvlogin
    @rmtsrvname = N'PG_LINKED_SERVER', -- Must match @server above
    @useself = 'false',                -- Use the remote user and password specified below
    @locallogin = NULL,                -- Applies to all local logins not otherwise mapped.
                                       -- Or, specify an MSSQL login e.g., 'sa' or 'your_mssql_user'
    @rmtuser = N'your_postgres_user',  -- Your PostgreSQL username
    @rmtpassword = N'your_postgres_password'; -- Your PostgreSQL password
GO

-- Optional: Configure server options if needed
-- EXEC master.dbo.sp_serveroption @server=N'PG_LINKED_SERVER', @optname=N'collation compatible', @optvalue=N'false'
-- EXEC master.dbo.sp_serveroption @server=N'PG_LINKED_SERVER', @optname=N'data access', @optvalue=N'true'
-- EXEC master.dbo.sp_serveroption @server=N'PG_LINKED_SERVER', @optname=N'dist', @optvalue=N'false'
-- EXEC master.dbo.sp_serveroption @server=N'PG_LINKED_SERVER', @optname=N'pub', @optvalue=N'false'
-- EXEC master.dbo.sp_serveroption @server=N'PG_LINKED_SERVER', @optname=N'rpc', @optvalue=N'true' -- Or false depending on needs
-- EXEC master.dbo.sp_serveroption @server=N'PG_LINKED_SERVER', @optname=N'rpc out', @optvalue=N'true' -- Or false
-- EXEC master.dbo.sp_serveroption @server=N'PG_LINKED_SERVER', @optname=N'sub', @optvalue=N'false'
-- EXEC master.dbo.sp_serveroption @server=N'PG_LINKED_SERVER', @optname=N'connect timeout', @optvalue=N'0'
-- EXEC master.dbo.sp_serveroption @server=N'PG_LINKED_SERVER', @optname=N'collation name', @optvalue=null
-- EXEC master.dbo.sp_serveroption @server=N'PG_LINKED_SERVER', @optname=N'lazy schema validation', @optvalue=N'false'
-- EXEC master.dbo.sp_serveroption @server=N'PG_LINKED_SERVER', @optname=N'query timeout', @optvalue=N'0'
-- EXEC master.dbo.sp_serveroption @server=N'PG_LINKED_SERVER', @optname=N'use remote collation', @optvalue=N'true'
-- EXEC master.dbo.sp_serveroption @server=N'PG_LINKED_SERVER', @optname=N'remote proc transaction promotion', @optvalue=N'true' -- Or false, often true if you need distributed transactions
GO

-- Test the linked server (replace with your actual PostgreSQL table)
-- SELECT * FROM PG_LINKED_SERVER...your_postgres_database.your_schema.your_table;
-- Example: SELECT * FROM PG_LINKED_SERVER...postgres.public.users;
GO