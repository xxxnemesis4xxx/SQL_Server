SET LANGUAGE FRENCH
GO

IF DB_ID('Entrepot') IS NULL
	CREATE DATABASE Entrepot;	
GO

USE Entrepot
GO

IF OBJECT_ID('Faits','U') IS NOT NULL
	DROP TABLE Faits
GO	
IF OBJECT_ID('Dates','U') IS NOT NULL
	DROP TABLE Dates
GO
IF OBJECT_ID('Client','U') IS NOT NULL
	DROP TABLE Client
GO
IF OBJECT_ID('Produit','U') IS NOT NULL
	DROP TABLE Produit
GO
IF OBJECT_ID('Employe','U') IS NOT NULL
	DROP TABLE Employe
GO
	
IF OBJECT_ID('remplirClient') IS NOT NULL
	DROP PROCEDURE dbo.remplirClient
GO
IF OBJECT_ID('remplirDate') IS NOT NULL
	DROP PROCEDURE dbo.remplirDate
GO
IF OBJECT_ID('remplirProduit') IS NOT NULL
	DROP PROCEDURE dbo.remplirProduit
GO
IF OBJECT_ID('remplirEmploye') IS NOT NULL
	DROP PROCEDURE dbo.remplirEmploye
GO
IF OBJECT_ID('remplirFaits') IS NOT NULL
	DROP PROCEDURE dbo.remplirFaits
GO
IF OBJECT_ID('obtenirContinent') IS NOT NULL
	DROP PROCEDURE dbo.obtenirContinent
GO
/************************************************
*************************************************/
CREATE TABLE dbo.Dates
(DateId int IDENTITY(1,1) PRIMARY KEY,
Saison nvarchar(12) NOT NULL,
FinDeSemaine varchar(30) NOT NULL,
DernierJourDuMois nvarchar(30) NOT NULL,
Mois nvarchar(30) NOT NULL,
AnneeFinanciere varchar(30) NOT NULL,
RangJourDeLaSemaine varchar(30) NOT NULL,
RangJourDansAnnee varchar(30) NOT NULL,
SigneZodiaque nvarchar(30) NOT NULL,
JourDivisiblePar5 varchar(30) NOT NULL,
RangDeLaSemaineDansAnnee varchar(30) NOT NULL,
PremierJourDuMois varchar(30) NOT NULL
)
GO


CREATE PROCEDURE RemplirDate AS
DECLARE @DateDebut DATETIME = '01/01/2012'
DECLARE @DateFin DATETIME = '31/03/2015'

DECLARE @AnneeEnCour INT
DECLARE	@MoisEnCour INT
DECLARE @JourneeDeLaSemaineDansAnnee INT


DECLARE @JourneeEnCour as DATETIME = @DateDebut
SET @MoisEnCour = DATEPART(MM,@JourneeEnCour)
SET @AnneeEnCour = DATEPART(YY,@JourneeEnCour)

