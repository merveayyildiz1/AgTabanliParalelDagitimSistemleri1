CREATE DATABASE [OtomasyonDB];
GO
USE [OtomasyonDB];
CREATE TABLE LogTablosu (ID INT PRIMARY KEY IDENTITY, Mesaj NVARCHAR(250), Tarih DATETIME DEFAULT GETDATE());
INSERT INTO LogTablosu (Mesaj) VALUES ('Otomasyon sistemi baslatildi.');
GO


SELECT 
    database_name AS [Veritabaný Adý],
    backup_start_date AS [Yedekleme Baþlangýcý],
    backup_finish_date AS [Bitiþ Zamaný],
    CAST(backup_size / 1024 / 1024 AS DECIMAL(10,2)) AS [Boyut (MB)],
    physical_device_name AS [Dosya Konumu]
FROM msdb.dbo.backupset bs
JOIN msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE database_name = 'OtomasyonDB'
ORDER BY backup_start_date DESC;