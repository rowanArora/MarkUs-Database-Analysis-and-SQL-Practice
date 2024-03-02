-- Find the recording session that produced the greatest total number of seconds of recording segments. Report
-- the ID and name of everyone who played at that session, whether as part of a band or in a solo capacity.

SET search_path TO recording;

-- First, we will convert the times for each recording segment into seconds.
DROP VIEW IF EXISTS converted_time CASCADE;
CREATE VIEW converted_time AS
SELECT seg_id,
       session_id,
       (((SELECT EXTRACT(HOUR FROM length)) * 60) * 60) + 
       ((SELECT EXTRACT(MINUTE FROM length)) * 60) + 
       (SELECT EXTRACT(SECOND FROM length)) AS num_seconds
FROM RecSeg
ORDER BY seg_id, session_id, num_seconds;

-- Now, we will get the total time in terms of recording segments for each session.
-- Sessions that did not produce any recordings have session time of 0.
DROP VIEW IF EXISTS total_time_per_session CASCADE;
CREATE VIEW total_time_per_session AS
SELECT DISTINCT S.session_id,
       COALESCE(SUM(CT.num_seconds), 0) as total_session_time
FROM Session S
     LEFT JOIN converted_time CT ON S.session_id = CT.session_id
GROUP BY S.session_id
ORDER BY S.session_id;

-- Now, we will find all of the founders who played in the biggest session.
DROP VIEW IF EXISTS founders_played CASCADE;
CREATE VIEW founders_played AS
SELECT TS.session_id,
       B.founder_id AS person_id,
       P.name,
       B.name AS band_name
FROM total_time_per_session TS 
     JOIN Play Pl ON TS.session_id = Pl.session_id
     JOIN Band B ON Pl.band_id = B.band_id
     JOIN Person P ON B.founder_id = P.id
WHERE TS.total_session_time = (
     SELECT MAX(total_session_time)
     FROM total_time_per_session
)
ORDER BY TS.session_id, B.founder_id, P.name, B.name;

-- Now, we will find all of the musicians who played in the biggest session.
DROP VIEW IF EXISTS musicians_played CASCADE;
CREATE VIEW musicians_played AS
SELECT TS.session_id,
       BM.person_id,
       P.name,
       B.name AS band_name
FROM total_time_per_session TS
     JOIN Play Pl ON TS.session_id = Pl.session_id
     JOIN BandMembership BM ON Pl.band_id = BM.band_id
     JOIN Band B on BM.band_id = B.band_id
     JOIN Person P ON BM.person_id = P.id
WHERE TS.total_session_time = (
     SELECT MAX(total_session_time)
     FROM total_time_per_session
)
ORDER BY TS.session_id, BM.person_id, P.name, B.name;

-- The maximum might be 0 if all sessions did not produce any recordings. 
-- Now, we will combine these two tables together to find everyone who played
-- in the biggest session(s).
(SELECT * FROM founders_played)
UNION
(SELECT * FROM musicians_played);