WHILE @JourneeEnCour < @DateFin
BEGIN
	--Regarde pour le changement du mois
	IF @MoisEnCour != DATEPART(MM,@JourneeEnCour)
	BEGIN
		SET @MoisEnCour = DATEPART(MM,@JourneeEnCour)
	END
	
	--Regarde pour le changement de l'année
	IF @AnneeEnCour != DATEPART(YY,@JourneeEnCour)
	BEGIN
		set @AnneeEnCour = DATEPART(YY,@JourneeEnCour)
	END
	
	SET @JourneeDeLaSemaineDansAnnee = DATEPART(WW,@JourneeEnCour)

	INSERT INTO [dbo].[Dates]
	SELECT
	
	CASE
		WHEN (DATEPART(MM,@JourneeEnCour) = 12 and DATEPART(DD,@JourneeEnCour) > 20) or
		DATEPART(MM,@JourneeEnCour) between 1 and 2 or (DATEPART(MM,@JourneeEnCour) = 3 and DATEPART(DD,@JourneeEnCour) < 21)
		THEN 'Hiver'
		WHEN (DATEPART(MM,@JourneeEnCour) = 3 and DATEPART(DD,@JourneeEnCour) > 20) or
		DATEPART(MM,@JourneeEnCour) between 4 and 5 or (DATEPART(MM,@JourneeEnCour) = 6 and DATEPART(DD,@JourneeEnCour) < 21)
		THEN 'Printemps'
		WHEN (DATEPART(MM,@JourneeEnCour) = 6 and DATEPART(DD,@JourneeEnCour) > 20) or
		DATEPART(MM,@JourneeEnCour) between 7 and 8 or (DATEPART(MM,@JourneeEnCour) = 9 and DATEPART(DD,@JourneeEnCour) < 21)
		THEN 'Été'
		WHEN (DATEPART(MM,@JourneeEnCour) = 9 and DATEPART(DD,@JourneeEnCour) > 20) or
		DATEPART(MM,@JourneeEnCour) between 10 and 11 or (DATEPART(MM,@JourneeEnCour) = 12 and DATEPART(DD,@JourneeEnCour) < 21)
		THEN 'Automne'
	END AS Saison,
	
	CASE
		WHEN DATEPART(DW,@JourneeEnCour) between 6 and 7
		THEN 'Fin de semaine'
		ELSE 'Pas fin de semaine'
	END AS FinDeSemaine,
	 
	CASE
		WHEN DATEPART(DD,@JourneeEnCour + 1) = 1
		THEN 'Dernier jour du mois'
		ELSE 'Pas dernier jour du mois'
	END AS DernierJourDuMois,
	
	DATENAME(MM,@JourneeEnCour) AS Mois,
	
	CASE
		WHEN DATEPART(MM,@JourneeEnCour)> 2
		THEN DATEPART(YYYY,@JourneeEnCour)
		ELSE DATEPART(YYYY,@JourneeEnCour) - 1
	END AS AnneeFinanciere,

	DATEPART(DW,@JourneeEnCour) AS RangJourDeLaSemaine,
	
	DATEPART(DY,@JourneeEnCour) AS RangJourDansAnnee,
	
	CASE
		WHEN (DATEPART(MM,@JourneeEnCour) = 1 and DATEPART(DD,@JourneeEnCour) > 20) or
		(DATEPART(MM,@JourneeEnCour) = 2 and DATEPART(DD,@JourneeEnCour) < 20) 
		THEN 'Verseau'
		WHEN (DATEPART(MM,@JourneeEnCour) = 2 and DATEPART(DD,@JourneeEnCour) > 19) or
		(DATEPART(MM,@JourneeEnCour) = 3 and DATEPART(DD,@JourneeEnCour) < 21) 
		THEN 'Poissons'
		WHEN (DATEPART(MM,@JourneeEnCour) = 3 and DATEPART(DD,@JourneeEnCour) > 20) or
		(DATEPART(MM,@JourneeEnCour) = 4 and DATEPART(DD,@JourneeEnCour) < 21) 
		THEN 'Bélier'
		WHEN (DATEPART(MM,@JourneeEnCour) = 4 and DATEPART(DD,@JourneeEnCour) > 20) or
		(DATEPART(MM,@JourneeEnCour) = 5 and DATEPART(DD,@JourneeEnCour) < 22) 
		THEN 'Taureau'
		WHEN (DATEPART(MM,@JourneeEnCour) = 5 and DATEPART(DD,@JourneeEnCour) > 21) or
		(DATEPART(MM,@JourneeEnCour) = 6 and DATEPART(DD,@JourneeEnCour) < 22) 
		THEN 'Gémeaux'
		WHEN (DATEPART(MM,@JourneeEnCour) = 6 and DATEPART(DD,@JourneeEnCour) > 21) or
		(DATEPART(MM,@JourneeEnCour) = 7 and DATEPART(DD,@JourneeEnCour) < 23) 
		THEN 'Cancer'
		WHEN (DATEPART(MM,@JourneeEnCour) = 7 and DATEPART(DD,@JourneeEnCour) > 22) or
		(DATEPART(MM,@JourneeEnCour) = 8 and DATEPART(DD,@JourneeEnCour) < 23) 
		THEN 'Lion'
		WHEN (DATEPART(MM,@JourneeEnCour) = 8 and DATEPART(DD,@JourneeEnCour) > 22) or
		(DATEPART(MM,@JourneeEnCour) = 9 and DATEPART(DD,@JourneeEnCour) < 23) 
		THEN 'Vierge'
		WHEN (DATEPART(MM,@JourneeEnCour) = 9 and DATEPART(DD,@JourneeEnCour) > 22) or
		(DATEPART(MM,@JourneeEnCour) = 10 and DATEPART(DD,@JourneeEnCour) < 23) 
		THEN 'Balance'
		WHEN (DATEPART(MM,@JourneeEnCour) = 10 and DATEPART(DD,@JourneeEnCour) > 22) or
		(DATEPART(MM,@JourneeEnCour) = 11 and DATEPART(DD,@JourneeEnCour) < 23) 
		THEN 'Scorpion'
		WHEN (DATEPART(MM,@JourneeEnCour) = 11 and DATEPART(DD,@JourneeEnCour) > 22) or
		(DATEPART(MM,@JourneeEnCour) = 12 and DATEPART(DD,@JourneeEnCour) < 22) 
		THEN 'Sagittaire'
		WHEN (DATEPART(MM,@JourneeEnCour) = 12 and DATEPART(DD,@JourneeEnCour) > 21) or
		(DATEPART(MM,@JourneeEnCour) = 1 and DATEPART(DD,@JourneeEnCour) < 21) 
		THEN 'Capricorne'
	END AS SigneZodiaque,
	
	CASE
		WHEN DATEPART(DD,@JourneeEnCour) % 5 = 0
		THEN 'Divisible'
		ELSE 'Pas divisible'
	END AS JourDivisiblePar5,
	
	@JourneeDeLaSemaineDansAnnee AS RangDeLaSemaineDansAnnee,
	
	CASE
		WHEN DATEPART(DD,@JourneeEnCour) = 1 THEN 'Premier jour du mois'	 
		ELSE 'Pas premier jour du mois'	
	END AS PremierJourDuMois
	
	SET @JourneeEnCour = DATEADD(DD,1,@JourneeEnCour)
