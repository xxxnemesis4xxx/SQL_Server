USE ENTREPOT
GO

DROP TABLE Continent
GO

CREATE TABLE Entrepot.dbo.Continent(
Continent varchar(40)NOT NULL,
Pays varchar(40) NOT NULL PRIMARY KEY
)
GO

DROP PROCEDURE remplirContinent
GO

CREATE PROCEDURE remplirContinent AS
DECLARE @Continent varchar(40);
DECLARE @Pays varchar(40);
DECLARE @getContinent CURSOR;

set @getContinent = CURSOR FOR
SELECT DISTINCT Entrepot.dbo.Client.NomPays,
Entrepot.dbo.Client.Continent
FROM Entrepot.dbo.Client

OPEN @getContinent
FETCH NEXT
FROM @getContinent INTO @Pays,@Continent
WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO [dbo].[Continent]
	SELECT
		@Continent AS Continent,
		@Pays AS Pays
		
	FETCH NEXT
	FROM @getContinent INTO @Pays,@Continent
END
GO

EXEC Entrepot.dbo.remplirContinent
GO


SELECT * FROM Entrepot.dbo.Continent