create database SecureDatabase
go

Use SecureDatabase 
go

-- Sat��lar�n tutulaca�� tablo olu�turuldu.
Create Table Sales (
    SaleID int primary key identity(1,1),
    ProductName nvarchar(50),
	quantity int,
	UnitPrice decimal(10,2),
    SaleDate Datetime default GETDATE()
)


-- Sat��la ilgili i�lem(DML) yap�ld��� zaman sat�� hakk�nda bilgi veren Log tablosu olu�turuldu.
Create Table SalesLog (
    LogID int primary key identity(1,1),
    SaleID int,
	ProductName nvarchar(50),
	quantity int,
	UnitPrice decimal(10,2),
    LogDate Datetime
)

Create Table DeletedSalesLog (
    LogID int primary key identity(1,1),
    SaleID int,
	ProductName nvarchar(50),
	quantity int,
	UnitPrice decimal(10,2),
    LogDate Datetime
)

---Sat�� yap�ld�ktan sonra SalesLog tablosunda veriyi kaydeder.
create trigger trg_insertProcess
on Sales
after insert as
begin
insert into SalesLog (SaleID,ProductName,quantity,UnitPrice,LogDate)
select i.SaleID,i.ProductName,i.quantity,i.UnitPrice,GETDATE() from inserted i
Print 'Sat�� Yap�ld�'
end

--- Sales  ve SalesLog tablomuza  veri eklendi.
insert into Sales (ProductName,quantity,UnitPrice) 
values ('LogitechHeadSet',10,3000), ('iMac ',2,65000)

--- Sat�� silinirken veriyi DeletedSalesLog tablosuna kaydeder.
create trigger trg_DeleteProcess
on Sales
for delete as
begin
insert into DeletedSalesLog (SaleID,ProductName,quantity,UnitPrice,LogDate)
select i.SaleID,i.ProductName,i.quantity,i.UnitPrice,GETDATE() from deleted i
Print 'Sat�� iptal edildi'
end
--- veri silindi ve Log tablomuza kaydedildi.
Delete from Sales where SaleID = 1



---burada e�er silinen veri deletedSalesLog tablosunda da silinmezse i�lem iptal edilir.

Begin try
    Begin transaction

	delete from SalesLog where SaleID = 1
	declare @LastId int = 1
	if exists(select*from DeletedSalesLog where @LastId = SaleID)
	begin 
	rollback transaction
	print 'Dikkat Veri Logda tutuluyor.i�lem iptal edildi'
	end
    commit transaction
end try
begin catch
    rollback transaction
    print 'Hata olu�tu. i�lem geri al�nd�.'
end catch