END
GO

EXECUTE  remplirDate
GO
/*******************************************************
********************************************************/
CREATE TABLE dbo.Produit
(ProduitId int IDENTITY(1,1) NOT NULL PRIMARY KEY,
NomProduit varchar(80) NOT NULL,
NomFournisseur varchar(80) NOT NULL,
AncienFournisseur1 varchar(80),
AncienFournisseur2 varchar(80),
AncienFournisseur3 varchar(80),
Categorie varchar(80) NOT NULL,
PaysFournisseur varchar(80) NOT NULL,
SystemeMesure varchar(80) NOT NULL
)
GO

CREATE PROCEDURE remplirProduit AS
DECLARE @ProductID int;
DECLARE @NomProduit varchar(80);
DECLARE @NomFournisseur varchar(80);
DECLARE @Categorie varchar(80);
DECLARE @PaysFournisseur varchar(80);
DECLARE @SystemeMesure varchar(80);

SELECT @ProductID = min(ProductID) from Northwind.dbo.Products;

WHILE @ProductID is not null
BEGIN
	SELECT @NomProduit = min(ProductName) from Northwind.dbo.Products
	WHERE Northwind.dbo.Products.ProductID = @ProductID;

	SELECT @Categorie = min(CategoryName) from Northwind.dbo.Categories
	JOIN Northwind.dbo.Products
	ON Northwind.dbo.Categories.CategoryID = Northwind.dbo.Products.CategoryID
	WHERE Northwind.dbo.Products.ProductID = @ProductID;

	SELECT @NomFournisseur = min(CompanyName) from Northwind.dbo.Suppliers
	JOIN Northwind.dbo.Products
	ON Northwind.dbo.Suppliers.SupplierID = Northwind.dbo.Products.SupplierID
	WHERE Northwind.dbo.Products.ProductID = @ProductID;

	SELECT @PaysFournisseur = min(Country) from Northwind.dbo.Suppliers
	JOIN Northwind.dbo.Products
	ON Northwind.dbo.Suppliers.SupplierID = Northwind.dbo.Products.SupplierID
	WHERE Northwind.dbo.Products.ProductID = @ProductID;

	SELECT @SystemeMesure = min(QuantityPerUnit) from Northwind.dbo.Products
	WHERE Northwind.dbo.Products.ProductID = @ProductID;
	INSERT INTO [dbo].[Produit]
	SELECT
		@NomProduit AS NomProduit,
		@NomFournisseur AS NomFournisseur,
		NULL AS AncienFournniseur1,
		NULL AS AncienFournniseur2,
		NULL AS AncienFournniseur3,
		@Categorie AS Categorie,
		@PaysFournisseur AS PaysFournisseur,
		
		CASE 
			WHEN CHARINDEX(' g ',@SystemeMesure) > 0 or CHARINDEX(' kg ',@SystemeMesure) > 0 or CHARINDEX(' ml ',@SystemeMesure) > 0
			or CHARINDEX(' cL ',@SystemeMesure) > 0 or CHARINDEX(' l ',@SystemeMesure) > 0 or CHARINDEX('1k',@SystemeMesure) > 0
			then 'Métrique'
			WHEN CHARINDEX(' oz ',@SystemeMesure) > 0
			THEN 'Impérial'
			ELSE
				'Aucun'
		END AS SystemeMesure
		
	SELECT @ProductID = min(ProductID) from Northwind.dbo.Products
	WHERE ProductID > @ProductID
