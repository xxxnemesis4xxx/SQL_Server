SET LANGUAGE FRENCH
GO

IF DB_ID('Entrepot') IS NULL
	CREATE DATABASE Entrepot;
GO
 
USE Entrepot
GO

IF OBJECT_ID('updateFaits') IS NOT NULL
	DROP PROCEDURE updateFaits
GO

IF OBJECT_ID('updateClient') IS NOT NULL
	DROP PROCEDURE updateClient
GO


IF OBJECT_ID('updateProduit') IS NOT NULL
	DROP PROCEDURE updateProduit
GO

CREATE PROCEDURE updateFaits AS
BEGIN
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
	DECLARE @FaitId INT;

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

			SELECT @DateId = (DateId) from Dates
			WHERE AnneeFinanciere = @AnneeFinance AND
			RangJourDansAnnee = @RangJourAnnee
			
			SELECT @FaitId = (FaitsId) FROM Entrepot.dbo.Faits WHERE EmployeId = @EmployeId AND ClientId = @ClientId
			and ProduitId = @ProduitId and DateId = @DateId and PrixVente = @PrixVente
			and QuantiteVendu = @QuantiteVendu
			
			IF @FaitId IS NULL AND @EmployeId IS NOT NULL AND @ClientId IS NOT NULL AND @ProduitId IS NOT NULL
			AND @DateId IS NOT NULL AND @PrixVente IS NOT NULL
			BEGIN
				INSERT INTO [dbo].[Faits]
				SELECT
					@EmployeId as EmployeId,
					@ClientId as ClientId,
					@ProduitId as ProduitId,
					@DateId as DateId,
					@PrixVente as PrixVente,
					@QuantiteVendu as QuantiteVendu
			END
				
			SELECT @ProductId = MIN(ProductId) from Northwind.dbo.[Order Details] 
			WHERE OrderID = @OrderId and ProductID > @ProductId
		END
		
		SELECT @OrderId = min(OrderID) from Northwind.dbo.[Order Details]
		WHERE OrderID > @OrderId
	END
END
GO

exec updateFaits
GO

CREATE PROCEDURE updateClient AS
BEGIN
	DECLARE @ClientId nchar(5);
	DECLARE @NomContact varchar(80)
	DECLARE @NomVille varchar(80)
	DECLARE @NomPays varchar(80)
	DECLARE @Continent varchar(80)
	DECLARE @NomVilleClient varchar(80)
	DECLARE @DateModification DATETIME
	DECLARE @IdClientEntrepot INT

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
		WHERE Pays = @NomPays COLLATE French_CI_AS
		
		IF @Continent IS NOT NULL
			BEGIN
				SELECT @IdClientEntrepot = (ClientId) FROM Entrepot.dbo.Client
				WHERE NomContact = @NomContact and NomPays = @NomPays and Continent = @Continent 
			END
		ELSE
			BEGIN
				SELECT @IdClientEntrepot = (ClientId) FROM Entrepot.dbo.Client
				WHERE NomContact = @NomContact and NomPays = @NomPays and Continent IS NULL
			END
			
			IF @IdClientEntrepot = 38
			BEGIN
				PRINT @NomContact
				PRINT @NomPays
				PRINT @NomVille
				PRINT @Continent
			END

		IF @IdClientEntrepot IS NULL
		BEGIN
			INSERT INTO [dbo].[Client]
			SELECT
				@NomContact AS NomContact,
				
				@NomVille AS NomVille,
				
				@NomPays AS NomPays,
				
				@Continent AS Continent,

				NULL AS ReferenceClientId,
				NULL AS DateModification	
		END
		ELSE
		BEGIN
			IF @Continent IS NOT NULL
				BEGIN
					SELECT @NomVilleClient = (NomVille) from Entrepot.dbo.Client
					WHERE NomContact = @NomContact COLLATE French_CI_AS and
					NomPays = @NomPays COLLATE French_CI_AS and
					Continent = @Continent COLLATE French_CI_AS
				END 
			ELSE
				BEGIN
					SELECT @NomVilleClient = (NomVille) from Entrepot.dbo.Client
					WHERE NomContact = @NomContact COLLATE French_CI_AS and
					NomPays = @NomPays COLLATE French_CI_AS and
					Continent IS NULL
				END
				
			
			IF @NomVilleClient IS NOT NULL AND @NomVilleClient != @NomVille COLLATE French_CI_AS
			BEGIN
				SET @DateModification = GETDATE()
				
				IF (SELECT ReferenceClientId from Entrepot.dbo.Client
					WHERE ClientId = @IdClientEntrepot) IS NOT NULL
				BEGIN
					SELECT @IdClientEntrepot = ReferenceClientId FROM Entrepot.dbo.Client
					WHERE ClientId = @IdClientEntrepot;
				END
				
				INSERT INTO [dbo].[Client]
				SELECT
					@NomContact AS NomContact,
					
					@NomVille as NomVile,
					
					@NomPays AS NomPays,
					
					@Continent AS Continent,
					
					@IdClientEntrepot AS ReferenceClientId,
					
					@DateModification AS DateModification	
			END
		END
		
		SELECT @ClientId = min(CustomerID) FROM Northwind.dbo.Customers
		WHERE  Northwind.dbo.Customers.CustomerID > @ClientId
		
		SET @Continent = NULL;
		SET @NomContact = NULL;
		SET @NomPays = NULL;
		SET @NomVille = NULL;
		SET @NomVilleClient = NULL;
		SET @IdClientEntrepot = NULL;
	END
END
GO

EXEC updateClient
GO

CREATE PROCEDURE updateProduit AS
BEGIN
	DECLARE @ProductID int;
	DECLARE @NomProduit varchar(80);
	DECLARE @NomFournisseur varchar(80);
	DECLARE @Categorie varchar(80);
	DECLARE @PaysFournisseur varchar(80);
	DECLARE @SystemeMesure varchar(80);
	DECLARE @IdProduitEntrepot int;
	DECLARE @NomFournisseurProduit varchar(80);
	DECLARE @AncienFournisseur1 varchar(80);
	DECLARE @AncienFournisseur2 varchar(80);

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
		
		SELECT @IdProduitEntrepot = (ProduitId) FROM Entrepot.dbo.Produit
		WHERE Categorie = @Categorie
		and PaysFournisseur = @PaysFournisseur
		and NomProduit = @NomProduit
		
		IF @IdProduitEntrepot IS NULL
		BEGIN
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
		END
		ELSE
		BEGIN
			SELECT @NomFournisseurProduit  = (NomFournisseur) from Entrepot.dbo.Produit
			WHERE Categorie = @Categorie and PaysFournisseur = @PaysFournisseur and NomProduit = @NomProduit
			IF @NomFournisseurProduit != @NomFournisseur
			BEGIN
				SELECT @AncienFournisseur1 = (AncienFournisseur1) from Entrepot.dbo.Produit
				WHERE ProduitId = @IdProduitEntrepot
				
				SELECT @AncienFournisseur2 = (AncienFournisseur2) from Entrepot.dbo.Produit
				WHERE ProduitId = @IdProduitEntrepot
				
				UPDATE Entrepot.dbo.Produit
				SET NomFournisseur = @NomFournisseur, AncienFournisseur1 = @NomFournisseurProduit,
				AncienFournisseur2 = @AncienFournisseur1, AncienFournisseur3 = @AncienFournisseur2
				WHERE ProduitId = @IdProduitEntrepot
			END
		END
			
		SELECT @ProductID = min(ProductID) from Northwind.dbo.Products
		WHERE ProductID > @ProductID
	END
END
GO

EXEC updateProduit