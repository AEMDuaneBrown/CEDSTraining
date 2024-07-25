
----------------------------------------------------------------------------------------------------------------------------------------------------------------
---- This query creates the metadata scripts using the MapDataFormattedForUpload Table produced from the Align Map -------
----------------------------------------------------------------------------------------------------------------------------------------------------------------

----Step 1 - Download the Map Data Formatted for Upload report from the CEDS Align tool
----Step 2 - Import the entire dataset into a SQL table
----Step 3 - Edit the schema name if not dbo
----Step 4 - Run the entire script below which will produce the code to copy and paste into another window to run - Note: copy the contents of the SQLCode column, not the FinalOrderId column
----Step 5 - Run the code and the extended property values will be applied to the columns

DECLARE @SchemaName VARCHAR(100) ---- presently the Map Data Formatted For Upload Report does not contain the schema, add that here:
SET @SchemaName = 'dbo'

----Creating a temporary table of the required fields for metadata

CREATE TABLE #DataNeeded
	(SystemName VARCHAR(1000)
	,DatabaseName VARCHAR(1000)
	,TableName VARCHAR(1000)
	,ColumnName VARCHAR(1000)
	,CEDSGlobalId VARCHAR(10)
	,CEDSElementName VARCHAR(1000)
	,CEDSElementDefinition VARCHAR(MAX)
	,CEDSElementDataModelId VARCHAR(10)
	,DefinitionsResponseId INT
	,PrimaryElement BIT
	,SupplementalElement BIT
	,CEDSURL VARCHAR(1000)
	,OrderId INT
	,SQLCode NVARCHAR(MAX)
	,Complete BIT)
INSERT INTO  #DataNeeded
	(SystemName
	,DatabaseName
	,TableName
	,ColumnName
	,CEDSGlobalId
	,CEDSElementName
	,CEDSElementDefinition
	,CEDSElementDataModelId
	,DefinitionsResponseId
	,PrimaryElement
	,SupplementalElement
	,CEDSURL
	,OrderId
	,SQLCode
	,Complete)
SELECT DISTINCT
	 [System Name] SystemName
	,[Database Name] DatabaseName
	,[Table Name] TableName
	,[Column Name] ColumnName
	,[Global ID] CEDSGlobalId
	,[CEDS Element Name] CEDSElementName
	,[CEDS Element Definition] CEDSElementDefinition
	,[CEDS Element Data Model Id] CEDSElementDataModelId
	,[Definitions Response ID] DefinitionsResponseId
	,'0' PrimaryElement
	,'0' SupplementalElement
	,'https://ceds.ed.gov/element/' + [Global ID] CEDSURL
	,'1' OrderId
	,NULL SQLCode
	,NULL Complete
FROM MapDataFormattedForUpload

----In the event more than one element was mapped to a single column, this will select one to be primary and one to be supplemental
----If more than 2 elements have been applied to a single column, the code produced for step 5 will likely err out trying to create the same
----extended property for the same column.

UPDATE #DataNeeded SET PrimaryElement = '1' WHERE DefinitionsResponseId = '1'

UPDATE dn1
SET PrimaryElement = '1'
FROM #DataNeeded dn1
JOIN #DataNeeded dn2
ON dn1.SystemName = dn2.SystemName
AND dn1.DatabaseName = dn2.DatabaseName
AND dn1.TableName = dn2.TableName
AND dn1.ColumnName = dn2.ColumnName
WHERE dn1.DefinitionsResponseId <> dn2.DefinitionsResponseId
AND dn1.DefinitionsResponseId < dn2.DefinitionsResponseId

UPDATE dn2
SET SupplementalElement = '1'
FROM #DataNeeded dn1
JOIN #DataNeeded dn2
ON dn1.SystemName = dn2.SystemName
AND dn1.DatabaseName = dn2.DatabaseName
AND dn1.TableName = dn2.TableName
AND dn1.ColumnName = dn2.ColumnName
WHERE dn1.DefinitionsResponseId <> dn2.DefinitionsResponseId
AND dn1.DefinitionsResponseId < dn2.DefinitionsResponseId