END
GO

EXECUTE  remplirProduit
GO

/***************************************************
****************************************************/
CREATE TABLE dbo.Employe
(EmployeId int IDENTITY(1,1) NOT NULL PRIMARY KEY,
NomEmploye varchar(80) NOT NULL,
Titre varchar(80)NOT NULL,
Pays varchar(80) NOT NULL,
indicateurSupervision varchar(80) NOT NULL
)
GO

CREATE PROCEDURE remplirEmploye AS
DECLARE @EmployeId int;
DECLARE @NomEmploye varchar(80);
DECLARE @Titre varchar(80);
DECLARE @Pays varchar(80);
DECLARE @indicateurSupervision varchar(80);

SELECT @EmployeId = min(EmployeeID) from Northwind.dbo.Employees

WHILE @EmployeId is not null
BEGIN
	SELECT @NomEmploye = FirstName + ' ' + LastName from Northwind.dbo.Employees
	WHERE EmployeeID = @EmployeId

	SELECT @Titre = Title from Northwind.dbo.Employees
	WHERE EmployeeID = @EmployeId

	SELECT @Pays = Country from Northwind.dbo.Employees
	WHERE EmployeeID = @EmployeId

	SELECT @indicateurSupervision = ReportsTo from Northwind.dbo.Employees
	WHERE EmployeeID = @EmployeId
	
	IF @indicateurSupervision is not null
	BEGIN
		SELECT @indicateurSupervision = FirstName + ' ' + LastName from Northwind.dbo.Employees
			WHERE EmployeeID = @indicateurSupervision
	END
	ELSE
		SET @indicateurSupervision = 'Aucun'

	INSERT INTO [dbo].[Employe] 
	SELECT
		@NomEmploye AS NomEmploye,
		@Titre AS Titre,
		@Pays AS Pays,
		@indicateurSupervision AS indicateurSupervision
		
	SELECT @EmployeId = min(EmployeeID) from Northwind.dbo.Employees
	WHERE EmployeeID > @EmployeId
END
GO

EXECUTE  remplirEmploye
GO

/****************************************************
*****************************************************/
CREATE TABLE dbo.Client
(ClientId int IDENTITY(1,1) NOT NULL PRIMARY KEY,
NomContact varchar(80),
NomVille varchar(80),
NomPays varchar(80),
Continent varchar(80),
ReferenceClientId int CONSTRAINT fk_ClientClient FOREIGN KEY(ClientId) REFERENCES Client(ClientId),
DateModification datetime
)
GO

