/*
Could Not: There are no constraints that we could not be implemented. 


Did Not: The following constraints were chosen to not be implemented:

1) Each Session should have at least 1 Band Playing.
2) Each Track should have at least 1 RecSegment associated.
3) Each Track should be included in at least 1 Album.
4) Each Session can have at most 3 sound engineers.

The first three are (1, N) cardinality constraints. Here is the explanation:
These constraints could be enforced by adding a non-null additional attribute 
to each entity relationship representing the 1 required relationship between 
the two entities (for example, the Session could include an additional attribute 
denoting the band_id of the first band registered for the session). Since this 
attribute is non-null, this design would guarantee that the entity is related 
to the other entity with a cardinality of at least 1. Each additional 
relationship between entities will be tracked in the relationship relations. 

Some caveats to this method are 1) the database organization becomes less 
intuitive, 2) this solution introduces a potential for redundancy. To help 
explain these limitations, let me leave the original example of Session, Play, 
Band relations with Session including the extra attribute specifying the first 
band registered. These ideas generalize to the other two constraints that we 
chose not to enforce.  

1) We are unable to require which bands playing in a given session are 
represented in the Play relation. Although any session will have at least one 
band recorded in the Session relation, without using triggers or assertions, 
we cannot enforce that the Play relation must include the first band or that
the Play relation must not include the first band. Since we cannot guarantee
if the first relation will be included or not in the Play relation, the
intuitive role of the Play relation is no longer absolute. Those that wish to
use this interface and want to query for all bands that recorded in a session,
will have to manually understand this restriction and adjust their querying.
This design is not intuitive. Additionally, joining the Session and Play
relations may add a spurious redundant tuple. This would need to be manually
accounted for in any queries. 
- Note: The reason why the inclusion of the first band into the Play relation 
cannot be guaranteed without a trigger or assertion is that this either
requires a foreign key constraint to be satisfied (the band_id used for the
first band must already occur in the Play relation before being included in
the Session relation), or some other kind of cross table check. Implementing
this with foreign constraints would create a circular dependency between
Session and Play meaning that no tuples could be added to either relation. 
Implementing the desired behavior with a cross table check is not supported in 
Postgres and thus must be an assertion or trigger. 

2) Given the explanation in 1), it is completely possible for there to be a 
redundancy in information recorded in the database due to the inclusion of the 
first band in the Session relation. Since we cannot guarantee that the first band 
in a session is not in Play, this means there is a possibility that that piece of 
information is redundantly stored in Play as well as in Session. 

Given these caveats and since our highest priority principle is to avoid redundancy 
over enforcing constraints, we chose to not implement these three constraints. 
While the principle of having our database be intuitive is not mentioned in the 
handout, we believe that it is an important aspect of database design, 
especially since the handout hinted at future extensions to this database being 
implemented. Avoiding these unintuitive, bad designs would help our designs be 
extendable. 
We chose to not enforce these constraints in an attempt to 1) minimize redundancy 
and 2) maintain intuitive organization of our database schemas. 

However, we did choose to enforce these constraints using the same strategy for:
- Each Band should have at least 1 band member
- Each Album should have at least 2 Tracks
We reasoned that there may be many bands with only one band member since our
design requires individual people who want to participate in a session to be
part of a band. If many bands are only one person, then there is not likely to
be a lot of redundant information between the two relations and could be an easier
interface to use for bands with only one member. 
Albums would likely have a smaller relation size compared to the rest of the
relations, reducing the amount of redundant space. Albums may also be summarized
by 1 or 2 songs for simplicity. It is often the case that albums are named after
one focus song. Based on this assumed usability, we chose to include the
additional attributes in Albums. 


4) This cardinality constraint limited the number of sound engineers associated
with a session to 3 (with a minimum of one). This limit of three could be enforced
in several ways: 
- have a unique additional column to Session indicating one engineer_id and 
one engineer index for the session. The index must be 1, 2, or 3 and needs to be
unique with the session_id. This approach would not work since session_id must be 
unique in a table for it to be a foreing reference. However, if we create a separate
table for the session info, then we are removing the requirement that there be at
least 1 engineer. 
- have three engineers in the Session table, and leave two of the engineers as NULL 
optional field. This does not work with ddl since the engineers are referencing an 
engineer person_id which is a NOT NULL primary key to a table. This can be worked
around if we add an additional "NULL/filler person" entry. This requires that most
every time someone is inserting a new session tuple, they will have to do a query 
to search the null person (or know a specific id number for the null person). We 
decided against this approach as adding a null entry is unintuitive. 

Thus, we just left the Session schema to have at least 1 engineer but an unbounded
number of most engineers according to the design.


Extra Constraints: 
We added the additional constraint that the start date time of a session must
be strictly less than the end date time of the session. This is intuitive, just
was not explicitly mentioned in the handout. 
Any person who wishes to participate in a Session must register themselves
as part of a band. For those who wish to participate alone, they are able to make
a solitary band. This just simplifies the database structure, although it may
change the semantics for what a band is. 

All three engineers are different people. 

Recordings must be greater than 0 in length.

Assumptions:
We did not make any assumptions with our schema.
*/

