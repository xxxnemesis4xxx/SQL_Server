USE ENTREPOT

DROP TABLE dbo.Client
GO

CREATE TABLE dbo.Client
(ClientId int IDENTITY(1,1) NOT NULL PRIMARY KEY,
NomContact varchar(80),
NomVille varchar(80),
NomPays varchar(80),
Continent varchar(80),
ReferenceClientId int,
DateModification datetime
)
GO

DROP PROCEDURE dbo.remplirClient
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

select * from dbo.client