CREATE PROCEDURE dbo.remplirClient AS 
DECLARE @ClientId nchar(5);
DECLARE @NomContact varchar(30)
DECLARE @NomVille varchar(30)
DECLARE @NomPays varchar(30)
DECLARE @Continent varchar(30)

SELECT @ClientId = min(CustomerID) FROM Northwind.dbo.Customers;

WHILE @ClientId IS NOT NULL
BEGIN
	SELECT @NomContact = ContactName from Northwind.dbo.Customers
	WHERE Northwind.dbo.Customers.CustomerID = @ClientId

	SELECT @NomVille = City from Northwind.dbo.Customers
	WHERE Northwind.dbo.Customers.CustomerID = @ClientId

	SELECT @NomPays = Country from Northwind.dbo.Customers
	WHERE Northwind.dbo.Customers.CustomerID = @ClientId
	
	SELECT @Continent = (Continent) from Entrepot.dbo.Continent
	WHERE Pays = @NomPays
	
	INSERT INTO [dbo].[Client]
	SELECT
		CASE
			WHEN @NomContact IS NOT NULL
			THEN @NomContact
			ELSE 'Aucun'
		END AS NomContact,
		
		CASE
			WHEN @NomVille IS NOT NULL
			THEN @NomVille
			ELSE 'Aucun'
		END AS NomVile,
		
		CASE
			WHEN @NomPays IS NOT NULL
			THEN @NomPays
			ELSE 'Aucun'
		END AS NomPays,
		
		@Continent AS Continent,
		NULL AS ReferenceClientId,
		NULL AS DateModification
		
	SELECT @ClientId = min(CustomerID) FROM Northwind.dbo.Customers
	WHERE CustomerID > @ClientId
END
GO

EXECUTE remplirClient
GO

/*******************************************************************
***********************************************************************/
CREATE TABLE dbo.Faits
(FaitsId int IDENTITY(1,1) NOT NULL PRIMARY KEY,
EmployeId INT NOT NULL CONSTRAINT fk_EmployeFaits FOREIGN KEY (EmployeId) REFERENCES Employe(EmployeId),
ClientId INT NOT NULL CONSTRAINT fk_ClientFaits FOREIGN KEY (ClientId) REFERENCES Client(ClientId),
ProduitId INT NOT NULL CONSTRAINT fk_ProduitFaits FOREIGN KEY (ProduitId) REFERENCES Produit(ProduitId),
DateId INT NOT NULL CONSTRAINT fk_DateFaits FOREIGN KEY (DateId) REFERENCES Dates(DateId),
PrixVente MONEY NOT NULL,
QuantiteVendu SMALLINT NOT NULL 
)
GO

CREATE PROCEDURE remplirFaits AS
DECLARE @OrderId int;
DECLARE @EmployeId int;
DECLARE @ClientId INT
DECLARE @ProduitId int;
DECLARE @ProductId int;
DECLARE @DateId int;
DECLARE @PrixVente money;
DECLARE @QuantiteVendu smallint
DECLARE @DateCommande datetime;
DECLARE @AnneeFinance varchar(80)
DECLARE @RangJourAnnee varchar(80)

SELECT @OrderId = min(OrderID) from Northwind.dbo.[Order Details]

