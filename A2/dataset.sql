drop table airports cascade;
drop table flights cascade;

create table airports (
  airportid int,
  city varchar(30),
  state varchar(30),
  name varchar(30)
);
create table flights(
  flightid int,
  originairportid int,
  destairportid int,
  carrier varchar(30),
  dayofmonth int,
  dayofweek int,
  departuredelay int,
  arrivaldelay int
);


insert into airports (airportid, city, state, name) values (10140, 'Albuquerque', 'New Mexico', 'airport1');
insert into airports (airportid, city, state, name) values (2, 'Hobbs', 'New Mexico', 'airport2');
insert into airports (airportid, city, state, name) values (3, 'Bharuch', 'Gujarat', 'airport3');
insert into airports (airportid, city, state, name) values (4, 'Taos', 'New Mexico', 'airport4');
insert into airports (airportid, city, state, name) values (5, 'Surat', 'Gujarat', 'airport5');
insert into airports (airportid, city, state, name) values (6, 'Chicago', 'Illinois', 'airport6');
insert into airports (airportid, city, state, name) values (7, 'Pasco', 'Washington', 'airport7');
insert into airports (airportid, city, state, name) values (8, 'Forks', 'Washington', 'airport8');
insert into airports (airportid, city, state, name) values (9, 'New York City', 'New York', 'airport9');
insert into airports (airportid, city, state, name) values (10, 'Albany', 'New York', 'airport10');
insert into airports (airportid, city, state, name) values (11, 'Buffalo', 'New York', 'airport11');

insert into flights (flightid, originairportid, destairportid, carrier, dayofmonth, dayofweek, departuredelay, arrivaldelay)
values (1, 10140, 3, 'Air India', 1, 2, 1, -1);
insert into flights (flightid, originairportid, destairportid, carrier, dayofmonth, dayofweek, departuredelay, arrivaldelay)
values (2, 3, 2, 'Air India', 1, 1, 1, 0);
insert into flights (flightid, originairportid, destairportid, carrier, dayofmonth, dayofweek, departuredelay, arrivaldelay)
values (3, 2, 10140, 'Air India', 1, 1, 0, 2);
insert into flights (flightid, originairportid, destairportid, carrier, dayofmonth, dayofweek, departuredelay, arrivaldelay)
values (4, 10140, 4, 'Spice Jet', 2, 4, 1, 1);
insert into flights (flightid, originairportid, destairportid, carrier, dayofmonth, dayofweek, departuredelay, arrivaldelay)
values (5, 4, 5, 'Air India', 1, 4, 1, 1);
insert into flights (flightid, originairportid, destairportid, carrier, dayofmonth, dayofweek, departuredelay, arrivaldelay)
values (6, 3, 5, 'Spice Jet', 1, 3, 1, 1);
insert into flights (flightid, originairportid, destairportid, carrier, dayofmonth, dayofweek, departuredelay, arrivaldelay)
values (7, 3, 5, 'Indigo', 1, 3, 1, 1);
insert into flights (flightid, originairportid, destairportid, carrier, dayofmonth, dayofweek, departuredelay, arrivaldelay)
values (8, 10140, 6, 'Air India', 3, 1, 1, 7);
insert into flights (flightid, originairportid, destairportid, carrier, dayofmonth, dayofweek, departuredelay, arrivaldelay)
values (9, 3, 7, 'Air India', 1, 1, 1, 1);
insert into flights (flightid, originairportid, destairportid, carrier, dayofmonth, dayofweek, departuredelay, arrivaldelay)
values (10, 7, 6, 'Air India', 1, 1, 1, 1);
insert into flights (flightid, originairportid, destairportid, carrier, dayofmonth, dayofweek, departuredelay, arrivaldelay)
values (11, 9, 11, 'Us Flights', 1, 1, 1, 1);
insert into flights (flightid, originairportid, destairportid, carrier, dayofmonth, dayofweek, departuredelay, arrivaldelay)
values (12, 10, 9, 'Us Flights', 1, 1, 1, 1);
insert into flights (flightid, originairportid, destairportid, carrier, dayofmonth, dayofweek, departuredelay, arrivaldelay)
values (13, 10, 11, 'Us Flights', 1, 1, 1, 1);
insert into flights (flightid, originairportid, destairportid, carrier, dayofmonth, dayofweek, departuredelay, arrivaldelay)
values (14, 11, 9, 'Us Flights', 1, 1, 1, 1);
insert into flights (flightid, originairportid, destairportid, carrier, dayofmonth, dayofweek, departuredelay, arrivaldelay)
values (15, 11, 10, 'Us Flights', 1, 1, 1, 1);