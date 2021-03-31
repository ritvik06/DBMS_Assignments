drop table airports;
drop table flights;

create table airports(
    "airportid" integer,
    "city" text,
    "state" text,
    "name" text,
    primary key(airportid)
);

insert into airports
values (10140, 'a', 'a_s', 'a_a'),
(10141, 'b', 'b_s', 'b_a'),
(10142, 'c', 'c_s', 'c_a'),
(10143, 'd', 'd_s', 'd_a'),
(10144, 'e', 'e_s', 'e_a')

;
-- copy batsman_scored from 'D:\sem8\DBMS\IPL DB\batsman_scored.csv' delimiter ',' CSV HEADER;

create table flights(
    flightid integer,
    originairportid integer,
    destairportid integer,
    carrier text,
    dayofmonth integer,
    dayofweek integer,
    departuredelay integer,
    arrivaldelay integer,
    primary key( flightid)
);

insert into flights
values(1,10140,10141,'boeing',1,1,0,0),
-- (2,10140,10141,'boeing',1,2,0,0),
-- (3,10140,10141,'boeing1',1,3,0,0),
(4,10141,10142,'boeing',1,1,0,0),
(5,10142,10143,'boeing',1,1,0,0),
(6,10142,10144,'boeing',1,1,0,0),
(7,10144,10141,'boeing',1,1,0,0),
(8,10143,10140,'boeing',1,1,0,0)
;

-- copy wicket_taken from 'D:\sem8\DBMS\IPL DB\wicket_taken.csv' delimiter ',' CSV HEADER;