WHILE @OrderId IS NOT NULL
BEGIN
	SELECT @ProductId = MIN(ProductId) from Northwind.dbo.[Order Details] 
	WHERE OrderID = @OrderId
	
	WHILE @ProductId IS NOT NULL
	BEGIN
		SELECT @ProduitId = (ProduitId) from Entrepot.dbo.Produit pro
		join Northwind.dbo.Products pro2
		on pro.NomProduit = pro2.ProductName COLLATE SQL_Latin1_General_CP1_CI_AS
		join Northwind.dbo.[Order Details] od
		on (pro2.ProductID = od.ProductID)
		WHERE od.OrderID = @OrderId and od.ProductID = @ProductId
		
		SELECT @PrixVente = (UnitPrice) from Northwind.dbo.[Order Details]
		WHERE OrderID = @OrderId and ProductID = @ProductId

		SELECT @QuantiteVendu = (Quantity) from Northwind.dbo.[Order Details]
		WHERE OrderID = @OrderId and ProductID = @ProductId

		SELECT @ClientId = (ClientId) from Entrepot.dbo.Client cl
		JOIN Northwind.dbo.Customers cus
		on (cl.NomContact = cus.ContactName COLLATE French_CI_AS) AND
		(cl.NomPays = cus.Country COLLATE French_CI_AS)
		JOIN Northwind.dbo.Orders ord
		on ord.CustomerID = cus.CustomerID
		JOIN NORTHWIND.DBO.[Order Details] od
		on ord.OrderID = od.OrderID
		WHERE od.OrderID = @OrderId
		group by cl.ClientId

		SELECT @EmployeId = (EmployeId) from Entrepot.dbo.Employe em
		JOIN Northwind.dbo.Employees empl
		on em.NomEmploye = empl.FirstName + ' ' + empl.LastName COLLATE French_CI_AS
		JOIN Northwind.dbo.Orders ord
		on empl.EmployeeID = ord.EmployeeID
		JOIN Northwind.dbo.[Order Details] od
		on ord.OrderID = od.OrderID
		WHERE od.OrderID = @OrderId
		group by em.EmployeId

		SELECT @DateCommande = (OrderDate) from Northwind.dbo.Orders
		WHERE OrderID = @OrderId

		SELECT @AnneeFinance = 
		CASE
			WHEN DATEPART(MM,@DateCommande)> 2
			THEN DATEPART(YYYY,@DateCommande)
			ELSE DATEPART(YYYY,@DateCommande) - 1
		END

		SELECT @RangJourAnnee = DATEPART(DY,@DateCommande)

		SELECT @DateId = (DateId) from Entrepot.dbo.Dates
		WHERE AnneeFinanciere = @AnneeFinance AND
		RangJourDansAnnee = @RangJourAnnee
		
		INSERT INTO [dbo].[Faits]
		SELECT
			@EmployeId as EmployeId,
			@ClientId as ClientId,
			@ProduitId as ProduitId,
			@DateId as DateId,
			@PrixVente as PrixVente,
			@QuantiteVendu as QuantiteVendu
			
		SELECT @ProductId = MIN(ProductId) from Northwind.dbo.[Order Details] 
		WHERE OrderID = @OrderId and ProductID > @ProductId
	END
	
	SELECT @OrderId = min(OrderID) from Northwind.dbo.[Order Details]
	WHERE OrderID > @OrderId
END
GO

EXECUTE remplirFaits
GO

IF EXISTS(select * FROM sys.views where name = 'VenteAnnuelEmploye')
	DROP VIEW dbo.VenteAnnuelEmploye
GO

CREATE VIEW VenteAnnuelEmploye AS
SELECT  EmployeId, p.AnneeFinanciere, SUM(PrixVente * QuantiteVendu) as 'Vente' from Entrepot.dbo.Faits
JOIN Entrepot.dbo.Dates P
On Faits.DateId = P.DateId
Group by P.AnneeFinanciere,EmployeId
GO

IF EXISTS(select * FROM sys.views where name = 'VenteMensuelProduit')
	DROP VIEW dbo.VenteMensuelProduit
GO

CREATE VIEW VenteMensuelProduit AS
SELECT SUM(PrixVente * QuantiteVendu) as 'Vente', p.Mois, p.AnneeFinanciere, c.Continent from Entrepot.dbo.Faits
JOIN Entrepot.dbo.Dates p
on Faits.DateId = p.DateId
JOIN Entrepot.dbo.Client c
on Faits.ClientId = c.ClientId
WHERE p.AnneeFinanciere = '2012' or p.AnneeFinanciere = '2013'
group by p.Mois,p.AnneeFinanciere,c.Continent
GO

select * from dbo.Client
order by ClientId

select * from dbo.Employe
order by EmployeId

select * from dbo.Produit
order by ProduitId

select * from dbo.Faits
order by ClientId,EmployeId, ProduitId,DateId