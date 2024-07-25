--USE CEDS-IDS-V12_0_0_0

--Organization/Person/Role

	--If you can't find it, it's probably an Organization :)
	SELECT *
	FROM RefOrganizationType
	--All of these descriptions are treated as Organizations
	--Open the table "Course" -- there is a Foreign Key called "OrganizationId" - this is NOT the LEA or School, this is the link from Course back to it's parent Organization
	--Open the table "CourseSection", note two Foreign Keys: "OrganizationId" and "CourseId" - This CourseSection is a section of Course (CourseId), but the CourseSection
				----itself is an Organization - the OrganizationId is the link from CourseSection back to it's parent Organization.
	--This makes all of the Organization tables/columns/elements available to all of the Organization Types. They may not all apply, but they are available.

	SELECT *
	FROM RefRole
	--Role is meant to be extremely high level --CEDS has other more specific roles such as teacher, paraprofessional, etc.
	--OrganizationPersonRole joins the Person to an Organization (LEA, Program, CourseSection, anything from OrganizationType) with a specific role, for a specfic period of time.  A person can then both a K12 Student and K12 Staff at the same time.
	--To enroll a student in a coursesection, program, school, etc. they must go through OrganizationPersonRole
	--You will notice in other tables, the Foreign Key relationship back to OrganizationPersonRole
	--Open K12StudentCourseSection - Note the Foreign Key relationship back to OrganizationPersonRole. They were enrolled in this CourseSection based on the dates in
					----OrganizationPersonRole

--Personas
	--Open the table Person and PersonMaster
	--There is a foreign Key from Person to PersonMaster.  What is this for?
	--A person may exist more than once in the IDS depending on the use case
	--If you think about how you collect data from schools presently, all of the demographic/program enrollment data, really everything about the student
					----is "owned" by the organization. You may have conflicting data if the student was in more than one LEA. The best way to track information
					----about a person in the IDS is by creating multiple persons with data "owned" by the organization that provided it.
					----But to be able to look across from a key relationship perspective is through the use of PersonMaster. The same ID applied to every
					----person record where it is the same human.

--RecordStartDateTime / RecordEndDateTime
	--The data are true as of these dates -- this allows for longitudinal storage within the IDS if desired.

--Data Collection
	--Open the table DataCollection
	--This provided an additional way to store data separately by Collection. This record came in from Source A, this record came in from Source B.

--Record Status
	--Open the table RecordStatus
	--RecordStatus can optionally be used keep track of the status of record.
	SELECT *
	FROM RefRecordStatusType

--Reference table (Option Sets)

	SELECT *
	FROM RefAbsentAttendanceCategory
	--Note the RefJurisdictionId --this is always NULL when the option set code is a CEDS standard Code. To add additional options
	--to this table, you can add in the OrganizationId of the Organization (Likely the state education agency) responsible for maintaining
	--this code. Of course, best practice would be to work with CEDS to get the coded added into the standard.
	--The RecordStartDateTime/RecordEndDateTime can be used for option set management -- keeping an option set historically, though
	--it is no longer valid presently. This would have a RecordEndDateTime.

--Extending
	--Never add to an existing table, create a new table with the Foreign Key back to the Primary Key of the table being extended, of course, best practice is to add it into the CEDS standard so there is no need for extending.


--Metadata--

	--Finding where things go in the IDS--
	SELECT *
	FROM _CEDStoNDSMapping
	WHERE GlobalID LIKE '%000001%'

	SELECT o.name AS TableName, c.name AS ColumnName, ep.value AS GlobalId
	FROM sys.objects o
	JOIN sys.columns c
		ON o.object_id = c.object_id
	JOIN sys.extended_properties ep
		ON c.object_id = ep.major_id
		AND c.column_id = ep.minor_id
	WHERE o.type = 'U'
		AND ep.name = 'CEDS_GlobalId'
		AND CONVERT(VARCHAR(1000), ep.value) LIKE '%000001%'




