USE [master]
GO
/****** Object:  Database [KQHT]    Script Date: 10/5/2020 10:49:27 PM ******/
CREATE DATABASE [KQHT] ON  PRIMARY 
( NAME = N'KQHT', FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQL_EXP_2008R2\MSSQL\DATA\KQHT.mdf' , SIZE = 2304KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'KQHT_log', FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQL_EXP_2008R2\MSSQL\DATA\KQHT_log.LDF' , SIZE = 504KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [KQHT] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [KQHT].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [KQHT] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [KQHT] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [KQHT] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [KQHT] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [KQHT] SET ARITHABORT OFF 
GO
ALTER DATABASE [KQHT] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [KQHT] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [KQHT] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [KQHT] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [KQHT] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [KQHT] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [KQHT] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [KQHT] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [KQHT] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [KQHT] SET  ENABLE_BROKER 
GO
ALTER DATABASE [KQHT] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [KQHT] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [KQHT] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [KQHT] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [KQHT] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [KQHT] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [KQHT] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [KQHT] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [KQHT] SET  MULTI_USER 
GO
ALTER DATABASE [KQHT] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [KQHT] SET DB_CHAINING OFF 
GO
USE [KQHT]
GO
/****** Object:  UserDefinedFunction [dbo].[AVG_Diem]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[AVG_Diem](@MaMH NCHAR(3))
RETURNS float
AS
BEGIN
	DECLARE @num float

	SET @num = 
	(
		SELECT SUM(KQ.Diem)/COUNT(DISTINCT KQ.MaSV)
		FROM KetQua KQ
		WHERE KQ.MaMH = @MaMH
	)

	RETURN @num
END
GO
/****** Object:  UserDefinedFunction [dbo].[AVG_SV]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[AVG_SV]
(@MaSV nchar(3))
RETURNS FLOAT
AS
BEGIN
	declare @diem float

	set @diem = 
	(
		select sum(KQ.Diem)/COUNT(DISTINCT KQ.MaMH)
		from KetQua KQ
		where KQ.MaSV = @MaSV
	)

	RETURN @diem
END
GO
/****** Object:  UserDefinedFunction [dbo].[GIOI]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GIOI] ()
RETURNS INT
as
begin

	DECLARE @I INT = (select count(sv.masv)
	from SinhVien sv
	where dbo.AVG_SV(sv.MaSV) >= 8)

	RETURN @I
end
GO
/****** Object:  UserDefinedFunction [dbo].[KHA]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[KHA]()
RETURNS INT
as
begin
	DECLARE @I INT = (
	select count(sv.masv)
	from SinhVien sv
	where dbo.AVG_SV(sv.MaSV) >= 7 AND  dbo.AVG_SV(sv.MaSV) < 8
	)
	RETURN @I
end
GO
/****** Object:  UserDefinedFunction [dbo].[Passed]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[Passed](@MaMH NCHAR(3))
RETURNS INT
AS
BEGIN
	DECLARE @num INT

	SET @num = 
	(
		SELECT COUNT(DISTINCT KQ.MaSV)
		FROM KetQua KQ
		WHERE KQ.MaMH = @MaMH
		AND KQ.Diem >= 5
	)

	RETURN @num
END
GO
/****** Object:  UserDefinedFunction [dbo].[PercentPassed]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[PercentPassed](@MaMH NCHAR(3))
RETURNS FLOAT
AS
BEGIN
	DECLARE @num FLOAT

	DECLARE @P INT = dbo.Passed(@MaMH)
	DECLARE @UP INT = dbo.UnPassed(@MaMH)

	SET @num =  (@P * 100) / (@P + @UP)

	RETURN @num
END
GO
/****** Object:  UserDefinedFunction [dbo].[TB]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[TB]()
RETURNS INT
as
begin
DECLARE @I INT = (
	select count(sv.masv)
	from SinhVien sv
	where dbo.AVG_SV(sv.MaSV) >= 5 AND  dbo.AVG_SV(sv.MaSV) < 7
	)
	RETURN @I

end
GO
/****** Object:  UserDefinedFunction [dbo].[UnPassed]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[UnPassed](@MaMH NCHAR(3))
RETURNS INT
AS
BEGIN
	DECLARE @num INT

	SET @num = 
	(
		SELECT COUNT(DISTINCT KQ.MaSV)
		FROM KetQua KQ
		WHERE KQ.MaMH = @MaMH
		AND KQ.Diem < 5
	)

	RETURN @num
END
GO
/****** Object:  UserDefinedFunction [dbo].[YEU]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[YEU]()
RETURNS INT
as
begin
DECLARE @I INT = (
	select count(sv.masv)
	from SinhVien sv
	where dbo.AVG_SV(sv.MaSV) < 5
	)
	RETURN @I

end
GO
/****** Object:  Table [dbo].[KetQua]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KetQua](
	[MaSV] [varchar](3) NOT NULL,
	[MaMH] [varchar](3) NOT NULL,
	[Diem] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaSV] ASC,
	[MaMH] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MonHoc]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MonHoc](
	[MaMH] [varchar](3) NOT NULL,
	[TenMH] [nvarchar](40) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaMH] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SinhVien]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SinhVien](
	[MaSV] [varchar](3) NOT NULL,
	[HoTen] [nvarchar](30) NULL,
	[NgaySinh] [date] NULL,
	[GioiTinh] [nchar](3) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaSV] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[KetQua] ([MaSV], [MaMH], [Diem]) VALUES (N'001', N'M1', 9)
INSERT [dbo].[KetQua] ([MaSV], [MaMH], [Diem]) VALUES (N'001', N'M2', 7.5)
INSERT [dbo].[KetQua] ([MaSV], [MaMH], [Diem]) VALUES (N'001', N'M3', 3.5)
INSERT [dbo].[KetQua] ([MaSV], [MaMH], [Diem]) VALUES (N'002', N'M1', 8.5)
INSERT [dbo].[KetQua] ([MaSV], [MaMH], [Diem]) VALUES (N'003', N'M1', 5)
INSERT [dbo].[KetQua] ([MaSV], [MaMH], [Diem]) VALUES (N'003', N'M2', 3.5)
INSERT [dbo].[KetQua] ([MaSV], [MaMH], [Diem]) VALUES (N'004', N'M1', 4.5)
INSERT [dbo].[KetQua] ([MaSV], [MaMH], [Diem]) VALUES (N'005', N'M1', 5)
INSERT [dbo].[KetQua] ([MaSV], [MaMH], [Diem]) VALUES (N'005', N'M2', 9)
INSERT [dbo].[KetQua] ([MaSV], [MaMH], [Diem]) VALUES (N'006', N'M1', 7.5)
INSERT [dbo].[KetQua] ([MaSV], [MaMH], [Diem]) VALUES (N'006', N'M4', 9)
INSERT [dbo].[KetQua] ([MaSV], [MaMH], [Diem]) VALUES (N'007', N'M4', 6.5)
INSERT [dbo].[KetQua] ([MaSV], [MaMH], [Diem]) VALUES (N'008', N'M4', 8.5)
INSERT [dbo].[KetQua] ([MaSV], [MaMH], [Diem]) VALUES (N'009', N'M4', 6.5)
INSERT [dbo].[KetQua] ([MaSV], [MaMH], [Diem]) VALUES (N'010', N'M5', 10)
INSERT [dbo].[MonHoc] ([MaMH], [TenMH]) VALUES (N'M1', N'Cơ sở dữ liệu NC')
INSERT [dbo].[MonHoc] ([MaMH], [TenMH]) VALUES (N'M2', N'Hệ thống thông tin')
INSERT [dbo].[MonHoc] ([MaMH], [TenMH]) VALUES (N'M3', N'Mạng máy tính NC')
INSERT [dbo].[MonHoc] ([MaMH], [TenMH]) VALUES (N'M4', N'HTTT doanh nghiệp')
INSERT [dbo].[MonHoc] ([MaMH], [TenMH]) VALUES (N'M5', N'HQT CSDL')
INSERT [dbo].[SinhVien] ([MaSV], [HoTen], [NgaySinh], [GioiTinh]) VALUES (N'001', N'Nguyễn An', CAST(N'2000-01-23' AS Date), N'Nam')
INSERT [dbo].[SinhVien] ([MaSV], [HoTen], [NgaySinh], [GioiTinh]) VALUES (N'002', N'Lê Phúc', CAST(N'1999-07-07' AS Date), N'Nữ ')
INSERT [dbo].[SinhVien] ([MaSV], [HoTen], [NgaySinh], [GioiTinh]) VALUES (N'003', N'Trần Thành', CAST(N'2000-09-27' AS Date), N'Nam')
INSERT [dbo].[SinhVien] ([MaSV], [HoTen], [NgaySinh], [GioiTinh]) VALUES (N'004', N'Nguyễn Đức', CAST(N'2001-12-31' AS Date), N'Nam')
INSERT [dbo].[SinhVien] ([MaSV], [HoTen], [NgaySinh], [GioiTinh]) VALUES (N'005', N'Hoàng Linh', CAST(N'2000-08-14' AS Date), N'Nữ ')
INSERT [dbo].[SinhVien] ([MaSV], [HoTen], [NgaySinh], [GioiTinh]) VALUES (N'006', N'Lê Hoa', CAST(N'2000-06-06' AS Date), N'Nữ ')
INSERT [dbo].[SinhVien] ([MaSV], [HoTen], [NgaySinh], [GioiTinh]) VALUES (N'007', N'Nguyễn An Ninh', CAST(N'2000-01-23' AS Date), N'Nam')
INSERT [dbo].[SinhVien] ([MaSV], [HoTen], [NgaySinh], [GioiTinh]) VALUES (N'008', N'Nguyễn Vy', CAST(N'2000-03-17' AS Date), N'Nữ ')
INSERT [dbo].[SinhVien] ([MaSV], [HoTen], [NgaySinh], [GioiTinh]) VALUES (N'009', N'Trần Hùng', CAST(N'2001-10-23' AS Date), N'Nam')
INSERT [dbo].[SinhVien] ([MaSV], [HoTen], [NgaySinh], [GioiTinh]) VALUES (N'010', N'Trần Hoa', CAST(N'2000-01-23' AS Date), N'Nữ ')
ALTER TABLE [dbo].[KetQua]  WITH CHECK ADD FOREIGN KEY([MaSV])
REFERENCES [dbo].[SinhVien] ([MaSV])
GO
ALTER TABLE [dbo].[KetQua]  WITH CHECK ADD FOREIGN KEY([MaMH])
REFERENCES [dbo].[MonHoc] ([MaMH])
GO
ALTER TABLE [dbo].[SinhVien]  WITH CHECK ADD  CONSTRAINT [checkgender] CHECK  (([GioiTinh]=N'Nam' OR [GioiTinh]=N'Nữ'))
GO
ALTER TABLE [dbo].[SinhVien] CHECK CONSTRAINT [checkgender]
GO
ALTER TABLE [dbo].[SinhVien]  WITH CHECK ADD CHECK  (([NgaySinh]<'1/31/2002'))
GO
/****** Object:  StoredProcedure [dbo].[Avg_]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[Avg_]
@m nchar(3)
as
begin
	SELECT dbo.AVG_Diem(@m)
end
GO
/****** Object:  StoredProcedure [dbo].[N_GIOI]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[N_GIOI]
AS
BEGIN
select dbo.GIOI()
END
GO
/****** Object:  StoredProcedure [dbo].[N_KHA]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[N_KHA]
AS
BEGIN
select dbo.KHA() 
END
GO
/****** Object:  StoredProcedure [dbo].[N_TB]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[N_TB]
AS
BEGIN
select dbo.TB() 
END
GO
/****** Object:  StoredProcedure [dbo].[N_YEU]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[N_YEU]
AS
BEGIN
select dbo.YEU() 
END
GO
/****** Object:  StoredProcedure [dbo].[P]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[P]
@m nchar(3)
as
begin
	SELECT dbo.Passed(@m)

end
GO
/****** Object:  StoredProcedure [dbo].[Per]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[Per]
@m nchar(3)
as
begin
	SELECT dbo.PercentPassed(@m)
end
GO
/****** Object:  StoredProcedure [dbo].[T_GIOI]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[T_GIOI]
AS
BEGIN

select round((dbo.GIOI()*100) / COUNT(distinct kq.MASV),2) FROM KetQua kq
END
GO
/****** Object:  StoredProcedure [dbo].[T_KHA]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[T_KHA]
AS
BEGIN

select round((dbo.KHA()*100) / COUNT(distinct kq.MASV),2) FROM KetQua kq
END
GO
/****** Object:  StoredProcedure [dbo].[T_TB]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[T_TB]
AS
BEGIN

select round((dbo.TB()*100) / COUNT(distinct kq.MASV),2) FROM KetQua kq
END
GO
/****** Object:  StoredProcedure [dbo].[T_YEU]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[T_YEU]
AS
BEGIN
select round((dbo.YEU()*100) / COUNT(distinct kq.MASV),2) FROM KetQua kq
END
GO
/****** Object:  StoredProcedure [dbo].[UP]    Script Date: 10/5/2020 10:49:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[UP]
@m nchar(3)
as
begin
	SELECT dbo.UnPassed(@m)
end
GO
USE [master]
GO
ALTER DATABASE [KQHT] SET  READ_WRITE 
GO
