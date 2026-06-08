USE ProjeDB;
GO

-- Test amaçlý hatalý ve mükerrer veriler yüklüyoruz
INSERT INTO dbo.ProjeTablosu (ID, Notlar) VALUES 
(1, 'Baþarýlý Kayýt'),
(2, NULL),                             
(3, '   Çok Fazla Boþluk Var   '),    
(4, 'Mükerrer Kayýt'),
(5, 'Mükerrer Kayýt');                



SELECT * FROM dbo.ProjeTablosu;
GO

-- A) Eksik verileri 'Bilinmiyor' olarak güncelliyoruz
UPDATE dbo.ProjeTablosu 
SET Notlar = 'Bilinmiyor' 
WHERE Notlar IS NULL;
GO

-- B) Baþýndaki ve sonundaki gereksiz boþluklarý kýrpýyoruz
UPDATE dbo.ProjeTablosu 
SET Notlar = TRIM(Notlar);
GO

-- C) Tekrar eden kayýtlarý temizliyoruz
DELETE t1 
FROM dbo.ProjeTablosu t1
INNER JOIN dbo.ProjeTablosu t2 
    ON t1.Notlar = t2.Notlar AND t1.ID > t2.ID;
GO




-- Temizlenmiþ halini kontrol ediyoruz 
SELECT * FROM dbo.ProjeTablosu;
GO


-- 1. ETL çýktýsýnýn yükleneceði tabloyu oluþturuyoruz
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProjeTablosu_Arsiv')
BEGIN
    CREATE TABLE dbo.ProjeTablosu_Arsiv (
        ArsivID INT IDENTITY(1,1) PRIMARY KEY,
        OrijinalID INT,
        TemizNotlar NVARCHAR(100),
        AktarimTarihi DATETIME DEFAULT GETDATE()
    );
END;
GO

-- 2. Veriyi ana tablodan çekip arþiv tablosuna yüklüyoruz
INSERT INTO dbo.ProjeTablosu_Arsiv (OrijinalID, TemizNotlar)
SELECT ID, Notlar 
FROM dbo.ProjeTablosu;
GO

-- 3. ETL Baþarýyla tamamlandý mý kontrol ediyoruz
SELECT * FROM dbo.ProjeTablosu_Arsiv;
GO