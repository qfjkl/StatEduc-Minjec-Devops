-- Create the new database if it does not exist already
IF NOT EXISTS (
    SELECT name
    FROM sys.databases
    WHERE name = N'dico_DB'
)
BEGIN
    CREATE DATABASE dico_DB;
END;
GO

-- Restore database from backup
RESTORE DATABASE dico_DB
FROM DISK = '/var/opt/mssql/backup/DICO_DB_NEW_1804204.bak'
WITH FILE = 1, STATS = 5,
REPLACE,
MOVE 'dico_DB' TO '/var/opt/mssql/data/dico_DB.mdf',
MOVE 'dico_DB_log' TO '/var/opt/mssql/data/dico_DB_log.ldf';