DROP SCHEMA IF EXISTS recording CASCADE;
CREATE SCHEMA recording;
SET SEARCH_PATH TO recording;

/*
We decided to make the phone number attribute its own type
so we can ensure that the input is in the correct format.
*/
CREATE DOMAIN phoneNum AS varchar(15)
    DEFAULT NULL
    CHECK (VALUE ~ '^[0-9]+$');

/*
We made the combination of name, email, and phone number 
unique so we could ensure that a person does not get added
again if they already exist in the Person relation.
*/
CREATE TABLE Person (
    id SERIAL PRIMARY KEY,
    name varchar(50) NOT NULL,
    email varchar(50) NOT NULL,
    phone_num phoneNum NOT NULL,
    UNIQUE(name, email, phone_num)
);

/*
We made the combination of name and address unique so we
could ensure that a studio does not get added again if
it already exists in the Studio relation.
We also added an attribute called original_manager to
the attributes of Studio so we can implement the constraint
that a Studio must have a single manager at all times.
*/
CREATE TABLE Studio (
    studio_id SERIAL PRIMARY KEY,
    name varchar(50) NOT NULL,
    address varchar(250) NOT NULL,
    original_manager SERIAL REFERENCES Person,
    start_date date,
    UNIQUE(name, address)
);

/*
We made this relation to keep track of the management history of
each studio. The manager who started most recently for each studio
is the current manager, disregarding the original_manager attribute
from the Studio relation.
*/
CREATE TABLE ManagementHistory (
    studio_id SERIAL REFERENCES Studio ON DELETE CASCADE,
    person_id SERIAL REFERENCES Person ON DELETE CASCADE,
    start_date date NOT NULL,
    PRIMARY KEY(studio_id, start_date)
);

/*
We made this table specifically to store the recording
Engineers so that we can also ensure that the certificates
for engineers are given only to people in the Engineer relation.
*/
CREATE TABLE Engineer (
    eng_id SERIAL REFERENCES Person ON DELETE CASCADE,
    PRIMARY KEY(eng_id)
);

/*
We made the EngCert relation to keep track of the certificates
each engineer has.
We made the engineer's ID and the certificate the primary key
for this relation to ensure that a certificate does not get added
for an engineer if the engineer already has that certificate.
*/
CREATE TABLE EngCert (
    eng_id SERIAL REFERENCES Engineer ON DELETE CASCADE,
    certificate varchar(50) NOT NULL,
    PRIMARY KEY(eng_id, certificate)
);

/*
We made this relation to store the recording sessions.
We made sure that this relation has an engineer attribute
to ensure that every session has at least one engineer.
*/
CREATE TABLE Session (
    session_id SERIAL PRIMARY KEY,
    studio_id SERIAL REFERENCES Studio ON DELETE CASCADE,
    start_datetime timestamp NOT NULL,
    end_datetime timestamp NOT NULL,
    fee int NOT NULL,
    engineer SERIAL REFERENCES Engineer ON DELETE CASCADE,
    UNIQUE(studio_id, start_datetime),
    CONSTRAINT end_after_start
        CHECK (start_datetime < end_datetime)
);