UPDATE dn1
SET PrimaryElement = '1'
FROM #DataNeeded dn1
JOIN #DataNeeded dn2
ON dn1.SystemName = dn2.SystemName
AND dn1.DatabaseName = dn2.DatabaseName
AND dn1.TableName = dn2.TableName
AND dn1.ColumnName = dn2.ColumnName
WHERE dn1.DefinitionsResponseId = dn2.DefinitionsResponseId
AND dn1.CEDSGlobalId <> dn2.CEDSGlobalId
AND dn1.CEDSGlobalId > dn2.CEDSGlobalId

UPDATE dn2
SET SupplementalElement = '1'
FROM #DataNeeded dn1
JOIN #DataNeeded dn2
ON dn1.SystemName = dn2.SystemName
AND dn1.DatabaseName = dn2.DatabaseName
AND dn1.TableName = dn2.TableName
AND dn1.ColumnName = dn2.ColumnName
WHERE dn1.DefinitionsResponseId = dn2.DefinitionsResponseId
AND dn1.CEDSGlobalId <> dn2.CEDSGlobalId
AND dn1.CEDSGlobalId > dn2.CEDSGlobalId


UPDATE #DataNeeded
SET PrimaryElement = '1'
FROM #DataNeeded
WHERE SystemName + DatabaseName + TableName + ColumnName IN
(
SELECT DISTINCT SystemName + DatabaseName + TableName + ColumnName
FROM #DataNeeded
GROUP BY SystemName + DatabaseName + TableName + ColumnName
HAVING COUNT(*) = 1
)
AND PrimaryElement = '0'
AND SupplementalElement = '0'
AND DefinitionsResponseId = '2'

UPDATE #DataNeeded
SET PrimaryElement = '1'
FROM #DataNeeded
WHERE SystemName + DatabaseName + TableName + ColumnName IN
(
SELECT DISTINCT SystemName + DatabaseName + TableName + ColumnName
FROM #DataNeeded
GROUP BY SystemName + DatabaseName + TableName + ColumnName
HAVING COUNT(*) = 1
)
AND PrimaryElement = '0'
AND SupplementalElement = '0'
AND DefinitionsResponseId = '3'

UPDATE #DataNeeded
SET PrimaryElement = '1'
FROM #DataNeeded
WHERE SystemName + DatabaseName + TableName + ColumnName IN
(
SELECT DISTINCT SystemName + DatabaseName + TableName + ColumnName
FROM #DataNeeded
GROUP BY SystemName + DatabaseName + TableName + ColumnName
HAVING COUNT(*) = 1
)
AND PrimaryElement = '0'
AND SupplementalElement = '0'
AND DefinitionsResponseId = '4'

UPDATE #DataNeeded
SET PrimaryElement = '1'
FROM #DataNeeded
WHERE SystemName + DatabaseName + TableName + ColumnName IN
(
SELECT DISTINCT SystemName + DatabaseName + TableName + ColumnName
FROM #DataNeeded
GROUP BY SystemName + DatabaseName + TableName + ColumnName
HAVING COUNT(*) = 1
)
AND PrimaryElement = '0'
AND SupplementalElement = '0'
AND DefinitionsResponseId = '5'

UPDATE #DataNeeded
SET PrimaryElement = '1'
FROM #DataNeeded
WHERE SystemName + DatabaseName + TableName + ColumnName IN
(
SELECT DISTINCT SystemName + DatabaseName + TableName + ColumnName
FROM #DataNeeded
GROUP BY SystemName + DatabaseName + TableName + ColumnName
HAVING COUNT(*) = 1
)
AND PrimaryElement = '0'
AND SupplementalElement = '0'
AND DefinitionsResponseId = '6'

UPDATE #DataNeeded
SET OrderId = '6'
WHERE SupplementalElement = '1'

----Copying the data to create multiple extended properties for each column.

INSERT INTO  #DataNeeded
	(SystemName
	,DatabaseName
	,TableName
	,ColumnName
	,CEDSGlobalId
	,CEDSElementName
	,CEDSElementDefinition
	,CEDSElementDataModelId
	,DefinitionsResponseId
	,PrimaryElement
	,SupplementalElement
	,CEDSURL
	,OrderId
	,SQLCode
	,Complete)
