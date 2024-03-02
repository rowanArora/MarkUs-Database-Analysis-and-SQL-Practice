SET SEARCH_PATH TO recording;

INSERT INTO 
    Person(name, email, phone_num)
VALUES
    -- Managers
    ('Donna Meagle', 'donna.meagle@gmail.com', '1233456789'),
    ('Tom Haverford', 'tom.haverford@gmail.com', '1234456789'),
    ('April Ludgate', 'april.ludgate@icloud.com', '1123456789'),
    ('Leslie Knope', 'leslie.knope@icloud.com', '1223456789'),
    -- Engineers
    ('Ben Wyatt', 'ben.wyatt@live.com', '1234567889'),
    ('Ann Perkins', 'ann.perkins@live.com', '1234567899'),
    ('Chris Traeger', 'chris.traeger@live.com', '1234566789'),
    -- Musicians
    ('Andy Dwyer', 'andy.dwyer@music.org', '1234567789'),
    ('Andrew Burlinson', 'andrew.burlinson@music.org', '1234556789'),
    ('Michael Chang', 'michael.chang@music.org', '1222345678'),
    ('James Pierson', 'james.pierson@music.org', '783212345'),
    ('Duke Silver', 'duke.silver@music.org', '1234567890');


INSERT INTO 
    Studio(name, address, original_manager, start_date)
VALUES
    ('Pawnee Recording Studio', '123 Valley spring lane, Pawnee, Indiana', 3, '2008-03-21'),
    ('Pawnee Sound', '353 Western Ave, Pawnee, Indiana', 1, '2011-05-07'),
    ('Eagleton Recording Studio', '829 Division, Eagleton, Indiana', 4, '2010-09-05');


INSERT INTO
    ManagementHistory(studio_id, person_id, start_date)
VALUES
    -- Pawnee Recording Studio
    (1, 2, '2017-01-13'),
    (1, 1, '2018-12-02'),
    -- Pawnee Sound
    (2, 1, '2011-05-07'),
    -- Eagleton Recording Studio
    (3, 2, '2016-09-05'),
    (3, 4, '2020-09-05');


INSERT INTO
    Engineer(eng_id)
VALUES
    (5),
    (6),
    (7);


INSERT INTO 
    EngCert(eng_id, certificate)
VALUES
    (5, 'ABCDEFGH-123I'),
    (5, 'JKLMNOPQ-456R'),
    (6, 'SOUND-123-AUDIO');


INSERT INTO
    Band(name, founder_id)
VALUES
    ('Mouse Rat', 8),
    ('Duke Silver', 12),
    ('Tom Haverford', 2),
    ('Andy Dwyer', 8);


INSERT INTO
    BandMembership(band_id, person_id)
VALUES
    (1, 9),
    (1, 10),
    (1, 11);


INSERT INTO
    Session(session_id, studio_id, start_datetime, end_datetime, fee, engineer)
VALUES
    -- Mouse Rat and Duke Silver
    (1, 1, '2023-01-08 10:00:00', '2023-01-08 15:00:00', 1500, 5),
    (2, 1, '2023-01-10 13:00:00', '2023-01-11 14:00:00', 1500, 5),
    (3, 1, '2023-01-12 18:00:00', '2023-01-13 20:00:00', 1500, 5),
    -- Mouse Rat
    (4, 1, '2023-03-10 11:00:00', '2023-03-10 23:00:00', 2000, 5),
    (5, 1, '2023-03-11 13:00:00', '2023-03-12 15:00:00', 2000, 5),
    -- Andy Dwyer and Tom Haverford
    (6, 1, '2023-03-13 10:00:00', '2023-03-13 20:00:00', 1000, 7),
    -- Andy Dwyer
    (7, 3, '2023-09-25 11:00:00', '2023-09-26 23:00:00', 1000, 5),
    (8, 3, '2023-09-29 11:00:00', '2023-09-30 23:00:00', 1000, 5);


INSERT INTO 
    SomeSessionEngineers(session_id, engineer)
VALUES
    (1, 6), 
    (2, 6), 
    (3, 6);


INSERT INTO
    Play(session_id, band_id)
VALUES
    (1, 1),
    (1, 2),
    (2, 1),
    (2, 2),
    (3, 1),
    (3, 2),
    (4, 1),
    (5, 1),
    (6, 4),
    (6, 3),
    (7, 4),
    (8, 4);


