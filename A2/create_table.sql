drop table flights;
drop table airports;

CREATE TABLE airports (
    airportid integer NOT NULL,
    city text,
    state text,
    name text,
    constraint airports_key primary key (airportid)
);

CREATE TABLE flights (
    flightid integer NOT NULL,
    originairportid integer,
    destairportid integer,
    carrier text,
    dayofmonth integer,
    dayofweek integer,
    departuredelay integer,
    arrivaldelay integer,
    constraint flights_key primary key (flightid)
);

\copy airports from '/Users/apple/Desktop/Sem7/COL362/Assignments/A2/airports.csv' delimiter ',' csv header;
\copy flights from '/Users/apple/Desktop/Sem7/COL362/Assignments/A2/flights.csv' delimiter ',' csv header;