SELECT DISTINCT
	 SystemName
	,DatabaseName
	,TableName
	,ColumnName
	,CEDSGlobalId
	,CEDSElementName
	,CEDSElementDefinition
	,CEDSElementDataModelId
	,DefinitionsResponseId
	,PrimaryElement
	,SupplementalElement
	,CEDSURL
	,'2' OrderId
	,SQLCode
	,Complete
FROM #DataNeeded
WHERE OrderId = '1'
AND PrimaryElement = '1'

INSERT INTO  #DataNeeded
	(SystemName
	,DatabaseName
	,TableName
	,ColumnName
	,CEDSGlobalId
	,CEDSElementName
	,CEDSElementDefinition
	,CEDSElementDataModelId
	,DefinitionsResponseId
	,PrimaryElement
	,SupplementalElement
	,CEDSURL
	,OrderId
	,SQLCode
	,Complete)
SELECT DISTINCT
	 SystemName
	,DatabaseName
	,TableName
	,ColumnName
	,CEDSGlobalId
	,CEDSElementName
	,CEDSElementDefinition
	,CEDSElementDataModelId
	,DefinitionsResponseId
	,PrimaryElement
	,SupplementalElement
	,CEDSURL
	,'3' OrderId
	,SQLCode
	,Complete
FROM #DataNeeded
WHERE OrderId = '1'
AND PrimaryElement = '1'

INSERT INTO  #DataNeeded
	(SystemName
	,DatabaseName
	,TableName
	,ColumnName
	,CEDSGlobalId
	,CEDSElementName
	,CEDSElementDefinition
	,CEDSElementDataModelId
	,DefinitionsResponseId
	,PrimaryElement
	,SupplementalElement
	,CEDSURL
	,OrderId
	,SQLCode
	,Complete)
SELECT DISTINCT
	 SystemName
	,DatabaseName
	,TableName
	,ColumnName
	,CEDSGlobalId
	,CEDSElementName
	,CEDSElementDefinition
	,CEDSElementDataModelId
	,DefinitionsResponseId
	,PrimaryElement
	,SupplementalElement
	,CEDSURL
	,'4' OrderId
	,SQLCode
	,Complete
FROM #DataNeeded
WHERE OrderId = '1'
AND PrimaryElement = '1'

INSERT INTO  #DataNeeded
	(SystemName
	,DatabaseName
	,TableName
	,ColumnName
	,CEDSGlobalId
	,CEDSElementName
	,CEDSElementDefinition
	,CEDSElementDataModelId
	,DefinitionsResponseId
	,PrimaryElement
	,SupplementalElement
	,CEDSURL
	,OrderId
	,SQLCode
	,Complete)
SELECT DISTINCT
	 SystemName
	,DatabaseName
	,TableName
	,ColumnName
	,CEDSGlobalId
	,CEDSElementName
	,CEDSElementDefinition
	,CEDSElementDataModelId
	,DefinitionsResponseId
	,PrimaryElement
	,SupplementalElement
	,CEDSURL
	,'5' OrderId
	,SQLCode
	,Complete
FROM #DataNeeded
WHERE OrderId = '1'
AND PrimaryElement = '1'

----Creating the SQL code

