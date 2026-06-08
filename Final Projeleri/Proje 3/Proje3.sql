-- 1. ERÝÞÝM YÖNETÝMÝ

-- Tüm sunucu genelinde geçerli bir Login oluþturuyor
CREATE LOGIN ProjeTestKullanicisi 
WITH PASSWORD = 'GuvenliSifre123*', 
     DEFAULT_DATABASE = ProjeDB;
GO

-- Bu Login'i ProjeDB veritabanýmýza kullanýcý olarak baðlýyoruz
USE ProjeDB;
GO
CREATE USER ProjeTestKullanicisi FOR LOGIN ProjeTestKullanicisi;
GO

-- Kullanýcýya SADECE verileri okuma yetkisi veriyoruz
ALTER ROLE db_datareader ADD MEMBER ProjeTestKullanicisi;
GO


-- 2.VERÝ ÞÝFRELEME 

USE master;
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'CokGuvenliMasterSifre123!';
GO

CREATE CERTIFICATE ProjeTDESertifikasi WITH SUBJECT = 'ProjeDB TDE Sertifikasi';
GO

USE ProjeDB;
GO
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE ProjeTDESertifikasi;
GO

ALTER DATABASE ProjeDB SET ENCRYPTION ON;
GO

-- Þifreleme durumunu kontrol ediyoruz
SELECT 
    db_name(database_id) AS Veritabaný_Adý,
    encryption_state,
    CASE encryption_state
        WHEN 1 THEN 'Þifrelenmemiþ'
        WHEN 2 THEN 'Þifreleme Devam Ediyor'
        WHEN 3 THEN 'Þifrelenmiþ (TDE Aktif)'
        ELSE 'Bilinmiyor'
    END AS Durum
FROM sys.dm_database_encryption_keys;
GO

-- 4. SQL INJECTION TESTLERÝ

-- A) Güvensiz Prosedür 
CREATE PROCEDURE dbo.GuvensizKullaniciAra
    @ArananNot NVARCHAR(50)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = 'SELECT * FROM dbo.ProjeTablosu WHERE Notlar = ''' + @ArananNot + '''';
    EXEC(@SQL);
END;
GO

-- B) Güvenli Prosedür 
CREATE PROCEDURE dbo.GuvenliKullaniciAra
    @ArananNot NVARCHAR(50)
AS
BEGIN
    SELECT * FROM dbo.ProjeTablosu WHERE Notlar = @ArananNot;
END;
GO

USE master;
GO

-- 5. Sunucu düzeyinde denetim oluþturma
CREATE SERVER AUDIT ProjeDenetimi
TO APPLICATION_LOG
WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE);
GO

ALTER SERVER AUDIT ProjeDenetimi WITH (STATE = ON);
GO

USE ProjeDB;
GO

-- Veritabaný düzeyinde kýsýtlý kullanýcýnýn hareketlerini izleme
CREATE DATABASE AUDIT SPECIFICATION ProjeVeritabanýDenetimi
FOR SERVER AUDIT ProjeDenetimi
ADD (SELECT, INSERT, UPDATE, DELETE ON DATABASE::ProjeDB BY ProjeTestKullanicisi)
WITH (STATE = ON);
GO
