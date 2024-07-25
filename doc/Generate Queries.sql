SELECT *
FROM RDS.FactK12StudentCounts fsc
JOIN RDS.DimFactTypes dft
	ON fsc.FactTypeId = dft.DimFactTypeId
WHERE dft.FactTypeCode = 'membership'

SELECT *
FROM RDS.ReportEDFactsK12StudentCounts
WHERE ReportCode = 'c052'

DELETE fsc
FROM RDS.FactK12StudentCounts fsc
JOIN RDS.DimFactTypes dft
	ON fsc.FactTypeId = dft.DimFactTypeId
WHERE dft.FactTypeCode = 'membership'

DELETE
FROM RDS.ReportEDFactsK12StudentCounts
WHERE ReportCode = 'c052'


USE [Generate]
GO

DECLARE	@return_value int

EXEC	@return_value = [App].[Wrapper_Migrate_Membership_to_RDS]

SELECT	'Return Value' = @return_value

GO


UPDATE App.GenerateReports SET IsLocked = 0

UPDATE App.GenerateReports
SET IsLocked = 1
WHERE ReportCode IN
('c052'
,'c039'
)


----
UPDATE App.DataMigrations
SET DataMigrationStatusId = 2
WHERE DataMigrationId = 3

DECLARE	@return_value int

EXEC	@return_value = [App].[Migrate_Data]

SELECT	'Return Value' = @return_value

GO

----
USE [Generate]
GO

DECLARE	@return_value int

EXEC	@return_value = [RDS].[Get_ReportData]
		@reportCode = N'c052',
		@reportLevel = N'sea',
		@reportYear = N'2024',
		@categorySetCode = NULL,
		@includeZeroCounts = 1,
		@includeFriendlyCaptions = 0,
		@obscureMissingCategoryCounts = 0,
		@isOnlineReport = 0

SELECT	'Return Value' = @return_value

GO
