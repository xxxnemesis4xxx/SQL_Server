SET LANGUAGE FRENCH

USE master
GO

IF EXISTS(SELECT * from sys.databases WHERE name='Entrepot')
BEGIN 
	DROP DATABASE Entrepot;
END

CREATE DATABASE Entrepot;

USE Entrepot
GO

BEGIN TRY
	DROP TABLE [dbo].[Dates]
END TRY

BEGIN CATCH
	/*No Action*/
END CATCH

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

	INSERT INTO entrepot.dbo.Dates
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

EXECUTE  RemplirDate
GO
select * from dbo.Dates;

select * from dbo.Dates
where Mois='Mars' and AnneeFinanciere = '2012'