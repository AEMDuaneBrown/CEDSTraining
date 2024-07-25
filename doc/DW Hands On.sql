	
--Fact / Dimension / Bridge
	--Open FactK12FinancialAccountGeneralLedges
	--Nearly every column in the Fact tables are Foreign Key Ids, avoiding NULL values. If no data, set to "-1"
	--Columns that point to a Dimension table are set up four ways:
			--1) Remove the text "Dim" from the Dimension table PrimaryKey to create the column name (DimK12SchoolId becomes K12SchoolId)
			--2) Dates - Use the CEDS element technical name followed by the text "Id" and point to DimDates
			--3) Qualifier - Add a standard CEDS option code to the column name (DimLeaId becomes LeaId becomes LeaAccountabilityId - standard option code of element District Responsibility Type is "Accountability")
			--4) Role - The element Role contains standard codes, these can be used along with "Id" to point to DimPeople, this provides context to the role the person plays within that Fact but retains the ability to have only one DimPeople table instead of a DimK12Student table, DimPsStudent table, DimK12Staff table, etc. (Technically a Qualifier, but if you remove the code, you are left with only "Id")

	--Bridge tables
		--Open BridgeK12StudentCourseSectionRaces
		--Contains the Fact Table Primary Key and the Dimension table Primary Key (minus the "Dim)
		--Used when there is a one to many relationship between the Fact and a dimension
		--Open BridgeK12StudentEnrollmentPersonAddresses
		--More than one address may apply to the student, also contains the "AddressTypeForLearnerOrFamilyCode" to indicate which type of address this is - "Mailing", "Physical", etc.

	--Development Principles
		--Always create the constraints (FK)
		--Always create the metadata

--Slowly Changing Dimensions / Junk Dimensions
	--Slowly Changing Dimension
		--Open DimK12Schools
	--Junk Dimension
		--CROSS JOIN - Contains every possible combination of codes for the elements listed
			SELECT *
			FROM RDS.DimEconomicallyDisadvantagedStatuses
		--Standard structure is Element Technical Name + the text "Code" at the end for the standard option set code and another column with the Element Technical Name + the text "Description" at the end for the standard option set description. 
		--Some will also contain the Element Technical Name + "EdFactCode" at the end where applicable. In the future, other standard mappings could also be provided for other federal reporting.

--Standard Semantic / Custom Semantic
	--Semantic Layer - makes use of the Fact tables to produce aggregated, disaggragated or other unit record tables, views, etc.
					----Data source is always the Fact tables or the Fact tables +
					----Can be a table, view, stored procedure, function, etc.
	--Standard Semantic
		--Open ReportEDFactsK12StudentCounts
		--This table is considered "Standard" semantic because it is part of the CEDS Data Warehouse release. It is capable of producing multiple EDFacts reports. This is one of the tables used by Generate. It's considered "standard" because it is expected that anyone who uses this table would do so the exact same way with the same interpretations.
	--Custom Semantic
		--Any table, view, stored procedure, function, etc. that is not part of the CEDS standard.
		--Go to the CEDS Collaborative Exchange (https://github.com/CEDS-Collaborative-Exchange)
					----Click CIID-Reports repository
					----Click significant-disproportionality
					----Click SQL Views
					----Open any view - this is a custom semantic layer
		--SLDS Scalable Data Use Supplemental Grant funding is going to define best practices for sharing custom semantic in the CEDS Collaborative Exchange.

--Staging
	--Staging Tables
	--Staging Stored Procedures
	--Staging Views


--Extending
	--Never add to an existing table, create a new table with the Foreign Key back to the Primary Key of the table being extended, of course, best practice is to add it into the CEDS standard so there is no need for extending.
	
--Metadata

	--Naming Structure
	SELECT DISTINCT name
	FROM sys.extended_properties
	WHERE name LIKE 'CEDS%'
	ORDER BY name
	--Additionally coming in V12/13
	/*
			CEDS_QualifierOptionCode - when it is only an option code and direct link to another Dimension table (e.g. LeaAccountabilityId)(Element: District Responsibility Type)
			CEDS_QualifierOptionElement
			CEDS_QualifierOptionGlobalId
			CEDS_QualifierOptionURL
			CEDS_SuffixConcatenatedOptionCode - when a standard option code is added to the end of the column name that contains a standard CEDS element name.
			CEDS_SuffixConcatenatedOptionElement
			CEDS_SuffixConcatenatedOptionElementGlobalId
			CEDS_SuffixConcatenatedOptionElementURL
			CEDS_PrefixConcatenatedOptionCode - when a standard option code is added to the start of the column name that contains a standard CEDS element name.
			CEDS_PrefixConcatenatedOptionElement
			CEDS_PrefixConcatenatedOptionElementGlobalId
			CEDS_PrefixConcatenatedOptionElementURL
	*/


	SELECT s.name AS SchemaName, o.name AS TableName, c.name AS ColumnName, ep.value AS GlobalId
	FROM sys.objects o
	JOIN sys.columns c
		ON o.object_id = c.object_id
	JOIN sys.extended_properties ep
		ON c.object_id = ep.major_id
		AND c.column_id = ep.minor_id
	JOIN sys.schemas s
		ON o.schema_id = s.schema_id
	WHERE o.type = 'U'
		AND ep.name = 'CEDS_GlobalId'
		AND ep.value = '000115'
	ORDER BY s.name

