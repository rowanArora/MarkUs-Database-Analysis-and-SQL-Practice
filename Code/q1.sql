-- For each studio, report the ID and name of its current manager, and the number of albums it has contributed
-- to. A studio contributed to an album iff at least one recording segment recorded there is part of that album.

SET search_path TO recording;

-- We will first find all of the old managers for each studio.
DROP VIEW IF EXISTS old_managers CASCADE;
CREATE VIEW old_managers AS
SELECT DISTINCT ON (MH1.studio_id, MH1.person_id)
       MH1.studio_id,
       MH1.person_id,
       MH1.start_date
FROM ManagementHistory MH1
     JOIN ManagementHistory MH2 ON MH1.studio_id = MH2.studio_id
WHERE MH1.start_date < MH2.start_date;

-- Using all of the old managers, we will find all of the current managers
-- for each studio.
DROP VIEW IF EXISTS curr_managers CASCADE;
CREATE VIEW curr_managers AS 
(SELECT * FROM ManagementHistory)
EXCEPT
(SELECT * FROM old_managers)
ORDER BY studio_id;

-- Now we will find all the track + album pairs.
DROP VIEW IF EXISTS all_album_tracks CASCADE;
CREATE VIEW all_album_tracks AS 
(SELECT album_id, track_1 AS track_id FROM Album)
UNION
(SELECT album_id, track_2 AS track_id FROM Album)
UNION
(SELECT * FROM AlbumTrack);

-- If a studio has contributed to an album, 
-- we will find the number of albums the studio has contributed to.
DROP VIEW IF EXISTS studio_per_album CASCADE;
CREATE VIEW studio_per_album AS
SELECT S.studio_id,
       COUNT(DISTINCT A.album_id) AS album_count
FROM RecSeg RS
     JOIN Session S ON RS.session_id = S.session_id
     JOIN TrackSeg TS ON RS.seg_id = TS.seg_id
     JOIN all_album_tracks A ON A.track_id = TS.track_id
GROUP BY S.studio_id;

-- If the studio did not contribute, set the count to 0.
DROP VIEW IF EXISTS no_album_studios CASCADE;
CREATE VIEW no_album_studios AS
SELECT studio_id,
       0 AS album_count
FROM Studio
WHERE studio_id NOT IN (SELECT DISTINCT studio_id FROM studio_per_album);

-- Now, we take the union of these two tables to get the number of albums
-- each studio has contributed to for all studios.
DROP VIEW IF EXISTS album_counts CASCADE;
CREATE VIEW album_counts AS
(SELECT * FROM studio_per_album)
UNION
(SELECT * FROM no_album_studios);

-- Now put it all together!
SELECT CM.studio_id,
       CM.person_id,
       P.name,
       AC.album_count
FROM curr_managers CM
     JOIN album_counts AC ON CM.studio_id = AC.studio_id
     JOIN Person P ON CM.person_id = P.id
ORDER BY CM.studio_id, CM.person_id, P.name, AC.album_count;
