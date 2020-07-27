DROP TABLE IF EXISTS #XEL
SELECT *
INTO #XEL
FROM sys.fn_xe_file_target_read_file('  !!!!! PATH TO Report.xel FILE !!!!!  ', null, null, null);  


DROP TABLE IF EXISTS #PROCESSED
;WITH XEL AS 
(
SELECT          x.[object_name] as EventType
                ,CAST(x.event_data AS xml) EventXML
FROM            #XEL x 
)

SELECT          xe.EventType,
                xe.EventXML.value('(event//data[@name="EventClass"]//value)[1]','VARCHAR(255)')  AS EventClassValue,
                xe.EventXML.value('(event//data[@name="EventClass"]//text)[1]','VARCHAR(255)')  AS EventClassName,
                xe.EventXML.value('(event//data[@name="StartTime"]//value)[1]','VARCHAR(255)')  AS StartTime,
                xe.EventXML.value('(event//data[@name="EndTime"]//value)[1]','VARCHAR(255)')  AS EndTime,
                xe.EventXML.value('(event//data[@name="Duration"]//value)[1]','VARCHAR(255)')  AS Duration,
                xe.EventXML.value('(event//data[@name="JobID"]//value)[1]','VARCHAR(255)')  AS JobID,
                xe.EventXML.value('(event//data[@name="ObjectType"]//value)[1]','VARCHAR(255)')  AS ObjectType,
                xe.EventXML.value('(event//data[@name="TextData"]//value)[1]','VARCHAR(512)')  AS TextData,
                xe.EventXML.value('(event//data[@name="ObjectReference"]//value)[1]','VARCHAR(2048)')  AS ObjectReference,
                xe.EventXML.value('(event//data[@name="ObjectPath"]//value)[1]','VARCHAR(2048)')  AS ObjectPath,
                xe.EventXML.value('(event//data[@name="ObjectID"]//value)[1]','VARCHAR(2048)')  AS ObjectID,
                xe.EventXML.value('(event//data[@name="ObjectName"]//value)[1]','VARCHAR(2048)')  AS ObjectName,
                xe.EventXML.value('(event//data[@name="DatabaseName"]//value)[1]','VARCHAR(2048)')  AS DatabaseName
INTO            #PROCESSED
FROM            XEL xe

DECLARE @Scale INT = 200
DECLARE @StartTime datetime = NULL
DECLARE @GraphSymbol char(1) = '!'

;WITH ProgressReportEnd AS 
(
SELECT      pb.JobID,
            pb.TextData,
            pb.StartTime,
            pb.EndTime,
            pb.Duration,
            pb.ObjectType,
            pb.ObjectReference,
            pb.ObjectPath,
            pb.ObjectID,
            pb.ObjectName,
            pb.DatabaseName
FROM        #PROCESSED pb
WHERE       pb.EventType = 'ProgressReportEnd'
), [Base] AS 
(

    SELECT      pb.JobID,
                pb.TextData,
                pb.StartTime,
                pb.EndTime,
                pb.Duration,
                pb.ObjectType,
                pb.ObjectReference,
                pb.ObjectPath,
                pb.ObjectID,
                pb.ObjectName,
                pb.DatabaseName,
                MIN(pb.StartTime) OVER () AS MinStartTime
    FROM        ProgressReportEnd pb

), [Base2] AS 
    (
        SELECT          q.JobID,
                        q.TextData,
                        q.StartTime,
                        q.EndTime,
                        q.ObjectType,
                        q.ObjectReference,
                        q.ObjectPath,
                        q.ObjectID,
                        q.ObjectName,
                        q.DatabaseName,
                        q.MinStartTime,
                        DATEDIFF(s,q.MinStartTime, q.StartTime) AS SecondsToStart,
                        DATEDIFF(s,q.starttime,ISNULL(q.EndTime,q.starttime)) AS SecondsDuration
        FROM            [Base] q
    )
    SELECT          q.StartTime,                
                    q.ObjectName,         
                    q.TextData,
                    q.ObjectPath, 
                    q.SecondsToStart / 60 AS MinutesToStart,
                    q.SecondsDuration / 60 AS MinutesDuration,
                    REPLICATE(' ', CEILING(1.* q.SecondsToStart / 3600 * @Scale))+ REPLICATE(@GraphSymbol, CEILING(1.*q.SecondsDuration / 3600 * @Scale))        
                    AS Gantt
    FROM            [Base2] q
    where 1=1

    ORDER BY        q.ObjectName,
                    q.SecondsToStart,
                    q.ObjectID;


