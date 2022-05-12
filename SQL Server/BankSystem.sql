use BankSystem;

CREATE TABLE Customer (
Id int IDENTITY(1,1) PRIMARY KEY,
Name VARCHAR(100),
DOB DATE,
Phone VARCHAR(12),
Email VARCHAR(50),
Address VARCHAR(200),
Username VARCHAR(20),
Password VARCHAR(20),
Reg_Date DATETIME
)

CREATE TABLE Branch (
Id int IDENTITY(1,1) PRIMARY KEY,
Name VARCHAR(20),
Description VARCHAR(100),
IFSC VARCHAR(10),
Phone VARCHAR(12)
)

CREATE TABLE Account (
Id int IDENTITY(1,1) PRIMARY KEY,
AccNumber VARCHAR(12),
AccType VARCHAR(10),
Reg_Date DATETIME,
Balance FLOAT(8),
CustId int FOREIGN KEY REFERENCES Customer(Id),
BranchId int FOREIGN KEY REFERENCES Branch(Id)
)

CREATE TABLE Transactions (
Id int IDENTITY(1,1) PRIMARY KEY,
TranDate DATETIME,
Amount FLOAT(8),
TranType VARCHAR(10),
AccId int FOREIGN KEY REFERENCES Account(Id)
)

INSERT INTO Branch VALUES ('Mumbai', 'GF, Gresham House United India Life Bldg, Sir Phirozshah Mehta Rd, Mumbai, Maharashtra 400023', 'SBIN007000', '044-22633164')
INSERT INTO Branch VALUES ('Chennai', '84 Rajaji Salai, Chennai, Tamilnadu 600 001', 'SBIN000080', '044-25220141')
INSERT INTO Branch VALUES ('Delhi', '11sansad Marg, New Delhi 110 001', 'SBIN000069', '011-23374050')
SELECT * FROM Branch







--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

USE [BankSystem]
GO

/****** Object:  StoredProcedure [dbo].[ADD_TRANSACTION_RECORD]    Script Date: 20-06-2021 20:31:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ADD_TRANSACTION_RECORD]
	-- Add the parameters for the stored procedure here
(
	@Username varchar(20),
	@AccNumber varchar(12),
	@Amount float
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @id1 int	
	DECLARE @id2 int	

    -- Insert statements for procedure here
	SELECT @id1 = Id FROM Account WHERE AccNumber = @AccNumber

	INSERT INTO Transactions(TranDate, Amount, TranType, AccId) VALUES (
	SYSDATETIME(),
	@Amount,
	'Credited',
	@id1
	)

	SELECT @id2 = A.Id FROM Account A INNER JOIN Customer C on A.CustId = C.Id WHERE C.Username = @Username

	INSERT INTO Transactions(TranDate, Amount, TranType, AccId) VALUES (
	SYSDATETIME(),
	@Amount,
	'Debited',
	@id2
	)
END
GO





-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------


USE [BankSystem]
GO

/****** Object:  StoredProcedure [dbo].[INSERT_INTO_BANK_TABLES]    Script Date: 20-06-2021 20:32:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INSERT_INTO_BANK_TABLES]
(
	-- Add the parameters for the stored procedure here
	@name	 varchar(100),
	@dob	 date,
	@phone	 varchar(12),
	@email	 varchar(50),
	@address varchar(200),
	@username varchar(20),
	@password varchar(20),
	--@accNumber varchar,
	@accType varchar(10),
	@branchId int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	INSERT INTO Customer (Name, DOB, Phone, Email, Address, Username, Password, Reg_Date) VALUES (
	@name,
	@dob,
	@phone,
	@email,
	@address,
	@username,
	@password,
	sysdatetime()
	)

	Declare @id int
	Declare @accNumber varchar(12)
	SET @accNumber = null

	SELECT @id = Id FROM Customer WHERE Username = @username

	SELECT Top 1 @accNumber = AccNumber FROM Account ORDER BY Id DESC
	
	IF (@accNumber is null)
		SET @accNumber = '100000000000'
	ELSE
		SELECT @accNumber = CAST((CAST(@accNumber AS bigint) + 1) AS varchar)

	INSERT INTO Account (AccNumber, AccType, Reg_Date, Balance, CustId, BranchId) VALUES (
	@accNumber,
	@accType,
	sysdatetime(),
	3000.00,
	@id,
	@branchId
	)

END
GO





--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------


USE [BankSystem]
GO

/****** Object:  StoredProcedure [dbo].[UPDATE_TRANSACTION]    Script Date: 20-06-2021 20:33:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPDATE_TRANSACTION]
	-- Add the parameters for the stored procedure here
(
	@Username varchar(20),
	@AccNumber varchar(12),
	@IFSC varchar(10),
	@AccHolder varchar(100),
	@Amount float,
	@text nvarchar(500) OUTPUT 
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT COUNT(*) FROM Customer C Inner Join Account A on C.Id = A.CustId Inner Join Branch B on A.BranchId = B.Id 
	WHERE A.AccNumber = @AccNumber AND B.IFSC = @IFSC AND C.Name = @AccHolder

	IF (COUNT(*) > 0)
		UPDATE Account SET Balance = Balance + @Amount WHERE AccNumber = @AccNumber
	ELSE
		SET @text = 'Transaction Failed.'

	IF (COUNT(*) > 0)
		UPDATE Account SET Balance = Balance - @Amount FROM Account A INNER JOIN Customer C on A.CustId = C.Id WHERE C.Username = @Username
	 
	
END
GO


