USE [master];
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'ProjeDB')
BEGIN
    ALTER DATABASE [ProjeDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [ProjeDB];
END
GO


RESTORE DATABASE [ProjeDB] 
FROM DISK = 'C:\Users\merve\Yedekler\AdventureWorks2019.bak' 
WITH MOVE 'AdventureWorks2019' TO 'C:\Users\merve\Yedekler\ProjeDB.mdf',
     MOVE 'AdventureWorks2019_log' TO 'C:\Users\merve\Yedekler\ProjeDB_log.ldf',
     REPLACE;
GO


ALTER DATABASE [ProjeDB] SET RECOVERY FULL;
GO


BACKUP DATABASE [ProjeDB] 
TO DISK = 'C:\Users\merve\Yedekler\Proje_Tam.bak' WITH FORMAT;
GO

USE [ProjeDB];
GO
CREATE TABLE ProjeTablosu (ID INT, Notlar NVARCHAR(100));
INSERT INTO ProjeTablosu VALUES (1, 'Tam yedekten sonra eklendi');
GO


BACKUP DATABASE [ProjeDB] 
TO DISK = 'C:\Users\merve\Yedekler\Proje_Fark.bak' WITH DIFFERENTIAL;
GO


INSERT INTO ProjeTablosu VALUES (2, 'Fark yedekten sonra eklendi');
GO
BACKUP LOG [ProjeDB] 
TO DISK = 'C:\Users\merve\Yedekler\Proje_Log.trn';
GO


USE [ProjeDB];
GO

DROP TABLE ProjeTablosu;
GO

SELECT * FROM ProjeTablosu;
GO


USE [master];
GO

ALTER DATABASE [ProjeDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO


RESTORE DATABASE [ProjeDB] 
FROM DISK = 'C:\Users\merve\Yedekler\Proje_Tam.bak' 
WITH REPLACE, NORECOVERY;
GO


RESTORE DATABASE [ProjeDB] 
FROM DISK = 'C:\Users\merve\Yedekler\Proje_Fark.bak' 
WITH RECOVERY;
GO

ALTER DATABASE [ProjeDB] SET MULTI_USER;
GO

USE [ProjeDB];
GO
SELECT * FROM ProjeTablosu;
GO


USE [master];
GO

ALTER DATABASE [ProjeDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO


RESTORE DATABASE [ProjeDB] 
FROM DISK = 'C:\Users\merve\Yedekler\Proje_Tam.bak' 
WITH REPLACE, NORECOVERY;
GO


RESTORE DATABASE [ProjeDB] 
FROM DISK = 'C:\Users\merve\Yedekler\Proje_Fark.bak' 
WITH NORECOVERY;
GO


RESTORE LOG [ProjeDB] 
FROM DISK = 'C:\Users\merve\Yedekler\Proje_Log.trn' 
WITH RECOVERY;
GO


ALTER DATABASE [ProjeDB] SET MULTI_USER;
GO


USE [ProjeDB];
GO
SELECT * FROM ProjeTablosu;
GO