-- For each person in the database, report their ID and the number of recording sessions they have played at.
-- Include everyone, even if they are a manager or engineer, and even if they never played at any sessions.

SET search_path TO recording;

-- We will first find the number of sessions each band played in.
-- Including bands that did not play in any sessions
DROP VIEW IF EXISTS sessions_per_band CASCADE;
CREATE VIEW sessions_per_band AS
SELECT B.band_id,
       B.founder_id,
       COALESCE(COUNT(DISTINCT session_id), 0) AS num_sessions
FROM Band B LEFT JOIN 
    Play P ON B.band_id = P.band_id
GROUP BY B.band_id;

-- Now, we will find the number of sessions each founder has played in.
DROP VIEW IF EXISTS sessions_per_founder CASCADE;
CREATE VIEW sessions_per_founder AS
SELECT DISTINCT founder_id AS person_id,
       SUM(num_sessions) AS num_sessions
FROM sessions_per_band SPB1
GROUP BY founder_id;

-- Now, we will find the number of sessions each bandmember has played in.
-- The bandmembers calculated here may or may not include the founding member.
DROP VIEW IF EXISTS sessions_per_bandmember CASCADE;
CREATE VIEW sessions_per_bandmember AS
SELECT BM.person_id,
       SUM(SPB.num_sessions) AS num_sessions
FROM sessions_per_band SPB 
     JOIN BandMembership BM ON SPB.band_id = BM.band_id
GROUP BY BM.person_id;

-- Now, we will get all of the people who did not play in any 
-- sessions since they were not in a band.
DROP VIEW IF EXISTS other_people CASCADE;
CREATE VIEW other_people AS
(SELECT id FROM Person)
EXCEPT
((SELECT person_id FROM sessions_per_founder)
 UNION
 (SELECT person_id FROM sessions_per_bandmember)
)
ORDER BY id;

-- Now, we will assign 0 for the number of sessions played in for these
-- other people.
DROP VIEW IF EXISTS sessions_per_other CASCADE;
CREATE VIEW sessions_per_other AS
SELECT id AS person_id,
       0 AS num_sessions
FROM other_people
ORDER BY id;

-- Now, we will combine these three tables to get the number of sessions
-- all people have played in.
(SELECT * FROM sessions_per_other)
UNION
(SELECT * FROM sessions_per_founder)
UNION
(SELECT * FROM sessions_per_bandmember)
ORDER BY person_id;