create database QLBH_LuongHaiSon;
use QLBH_LuongHaiSon;


create table Customer(
cID int(4) primary key,
cName varchar(50),
cAge int(4)
);

create table `Order`(
oID int(4) primary key,
cID int,
FOREIGN KEY (cID) REFERENCES Customer(cID),
oDate date,
oTotalPrice int
);

create table Product(
pID int(4) primary key,
pName varchar(50),
pPrice int
);


create table OrderDetail(
oID int,
FOREIGN KEY (oID) REFERENCES `Order`(oID),
pID int,
FOREIGN KEY (pID) REFERENCES `Product`(pID),
odQTY int
);

-- 1: Tạo 4 bảng và chèn dữ liệu
INSERT INTO Customer(cID,cName, cAge)
VALUES (1,'Minh Quan',10),
(2,'Ngoc Oanh',20),
(3,'Hong Ha',50);

INSERT INTO `Order`(oID,cID, oDate,oTotalPrice)
VALUES (1,1,'2006/3/21',null),
(2,2,'2006/3/23',null),
(3,1,'2006/3/16',null);

INSERT INTO Product(pID,pName, pPrice)
VALUES (1,'May Giat',3),
(2,'Tu Lanh',5),
(3,'Dieu Hoa',7),
(4,'Quat',1),
(5,'Bep Dien',2);

INSERT INTO OrderDetail(oID, pID,odQTY)
VALUES (1,1,3),(1,3,7),(1,4,2),(2,1,1),(3,1,8),(2,5,4),(2,3,3);

-- 2. Hiển thị các thông tin gồm oID, oDate, oPrice của tất cả các hóa đơn trong bảng Order, danh sách phải sắp xếp theo thứ tự ngày tháng, hóa đơn
SELECT oID, cID, oDate, oTotalPrice
FROM `Order`
ORDER BY oDate DESC, oID ASC;

-- 3. Hiển thị tên và giá của các sản phẩm có giá cao nhất
SELECT pName, pPrice
FROM Product
WHERE pPrice = (SELECT MAX(pPrice) FROM Product);

-- 4. Hiển thị danh sách các khách hàng đã mua hàng, và danh sách sản phẩm được mua bởi các khách đó
SELECT c.cName, p.pName
FROM Customer c
JOIN `Order` o ON c.cID = o.cID
JOIN OrderDetail od ON o.oID = od.oID
JOIN Product p ON od.pID = p.pID

-- 5. Hiển thị tên những khách hàng không mua bất kỳ một sản phẩm nào

SELECT c.cName
FROM Customer c
WHERE NOT EXISTS (
  SELECT 1 
  FROM `Order` o 
  JOIN OrderDetail od ON o.oID = od.oID 
  WHERE o.cID = c.cID 
  AND od.odQTY > 0
);

-- 6. Hiển thị chi tiết của từng hóa đơn
SELECT o.oID, o.oDate, od.odQTY, p.pName, p.pPrice
FROM Customer c
JOIN `Order` o ON c.cID = o.cID
JOIN OrderDetail od ON o.oID = od.oID
JOIN Product p ON od.pID = p.pID

-- 7. Hiển thị mã hóa đơn, ngày bán và giá tiền của từng hóa đơn
SELECT o.oID, o.oDate, Sum(od.odQTY*p.pPrice) as Total
FROM `Order` o
JOIN OrderDetail od ON o.oID = od.oID
JOIN Product p ON od.pID = p.pID
group by o.oID, o.oDate;

-- 8. Tạo một view tên là Sales để hiển thị tổng doanh thu của siêu thị
CREATE VIEW Sales AS
SELECT SUM(od.odQTY * p.pPrice) AS Sales
FROM OrderDetail od
JOIN Product p ON od.pID = p.pID;
select * from Sales;

-- 9. Xóa tất cả các ràng buộc khóa ngoại, khóa chính của tất cả các bảng.
-- xóa khóa ngoại
ALTER TABLE `order`
DROP CONSTRAINT order_ibfk_1;
ALTER TABLE orderdetail
DROP CONSTRAINT orderdetail_ibfk_1,
DROP CONSTRAINT orderdetail_ibfk_2;
-- xóa khóa chính
ALTER TABLE Customer DROP PRIMARY KEY;
ALTER TABLE Product DROP PRIMARY KEY;
ALTER TABLE `Order` DROP PRIMARY KEY;

-- 10. Tạo một trigger tên là cusUpdate trên bảng Customer, sao cho khi sửa mã khách (cID) thì mã khách trong bảng Order cũng được sửa theo
CREATE TRIGGER cusUpdate
AFTER UPDATE ON Customer
FOR EACH ROW
UPDATE `Order` SET cID = NEW.cID WHERE cID = OLD.cID;
update Customer
set cId = 4 where cId = 1;
-- 11. Tạo một stored procedure tên là delProduct nhận vào 1 tham số là tên của một sản phẩm, strored procedure này sẽ xóa sản phẩm có tên được truyên vào thông qua tham số, và các thông tin liên quan đến sản phẩm đó ở trong bảng OrderDetail 
DELIMITER // 
create procedure delProduct(in pNameDel varchar(25))
begin
delete from Product where pName = pNameDel;
delete from OrderDetail where pId = (select pId from Product where pName = pNameDel);
end //
DELIMITER ;
call delProduct("Dieu Hoa");