-- Inserting into RecSeg Table:
-- Mouse Rat and Duke Silver Session 1
DO $$
BEGIN
    FOR i in 1..10 LOOP -- 1 to 10
    INSERT INTO RecSeg(session_id, format, length) values(1, 'WAV', '00:01:00');
    END LOOP;
END;
$$;
-- Mouse Rat and Duke Silver Session 2
DO $$
BEGIN
    FOR i in 1..5 LOOP -- 11 to 15
    INSERT INTO RecSeg(session_id, format, length) values(2, 'WAV', '00:01:00');
    END LOOP;
END;
$$;
-- Mouse Rat and Duke Silver Session 3
DO $$
BEGIN
    FOR i in 1..4 LOOP -- 16 to 19
    INSERT INTO RecSeg(session_id, format, length) values(3, 'WAV', '00:01:00');
    END LOOP;
END;
$$;
-- Mouse Rat Session 1
DO $$
BEGIN
    FOR i in 1..2 LOOP -- 20 to 21
    INSERT INTO RecSeg(session_id, format, length) values(4, 'WAV', '00:02:00');
    END LOOP;
END;
$$;
-- Andy Dwyer and Tom Haverford Session 1
DO $$
BEGIN
    FOR i in 1..5 LOOP -- 22 to 26
    INSERT INTO RecSeg(session_id, format, length) values(6, 'WAV', '00:01:00');
    END LOOP;
END;
$$;
-- Andy Dwyer Session 1
DO $$
BEGIN
    FOR i in 1..9 LOOP -- 27 to 35 (27 to 31 unusable)
    INSERT INTO RecSeg(session_id, format, length) values(7, 'AIFF', '00:03:00');
    END LOOP;
END;
$$;
-- Andy Dwyer Session 2
DO $$
BEGIN
    FOR i in 1..6 LOOP -- 36 to 41
    INSERT INTO RecSeg(session_id, format, length) values(8, 'WAV', '00:03:00');
    END LOOP;
END;
$$;


INSERT INTO
    Track(name)
VALUES
    ('5,000 Candles in the Wind'),
    ('Catch Your Dream'),
    ('May Song'),
    ('The Pit'),
    ('Remember'),
    ('The Way You Look Tonight'),
    ('Another Song');


-- Inserting into TrackSeg Table:
-- 5,000 Candles in the Wind
DO $$
BEGIN
    FOR i in 11..15 LOOP
    INSERT INTO TrackSeg(seg_id, track_id) values(i, 1);
    END LOOP;
END;
$$;
DO $$
BEGIN
    FOR i in 22..26 LOOP
    INSERT INTO TrackSeg(seg_id, track_id) values(i, 1);
    END LOOP;
END;
$$;
-- Catch Your Dream
DO $$
BEGIN
    FOR i in 16..19 LOOP
    INSERT INTO TrackSeg(seg_id, track_id) values(i, 2);
    END LOOP;
END;
$$;
DO $$
BEGIN
    FOR i in 20..21 LOOP
    INSERT INTO TrackSeg(seg_id, track_id) values(i, 2);
    END LOOP;
END;
$$;
DO $$
BEGIN
    FOR i in 22..26 LOOP
    INSERT INTO TrackSeg(seg_id, track_id) values(i, 2);
    END LOOP;
END;
$$;
-- May Song
DO $$
BEGIN
    FOR i in 32..33 LOOP
    INSERT INTO TrackSeg(seg_id, track_id) values(i, 3);
    END LOOP;
END;
$$;
-- The Pit
DO $$
BEGIN
    FOR i in 34..35 LOOP
    INSERT INTO TrackSeg(seg_id, track_id) values(i, 4);
    END LOOP;
END;
$$;
-- Remember
DO $$
BEGIN
    FOR i in 36..37 LOOP
    INSERT INTO TrackSeg(seg_id, track_id) values(i, 5);
    END LOOP;
END;
$$;
-- The Way You Look Tonight
DO $$
BEGIN
    FOR i in 38..39 LOOP
    INSERT INTO TrackSeg(seg_id, track_id) values(i, 6);
    END LOOP;
END;
$$;
-- Another Song
DO $$
BEGIN
    FOR i in 40..41 LOOP
    INSERT INTO TrackSeg(seg_id, track_id) values(i, 7);
    END LOOP;
END;
$$;


INSERT INTO
    Album(name, release_date, track_1, track_2)
VALUES
    ('The Awesome Album', '2023-05-25', 1, 2),
    ('Another Awesome Album', '2023-10-29', 3, 4);


INSERT INTO
    AlbumTrack(album_id, track_id)
VALUES
    (2, 5),
    (2, 6),
    (2, 7);
