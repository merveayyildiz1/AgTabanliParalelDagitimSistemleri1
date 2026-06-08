USE ProjeDB;
GO

-- Performans farkýný görebilmek için döngüyle 1000 adet test verisi ekliyoruz
DECLARE @i INT = 1;
WHILE @i <= 1000
BEGIN
    INSERT INTO dbo.ProjeTablosu (ID, Notlar) 
    VALUES (@i, 'Test Notu Icerigi - Kayit No: ' + CAST(@i AS NVARCHAR(10)));
    SET @i = @i + 1;
END;
GO


-- A) Varsa eski veya gereksiz indeksleri temizleme 
DROP INDEX IF EXISTS IX_ProjeTablosu_Eski ON dbo.ProjeTablosu;
GO

-- B) Notlar sütununa göre aramalarý uçuracak indeks oluþturuyoruz
CREATE NONCLUSTERED INDEX IX_ProjeTablosu_Notlar 
ON dbo.ProjeTablosu (Notlar);
GO



-- KÖTÜ/YAVAÞ SORGU (Ýndeksi iptal eder, tüm tabloyu tarar - Table Scan)
SELECT * FROM dbo.ProjeTablosu WHERE Notlar LIKE '%Kayit No: 500%';
GO

-- ÝYÝ/YAPILANDIRILMIÞ SORGU 
SELECT * FROM dbo.ProjeTablosu WITH (INDEX(IX_ProjeTablosu_Notlar))
WHERE Notlar = 'Test Notu Icerigi - Kayit No: 500';
GO



-- En çok CPU tüketen ve yavaþ çalýþan ilk 5 sorgu
SELECT TOP 5
    total_worker_time / execution_count AS [Ortalama CPU Zamaný (ms)],
    execution_count AS [Çalýþtýrýlma Sayýsý],
    SUBSTRING(st.text, (qs.statement_start_offset/2)+1, 
        ((CASE qs.statement_end_offset 
            WHEN -1 THEN DATALENGTH(st.text) 
            ELSE qs.statement_end_offset END 
        - qs.statement_start_offset)/2) + 1) AS [Çalýþan SQL Kodu]
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY total_worker_time DESC;
GO