/*
We acknowledge that we cannot enforce that the engineers included 
in the below table are or are not already included in Session without
a trigger or assert. This is a known compromise in our design.
We made this relation to keep track of any extra recording engineers
a session may include.
*/
CREATE TABLE SomeSessionEngineers(
    session_id SERIAL REFERENCES Session ON DELETE CASCADE, 
    engineer SERIAL REFERENCES Engineer ON DELETE CASCADE,
    PRIMARY KEY (session_id, engineer)
);

/*
We made this relation to keep track of the bands/solo artists
in the database.
We included an attribute called founder_id to ensure that
each band inserted into this table has at least one member
in it.
*/
CREATE TABLE Band (
    band_id SERIAL PRIMARY KEY,
    name varchar(50) NOT NULL,
    founder_id SERIAL REFERENCES Person ON DELETE CASCADE,
    UNIQUE(name)
);

/*
We acknowledge that we cannot enforce that the members included in 
the below table are or are not already included in Band without a 
trigger or assert. This is a known compromise in our design.
We made this relation to keep track of the members of a band.
*/
CREATE TABLE BandMembership (
    band_id SERIAL REFERENCES Band ON DELETE CASCADE,
    person_id SERIAL REFERENCES Person ON DELETE CASCADE,
    PRIMARY KEY(band_id, person_id)
);

/*
We made this relation to keep track of which bands/solo artists
played at each recording session.
We made the session ID and band ID the primary key to enforce
that you cannot add a value to this relation if it already exists.
*/
CREATE TABLE Play (
    session_id SERIAL REFERENCES Session(session_id) ON DELETE CASCADE,
    band_id SERIAL REFERENCES Band ON DELETE CASCADE,
    PRIMARY KEY(session_id, band_id)
);

/*
We made this relation to keep track of each recording segment
produced in a recording session.
We implemented a constraint to check if a new recording segment 
that is inserted into this relation has a recording segment 
length greater than 0 to ensure that each recording segment
added to this table actually contains some recording.
*/
CREATE TABLE RecSeg (
    seg_id SERIAL PRIMARY KEY,
    session_id SERIAL REFERENCES Session(session_id) ON DELETE CASCADE,
    format varchar(10) NOT NULL,
    length time NOT NULL, 
    CONSTRAINT length_not_zero
        CHECK (length > '00:00:00')
);

/*
We made this relation to keep track of the tracks which can possibly
be added to an album.
*/
CREATE TABLE Track (
    track_id SERIAL PRIMARY KEY,
    name varchar(50) NOT NULL
);

/*
We made this relation to keep track of which recording segments
are part of which tracks.
We made the recording segment ID and track ID the primary key
so that we could ensure that a recording segment for a track
cannot be added to this table if it already exists.
*/
CREATE TABLE TrackSeg (
    seg_id SERIAL REFERENCES RecSeg ON DELETE CASCADE,
    track_id SERIAL REFERENCES Track ON DELETE CASCADE,
    description varchar(250),
    PRIMARY KEY (seg_id, track_id)
);

/*
We created this relation to keep track of which albums are
produced.
We added two Track attributes to this relation to ensure that
each album that is created has at least two tracks on it.
We also implemented a constraint to ensure that the two tracks
needed for the creation of the album are not the same track.
*/
CREATE TABLE Album (
    album_id SERIAL PRIMARY KEY,
    name varchar(50) NOT NULL,
    release_date date NOT NULL,
    track_1 SERIAL REFERENCES Track ON DELETE CASCADE,
    track_2 SERIAL REFERENCES Track ON DELETE CASCADE,
    UNIQUE(name, release_date),
    CONSTRAINT diff_tracks
        CHECK (track_1 != track_2)
);

/*
We acknowledge that we cannot enforce that the tracks included in 
the below table are or are not already included in Album without a 
trigger or assert. This is a known compromise in our design.
We created this relation to keep track off of all of the tracks
for a given album.
*/
CREATE TABLE AlbumTrack (
    album_id SERIAL REFERENCES Album ON DELETE CASCADE,
    track_id SERIAL REFERENCES Track ON DELETE CASCADE,
    PRIMARY KEY(album_id, track_id)
);