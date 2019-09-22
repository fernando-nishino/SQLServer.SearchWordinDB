USE master;

DECLARE @SearchedWords AS varchar(1000) = '###WORD(S) TO SEARCH###' --Type Here

DECLARE @DataBase AS varchar(255)
DECLARE @Query AS varchar(MAX)
DECLARE @DataBases AS TABLE (Id int IDENTITY(1, 1), Dtbase varchar(255))
DECLARE @i AS int = 1
DECLARE @Total AS int

INSERT INTO @DataBases (Dtbase) SELECT name FROM master.dbo.sysdatabases ORDER BY name
SET @Total = @@ROWCOUNT

SET @SearchedWords = '%' + REPLACE(REPLACE(@SearchedWords, ' ', '%'), '_', '[_]') + '%'

WHILE @i <= @Total
BEGIN
	SET @DataBase = (SELECT Dtbase FROM @DataBases WHERE Id = @i)
	PRINT '-------------------------'
	--PRINT CAST(GETDATE() AS time)
	PRINT @DataBase
	SET @Query =' ' +
							'SELECT	CONVERT(time(1), GETDATE(), 108) AS Time, ' +
									'''' + @DataBase + ''' AS Dtbase, ' +
									'Objects.name AS Object, ' +
									'Modules.definition AS Module, ' +
									'Columns.name AS Colu, ' +
									'Objects.type_desc AS Type ' +
							'FROM ' + @DataBase + '.sys.objects AS Objects ' +
							'LEFT JOIN ' + @DataBase + '.sys.sql_modules AS Modules ON Objects.object_id = Modules.object_id ' +
							'LEFT JOIN ' + @DataBase + '.sys.columns AS Columns ON Objects.object_id = Columns.object_id ' +
							'WHERE ' + 
									'(Objects.name LIKE ''' + @SearchedWords + ''' COLLATE latin1_general_ci_ai OR ' +
									'Modules.definition LIKE ''' + @SearchedWords + ''' COLLATE latin1_general_ci_ai OR ' +
									'Columns.name LIKE ''' + @SearchedWords + ''' COLLATE latin1_general_ci_ai) ' +
						' ' +
				'ORDER BY Object; '
	EXEC (@Query)
	SET @i = @i + 1
END


SELECT CONVERT(time(1), GETDATE(), 108) AS Time, Job.name AS Job, Job.enabled AS Enabled, JobHist.step_name AS StepHist, JobStep.step_name AS StepJob, JobHist.message AS Message, 
		CAST((Sched.active_start_time % 1000000) / 10000 AS varchar(2)) + ':' + RIGHT('0' + CAST((Sched.active_start_time % 10000) / 100 AS varchar(2)), 2) + ':' + RIGHT('0' + CAST(Sched.active_start_time % 100 AS varchar(2)), 2) AS HorarioExecucao
FROM		msdb.dbo.sysjobs			AS Job		WITH (NOLOCK)
LEFT JOIN	msdb.dbo.sysjobhistory		AS JobHist	WITH (NOLOCK) ON Job.job_id = JobHist.job_id
LEFT JOIN	msdb.dbo.sysjobschedules	AS JobSched	WITH (NOLOCK) ON Job.job_id = JobSched.job_id
LEFT JOIN	msdb.dbo.sysschedules		AS Sched	WITH (NOLOCK) ON JobSched.schedule_id = Sched.schedule_id
LEFT JOIN	msdb.dbo.sysjobsteps		AS JobStep	WITH (NOLOCK) ON Job.job_id = Jobstep.job_id
WHERE	Job.name LIKE @SearchedWords COLLATE latin1_general_ci_ai OR
		JobHist.step_name LIKE @SearchedWords COLLATE latin1_general_ci_ai OR
		JobHist.message LIKE @SearchedWords COLLATE latin1_general_ci_ai OR
		JobStep.command LIKE @SearchedWords COLLATE latin1_general_ci_ai OR
		Sched.name LIKE @SearchedWords COLLATE latin1_general_ci_ai
