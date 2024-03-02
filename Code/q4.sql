-- Find the album that required the greatest number of recording sessions. Report the album ID and name, the
-- number of recording sessions, and the number of different people who played on the album. If a person played
-- both as part of a band and in a solo capacity, count them only once.

SET search_path TO recording;

-- First, we will find the first two album tracks for each album.
DROP VIEW IF EXISTS album_tracks_first CASCADE;
CREATE VIEW album_tracks_first AS
SELECT album_id,
       track_1 AS track_id
FROM Album;

DROP VIEW IF EXISTS album_tracks_second CASCADE;
CREATE VIEW album_tracks_second AS
SELECT album_id,
       track_2 AS track_id
FROM Album;

-- Now, we will find the rest of the tracks for each album.
DROP VIEW IF EXISTS album_tracks_rest CASCADE;
CREATE VIEW album_tracks_rest AS
SELECT album_id,
       track_id
FROM AlbumTrack;

-- Now, we will combine these three tables together to find all of
-- the tracks for each album.
DROP VIEW IF EXISTS album_tracks_all CASCADE;
CREATE VIEW album_tracks_all AS
(SELECT * FROM album_tracks_first)
UNION
(SELECT * FROM album_tracks_second)
UNION
(SELECT * FROM album_tracks_rest)
ORDER BY album_id, track_id;

-- Now, we will find the number of sessions each track took to record, excluding overlap.
DROP VIEW IF EXISTS album_sessions CASCADE;
CREATE VIEW album_sessions AS
SELECT T.album_id,
       RS.session_id
FROM album_tracks_all T
     JOIN TrackSeg TS ON T.track_id = TS.track_id
     JOIN RecSeg RS ON TS.seg_id = RS.seg_id
GROUP BY T.album_id, RS.session_id
ORDER BY T.album_id, RS.session_id;

-- Now, we will find the number of sessions each album took to record.
DROP VIEW IF EXISTS album_num_sessions CASCADE;
CREATE VIEW album_num_sessions AS
SELECT AN.album_id,
       AN.name,
       COUNT(DISTINCT A.session_id) AS num_sessions
FROM album_sessions A
     JOIN Album AN ON A.album_id = AN.album_id
GROUP BY AN.album_id, AN.name
ORDER BY AN.album_id, AN.name, num_sessions;

-- Now, we will get all of the bands who played on these sessions.
DROP VIEW IF EXISTS album_bands CASCADE;
CREATE VIEW album_bands AS 
SELECT DISTINCT A.album_id,
       P.band_id
FROM album_sessions A
     JOIN Play P ON A.session_id = P.session_id;

-- Now, we will find all of the founders who played on this album.
DROP VIEW IF EXISTS album_founders CASCADE;
CREATE VIEW album_founders AS 
SELECT AB.album_id,
       B.founder_id AS person_id
FROM album_bands AB
     JOIN Band B ON AB.band_id = B.band_id;

-- Now, we will find all of the other musicians who played on this album.
DROP VIEW IF EXISTS album_musicians CASCADE;
CREATE VIEW album_musicians AS 
SELECT DISTINCT AB.album_id,
       BM.person_id
FROM album_bands AB 
     JOIN BandMembership BM ON AB.band_id = BM.band_id;

-- Now, we will combine these two tables to find everyone who played
-- on the album.
DROP VIEW IF EXISTS album_musicians_all CASCADE;
CREATE VIEW album_musicians_all AS 
(SELECT * FROM album_founders)
UNION
(SELECT * FROM album_musicians)
ORDER BY person_id;

-- Now, we can simply output what we have found.
SELECT DISTINCT A.album_id,
       A.name,
       A.num_sessions,
       (SELECT COUNT(*)
       FROM album_musicians_all AMA
       WHERE A.album_id = AMA.album_id
       GROUP BY AMA.album_id) AS num_musicians
FROM album_num_sessions A 
WHERE A.num_sessions = (
     SELECT MAX(num_sessions)
     FROM album_num_sessions
)
ORDER BY A.album_id, A.name, A.num_sessions, num_musicians;