UPDATE #DataNeeded
SET SQLCode = 'EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N''See the CEDS_GlobalId, CEDS_Element, CEDS_URL, and CEDS_Def_Desc extended properties.'' , @level0type=N''SCHEMA'',@level0name=N''' + @SchemaName + ''', @level1type=N''TABLE'',@level1name=N''' + tcnc.TableName + ''', @level2type=N''COLUMN'',@level2name=N''' + tcnc.ColumnName + ''';'
FROM #DataNeeded tcnc
WHERE OrderId = '1'

UPDATE #DataNeeded
SET SQLCode = 'EXEC sys.sp_addextendedproperty @name=N''CEDS_Def_Desc'', @value=N''' + REPLACE(tcnc.CEDSElementDefinition, '''', 'singlequotesannoyme') + ''' , @level0type=N''SCHEMA'',@level0name=N''' + @SchemaName + ''', @level1type=N''TABLE'',@level1name=N''' + tcnc.TableName + ''', @level2type=N''COLUMN'',@level2name=N''' + tcnc.ColumnName + ''';'
FROM #DataNeeded tcnc
WHERE OrderId = '2'

UPDATE #DataNeeded
SET SQLCode = 'EXEC sys.sp_addextendedproperty @name=N''CEDS_Element'', @value=N''' + tcnc.CEDSElementName + ''' , @level0type=N''SCHEMA'',@level0name=N''' + @SchemaName + ''', @level1type=N''TABLE'',@level1name=N''' + tcnc.TableName + ''', @level2type=N''COLUMN'',@level2name=N''' + tcnc.ColumnName + ''';'
FROM #DataNeeded tcnc
WHERE OrderId = '3'

UPDATE #DataNeeded
SET SQLCode = 'EXEC sys.sp_addextendedproperty @name=N''CEDS_GlobalId'', @value=N''' + tcnc.CEDSGlobalId + ''' , @level0type=N''SCHEMA'',@level0name=N''' + @SchemaName + ''', @level1type=N''TABLE'',@level1name=N''' + tcnc.TableName + ''', @level2type=N''COLUMN'',@level2name=N''' + tcnc.ColumnName + ''';'
FROM #DataNeeded tcnc
WHERE OrderId = '4'

UPDATE #DataNeeded
SET SQLCode = 'EXEC sys.sp_addextendedproperty @name=N''CEDS_URL'', @value=N''https://ceds.ed.gov/element/' + tcnc.CEDSGlobalId + ''' , @level0type=N''SCHEMA'',@level0name=N''' + @SchemaName + ''', @level1type=N''TABLE'',@level1name=N''' + tcnc.TableName + ''', @level2type=N''COLUMN'',@level2name=N''' + tcnc.ColumnName + ''';'
FROM #DataNeeded tcnc
WHERE OrderId = '5'

UPDATE #DataNeeded
SET SQLCode = 'EXEC sys.sp_addextendedproperty @name=N''CEDS_SupplementalGlobalId'', @value=N''' + tcnc.CEDSGlobalId + ''' , @level0type=N''SCHEMA'',@level0name=N''' + @SchemaName + ''', @level1type=N''TABLE'',@level1name=N''' + tcnc.TableName + ''', @level2type=N''COLUMN'',@level2name=N''' + tcnc.ColumnName + ''';'
FROM #DataNeeded tcnc
WHERE OrderId = '6'

----Note: This corrects the single quotes ' that exist inside of the CEDS definitions so that when the code is displayed they are escaped.
UPDATE #DataNeeded
SET SQLCode = REPLACE(SQLCode, 'singlequotesannoyme', '''''')

CREATE TABLE #SQLCode
	(SQLCode NVARCHAR(MAX)
	,FinalOrderId INT)

DECLARE @FinalOrderId INT
SET @FinalOrderId = 1
DECLARE @SQLCode NVARCHAR(MAX)

WHILE (SELECT COUNT(*) FROM #DataNeeded WHERE Complete IS NULL) > 0
	BEGIN

		SET @SQLCode = (SELECT TOP 1 SQLCode FROM #DataNeeded WHERE Complete IS NULL ORDER BY ColumnName, OrderId)
		
		INSERT INTO #SQLCode
		SELECT @SQLCode, @FinalOrderId

		SET @FinalOrderId = @FinalOrderId + 1

		INSERT INTO #SQLCode
		SELECT 'GO', @FinalOrderId

		UPDATE #DataNeeded SET Complete = 1 WHERE SQLCode = @SQLCode

		SET @FinalOrderId = @FinalOrderId + 1
			

	END

----Selecting the SQL Code in order.

	SELECT *
	FROM #SQLCode
	ORDER BY FinalOrderId

DROP TABLE #DataNeeded
DROP TABLE #SQLCode



	--SELECT s.name AS SchemaName, o.name AS TableName, c.name AS ColumnName, ep.value
	--FROM sys.objects o
	--JOIN sys.columns c
	--	ON o.object_id = c.object_id
	--JOIN sys.extended_properties ep
	--	ON c.object_id = ep.major_id
	--	AND c.column_id = ep.minor_id
	--JOIN sys.schemas s
	--	ON o.schema_id = s.schema_id
	--WHERE o.type = 'U'
	--ORDER BY s.name, o.name, c.name