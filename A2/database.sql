
create table authordetails(
	authorid int primary key,
	city text,
	gender char,
	age int
);

insert into authordetails 
values (1,'a','m',40),(2,'b','f',40),(3,'c','m',40),(4,'a','m',40),(5,'d','f',40),(6,'a','m',40),
(7,'b','f',40),(8,'d','f',40),(9,'e','f',40),(10,'c','m',40),(11,'d','m',40),(12,'b','m',40);

-- delete from authordetails;


create table authorpaperlist (
	authorid int,
	paperid int,
	primary key(authorid,paperid)
);

insert into authorpaperlist 
values (1,100),(1,101),(1,102),
(2,100),(2,106),
(3,100),(3,108),(3,105),
(4,103),(4,104),(4,106),
(5,103),
(6,103),(6,101),
(7,104),(7,105),
(8,102),(8,107),
(9,107),(9,108),
(10,109),
(11,109),
(12,107);

-- delete from authorpaperlist;


create table citationlist (
	paperid1 int,
	paperid2 int,
	primary key(paperid1,paperid2)
);

insert into citationlist 
values (100,104),(100,101),(100,103),
(103,107),(103,101),
(107,104),
(108,100); 

-- delete from citationlist;


create table paperdetails(
	paperid int primary key,
	conferencename text
);

insert into paperdetails
values (100,'conf1'),
(101,'conf2'),
(102,'conf2'),
(103,'conf2'),
(104,'conf1'),
(105,'conf3'),
(106,'conf2'),
(107,'conf3'),
(108,'conf2'),
(109,'conf2');

