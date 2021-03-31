-- PREAMBLE --



-- 1 --

SELECT airports.city as name 
FROM 
(WITH RECURSIVE Path (City, Carrier) AS 

(SELECT destairportid, carrier
FROM flights 
WHERE flights.originairportid = 10140

UNION

SELECT flights.destairportid, flights.carrier
FROM PATH, flights 
WHERE flights.originairportid = Path.City
AND flights.carrier = Path.Carrier)

SELECT * FROM PATH) as inter, airports

WHERE inter.City = airports.airportid

GROUP BY airports.city 
ORDER BY airports.city ASC;

-- 2 --

SELECT airports.city as name
FROM 
(WITH RECURSIVE Path (City, DayofWeek) AS 

(SELECT destairportid, dayofweek
FROM flights 
WHERE flights.originairportid = 10140

UNION

SELECT flights.destairportid, flights.dayofweek
FROM PATH, flights 
WHERE flights.originairportid = Path.City
AND flights.dayofweek = Path.dayofweek)

SELECT * FROM PATH) as inter, airports

WHERE inter.City = airports.airportid

GROUP BY airports.city 
ORDER BY airports.city ASC;

-- 3 --

WITH RECURSIVE search_path (path_arr, cycle) AS (
	SELECT array[flights.originairportid, flights.destairportid], flights.originairportid = flights.destairportid 
	FROM flights 
	WHERE flights.originairportid = 10140
	UNION (
		SELECT (path_arr || flights.destairportid), flights.destairportid = any(search_path.path_arr)
		FROM flights, search_path
		WHERE path_arr[array_length(path_arr,1)] = flights.originairportid
		AND NOT search_path.cycle
	)
)

SELECT airports.city as name
FROM search_path, airports
WHERE airports.airportid = search_path.path_arr[array_length(path_arr,1)]
GROUP BY airports.city 
HAVING COUNT(*) = 1
ORDER BY airports.city ASC;

-- 4 --

SELECT (inter.path_length-1) as length
FROM (WITH RECURSIVE search_path (path_arr, cycle) AS (
	SELECT array[flights.originairportid, flights.destairportid], flights.originairportid = flights.destairportid 
	FROM flights 
	UNION (
		SELECT (path_arr || flights.destairportid), flights.destairportid = any(search_path.path_arr)
		FROM flights, search_path
		WHERE path_arr[array_length(path_arr,1)] = flights.originairportid
		AND NOT search_path.cycle
	)
)

SELECT * from search_path, array_length(search_path.path_arr,1) as path_length
WHERE search_path.CYCLE
AND 10140 = any(search_path.path_arr)) as inter

ORDER BY inter.path_length DESC
LIMIT 1;

-- 5 --

SELECT (inter.path_length-1) as length
FROM (WITH RECURSIVE search_path (path_arr, cycle) AS (
	SELECT array[flights.originairportid, flights.destairportid], flights.originairportid = flights.destairportid 
	FROM flights 
	UNION (
		SELECT (path_arr || flights.destairportid), flights.destairportid = any(search_path.path_arr)
		FROM flights, search_path
		WHERE path_arr[array_length(path_arr,1)] = flights.originairportid
		AND NOT search_path.cycle
	)
)

SELECT * from search_path, array_length(search_path.path_arr,1) as path_length
WHERE search_path.CYCLE) as inter

ORDER BY inter.path_length DESC
LIMIT 1;

-- 6 --

SELECT COUNT(*) as count
FROM (WITH RECURSIVE search_path (path_arr, cycle) AS (
	SELECT array[flights.originairportid, flights.destairportid], flights.originairportid = flights.destairportid 
	FROM flights 

	UNION (
		SELECT (path_arr || flights.destairportid), flights.destairportid = any(search_path.path_arr)
		FROM flights, search_path, airports as a1, airports as a2
		WHERE path_arr[array_length(path_arr,1)] = flights.originairportid
		AND NOT search_path.cycle
        AND a1.airportid = flights.originairportid
        AND a2.airportid = flights.destairportid
        AND a1.state != a2.state
	)
)

SELECT * from search_path
WHERE NOT search_path.cycle) as inter, airports as a1, airports as a2 

WHERE a1.city = 'Albuquerque'
AND a2.city = 'Chicago'
AND inter.path_arr[1] = a1.airportid
AND inter.path_arr[array_length(inter.path_arr,1)] = a2.airportid;

-- 7 --

SELECT COUNT(*) as count
FROM (WITH RECURSIVE search_path (path_arr, cycle) AS (
	SELECT array[flights.originairportid, flights.destairportid], flights.originairportid = flights.destairportid 
	FROM flights 
	-- WHERE flights.originairportid = 10140
	UNION (
		SELECT (path_arr || flights.destairportid), flights.destairportid = any(search_path.path_arr)
		FROM flights, search_path
		WHERE path_arr[array_length(path_arr,1)] = flights.originairportid
		AND NOT search_path.cycle
	)
)

SELECT * from search_path
WHERE NOT search_path.cycle) as inter, airports as a1, airports as a2, airports as a3

WHERE a1.city = 'Albuquerque'
AND a2.city = 'Chicago'
AND a3.city = 'Washington'
AND inter.path_arr[1] = a1.airportid
AND inter.path_arr[array_length(inter.path_arr,1)] = a2.airportid
AND a3.airportid = any(inter.path_arr);

-- 8 --

SELECT name1, name2 FROM
(SELECT a1.city as name1, a2.city as name2
FROM airports as a1, airports as a2
WHERE a1.city != a2.city


EXCEPT

SELECT a1.city, a2.city FROM
(WITH RECURSIVE search_path (path_arr, cycle) AS (
	SELECT array[flights.originairportid, flights.destairportid], flights.originairportid = flights.destairportid 
	FROM flights 
	UNION (
		SELECT (path_arr || flights.destairportid), flights.destairportid = any(search_path.path_arr)
		FROM flights, search_path
		WHERE path_arr[array_length(path_arr,1)] = flights.originairportid
		AND NOT search_path.cycle
	)
) 

SELECT path_arr[1] as origin, path_arr[array_length(path_arr,1)] as dest FROM search_path) as inter1, airports as a1, airports as a2

WHERE inter1.origin = a1.airportid
AND inter1.dest = a2.airportid
and a1.city!=a2.city) as inter1
ORDER BY name1 ASC,
name2 ASC;

-- 9 --

SELECT inter.day FROM 

(WITH RECURSIVE days_of_month(day, val) AS(
    SELECT 1, 0 
    FROM flights 

    UNION 

    SELECT day+1, 0
    FROM days_of_month
    WHERE day<31
)

SELECT * FROM days_of_month

UNION 

(SELECT inter.dayofmonth as day, SUM(inter.total_delay) FROM
(SELECT destairportid, carrier, dayofmonth, (flights.arrivaldelay+flights.departuredelay) as total_delay
FROM flights 
WHERE flights.originairportid = 10140) as inter

GROUP BY inter.dayofmonth
ORDER BY SUM(inter.total_delay) ASC,
inter.dayofmonth ASC)) as inter

GROUP BY inter.day

ORDER BY SUM(inter.val) ASC,
inter.day ASC;

-- 10 --

SELECT a1.city as name 
FROM (SELECT COUNT(*) as num_airports
FROM airports
WHERE airports.state = 'New York') as inter, flights, airports as a1, airports as a2

WHERE flights.originairportid = a1.airportid
AND flights.destairportid = a2.airportid
AND a1.state = 'New York'
AND a2.state = 'New York'

GROUP BY a1.city, inter.num_airports
HAVING COUNT(*) = inter.num_airports-1

ORDER BY a1.city ASC;

-- 11 --

SELECT a1.city as name1, a2.city as name2 FROM
(WITH RECURSIVE search_path (path_arr, cycle, delay_arr) AS (
	SELECT array[flights.originairportid, flights.destairportid], flights.originairportid = flights.destairportid, array[0, flights.arrivaldelay+flights.departuredelay]
	FROM flights 

	UNION (
		SELECT (path_arr || flights.destairportid), flights.destairportid = any(search_path.path_arr), delay_arr || (flights.arrivaldelay+flights.departuredelay)
		FROM flights, search_path
		WHERE path_arr[array_length(path_arr,1)] = flights.originairportid
		AND NOT search_path.cycle
        AND delay_arr[array_length(delay_arr,1)] <= (flights.arrivaldelay+flights.departuredelay) 
	)
) 

SELECT path_arr[1] as origin, path_arr[array_length(path_arr,1)] as dest FROM search_path) as inter, airports as a1, airports as a2

WHERE a1.airportid = inter.origin
AND a2.airportid = inter.dest

GROUP BY a1.city, a2.city
ORDER BY a1.city ASC,
a2.city ASC;

-- 12 --

SELECT inter1.author2 as authorid, MIN(inter1.path_length) as length
FROM 
(SELECT inter.path_arr[1] as author1, inter.path_arr[array_length(inter.path_arr,1)] as author2, array_length(inter.path_arr,1)-1 as path_length
FROM 
(WITH RECURSIVE search_path (path_arr, cycle) AS (
	SELECT array[authord1.authorid, authord2.authorid], authord1.authorid = authord2.authorid
	FROM authordetails as authord1, authordetails as authord2, authorpaperlist as p1, authorpaperlist as p2
	WHERE authord1.authorid = 1235
    AND p1.authorid = authord1.authorid
    AND p2.authorid = authord2.authorid
    AND p1.paperid = p2.paperid
    AND NOT authord1.authorid = authord2.authorid


	UNION (
		SELECT (path_arr || authord2.authorid), authord2.authorid = any(search_path.path_arr)
		FROM search_path, authordetails as authord1, authordetails as authord2, authorpaperlist as p1, authorpaperlist as p2
		WHERE path_arr[array_length(path_arr,1)] = authord1.authorid
        AND p1.authorid = authord1.authorid
        AND p2.authorid = authord2.authorid
        AND p1.paperid = p2.paperid
		AND NOT search_path.cycle
        AND NOT p1.authorid = p2.authorid
	)
)

SELECT * from search_path
WHERE NOT search_path.cycle) as inter) as inter1

GROUP BY inter1.author2

UNION

SELECT authord2.authorid, -1 as min
FROM authordetails as authord1, authordetails as authord2
WHERE authord1.authorid != authord2.authorid
AND authord1.authorid = 1235

EXCEPT 

(WITH RECURSIVE search_path (path_arr, cycle) AS (
	SELECT array[authord1.authorid, authord2.authorid], authord1.authorid = authord2.authorid
	FROM authordetails as authord1, authordetails as authord2, authorpaperlist as p1, authorpaperlist as p2
	WHERE authord1.authorid = 1235
    AND p1.authorid = authord1.authorid
    AND p2.authorid = authord2.authorid
    AND p1.paperid = p2.paperid
    AND NOT authord1.authorid = authord2.authorid


	UNION (
		SELECT (path_arr || authord2.authorid), authord2.authorid = any(search_path.path_arr)
		FROM search_path, authordetails as authord1, authordetails as authord2, authorpaperlist as p1, authorpaperlist as p2
		WHERE path_arr[array_length(path_arr,1)] = authord1.authorid
        AND p1.authorid = authord1.authorid
        AND p2.authorid = authord2.authorid
        AND p1.paperid = p2.paperid
		AND NOT search_path.cycle
        AND NOT p1.authorid = p2.authorid

	)
)

SELECT path_arr[array_length(path_arr,1)] as authorid, -1 FROM search_path
WHERE NOT search_path.cycle)

ORDER BY length DESC,
        authorid ASC;

-- 13 --

SELECT COUNT(*) as count
FROM 
(WITH RECURSIVE search_path (path_arr, cycle) AS (
	SELECT array[authord1.authorid, authord2.authorid], authord1.authorid = authord2.authorid
	FROM authordetails as authord1, authordetails as authord2, authorpaperlist as p1, authorpaperlist as p2
	WHERE authord1.authorid = 1558
    AND p1.authorid = authord1.authorid
    AND p2.authorid = authord2.authorid
    AND p1.paperid = p2.paperid
    AND NOT authord1.authorid = authord2.authorid

    AND (authord2.age > 35 OR authord2.authorid = 2826)

	UNION (
		SELECT (path_arr || authord2.authorid), authord2.authorid = any(search_path.path_arr)
		FROM search_path, authordetails as authord1, authordetails as authord2, authorpaperlist as p1, authorpaperlist as p2
		WHERE path_arr[array_length(path_arr,1)] = authord1.authorid
        AND p1.authorid = authord1.authorid
        AND p2.authorid = authord2.authorid
        AND p1.paperid = p2.paperid
		AND NOT search_path.cycle
        AND NOT p1.authorid = p2.authorid
        AND (authord1.age > 35 OR authord1.authorid = 1558)
        AND (authord2.age > 35 OR authord2.authorid = 2826)
        AND (authord1.gender!=authord2.gender OR authord2.authorid = 2826)
	)
)

SELECT * from search_path
WHERE NOT search_path.cycle) as inter

WHERE inter.path_arr[array_length(inter.path_arr,1)] = 2826

HAVING COUNT(*)>0

UNION 

(SELECT 0 as count)

ORDER BY count DESC
LIMIT 1;

-- 14 -- 

SELECT COUNT(*) FROM
(SELECT path_nodes.path_array

FROM 

(WITH RECURSIVE search_path (path_arr, cycle) AS (
	SELECT array[authord1.authorid, authord2.authorid], authord1.authorid = authord2.authorid
	FROM authordetails as authord1, authordetails as authord2, authorpaperlist as p1, authorpaperlist as p2

	WHERE authord1.authorid = 704
    AND p1.authorid = authord1.authorid
    AND p2.authorid = authord2.authorid
    AND p1.paperid = p2.paperid
    AND NOT authord1.authorid = authord2.authorid
    AND NOT authord2.authorid = 102


	UNION (
		SELECT (path_arr || authord2.authorid), authord2.authorid = any(search_path.path_arr)
		FROM search_path, authordetails as authord1, authordetails as authord2, authorpaperlist as p1, authorpaperlist as p2
		WHERE path_arr[array_length(path_arr,1)] = authord1.authorid
        AND p1.authorid = authord1.authorid
        AND p2.authorid = authord2.authorid
        AND p1.paperid = p2.paperid
		AND NOT search_path.cycle
        AND NOT p1.authorid = p2.authorid
        AND NOT authord2.authorid = 704
	)
)

SELECT path_arr[2:array_length(path_arr,1)-1] as path_array from search_path
WHERE  path_arr[array_length(path_arr,1)] = 102
AND NOT search_path.cycle) as path_nodes,


(WITH RECURSIVE cite_path (cite_arr, cycle) AS (
	SELECT array[citationlist.paperid2, citationlist.paperid1], citationlist.paperid1 = citationlist.paperid2
	FROM citationlist
	WHERE citationlist.paperid2 = 126
    AND citationlist.paperid1 != citationlist.paperid2

	UNION

	(	SELECT (cite_arr || citationlist.paperid1), citationlist.paperid1 = any(cite_path.cite_arr)
		FROM citationlist, cite_path
		WHERE cite_arr[array_length(cite_arr,1)] = citationlist.paperid2

	)
)

SELECT cite_arr[array_length(cite_arr,1)] as paper from cite_path
WHERE NOT cite_path.cycle
GROUP BY cite_arr[array_length(cite_arr,1)]) as cite_papers, authorpaperlist

WHERE cite_papers.paper = authorpaperlist.paperid
AND authorpaperlist.authorid = any(path_nodes.path_array)

GROUP BY path_nodes.path_array) as alpha

UNION 

(SELECT 0 as count)

ORDER BY count DESC
LIMIT 1;

-- 15 --

SELECT COUNT(*) FROM 

(

    WITH RECURSIVE search_path (path_arr, cycle) AS (
	SELECT array[authord1.authorid, authord2.authorid], authord1.authorid = authord2.authorid
	FROM authordetails as authord1, authordetails as authord2, authorpaperlist as p1, authorpaperlist as p2

	WHERE authord1.authorid = 1745
    AND p1.authorid = authord1.authorid
    AND p2.authorid = authord2.authorid
    AND p1.paperid = p2.paperid
    AND NOT authord1.authorid = authord2.authorid
    AND NOT authord2.authorid = 456


	UNION (
		SELECT (path_arr || authord2.authorid), authord2.authorid = any(search_path.path_arr)
		FROM search_path, authordetails as authord1, authordetails as authord2, authorpaperlist as p1, authorpaperlist as p2,

(SELECT authorpaperlist.authorid, inter.count
FROM 
(WITH RECURSIVE cite_path (cite_arr, cycle) AS (
	SELECT array[citationlist.paperid2, citationlist.paperid1], citationlist.paperid1 = citationlist.paperid2
	FROM citationlist
	WHERE citationlist.paperid1 != citationlist.paperid2

	UNION

	(	SELECT (cite_arr || citationlist.paperid1), citationlist.paperid1 = any(cite_path.cite_arr)
		FROM citationlist, cite_path
		WHERE cite_arr[array_length(cite_arr,1)] = citationlist.paperid2

	)
)

SELECT cite_arr[1] as paper, COUNT(*) as count from cite_path
WHERE NOT cite_path.cycle
GROUP BY cite_arr[1]
ORDER BY COUNT(*) DESC) as inter, authorpaperlist

WHERE authorpaperlist.paperid = inter.paper
ORDER BY inter.count DESC) as author_cites1, 

(SELECT authorpaperlist.authorid, inter.count
FROM 
(WITH RECURSIVE cite_path (cite_arr, cycle) AS (
	SELECT array[citationlist.paperid2, citationlist.paperid1], citationlist.paperid1 = citationlist.paperid2
	FROM citationlist
	WHERE citationlist.paperid1 != citationlist.paperid2

	UNION

	(	SELECT (cite_arr || citationlist.paperid1), citationlist.paperid1 = any(cite_path.cite_arr)
		FROM citationlist, cite_path
		WHERE cite_arr[array_length(cite_arr,1)] = citationlist.paperid2

	)
)

SELECT cite_arr[1] as paper, COUNT(*) as count from cite_path
WHERE NOT cite_path.cycle
GROUP BY cite_arr[1]
ORDER BY COUNT(*) DESC) as inter, authorpaperlist

WHERE authorpaperlist.paperid = inter.paper
ORDER BY inter.count DESC) as author_cites2


		WHERE path_arr[array_length(path_arr,1)] = authord1.authorid
        AND p1.authorid = authord1.authorid
        AND p2.authorid = authord2.authorid
        AND author_cites1.authorid = authord1.authorid
        AND author_cites2.authorid = authord2.authorid
        AND p1.paperid = p2.paperid
		AND NOT search_path.cycle
        AND NOT p1.authorid = p2.authorid
        AND NOT authord2.authorid = 1745
        AND (author_cites1.count > author_cites2.count OR author_cites2.authorid = 456)
	) 
)

SELECT path_arr[2:array_length(path_arr,1)-1] as path_array from search_path
WHERE search_path.path_arr[array_length(search_path.path_arr,1)] = 456
AND NOT search_path.cycle









UNION 










(WITH RECURSIVE search_path (path_arr, cycle) AS (
	SELECT array[authord1.authorid, authord2.authorid], authord1.authorid = authord2.authorid
	FROM authordetails as authord1, authordetails as authord2, authorpaperlist as p1, authorpaperlist as p2

	WHERE authord1.authorid = 1745
    AND p1.authorid = authord1.authorid
    AND p2.authorid = authord2.authorid
    AND p1.paperid = p2.paperid
    AND NOT authord1.authorid = authord2.authorid
    AND NOT authord2.authorid = 456


	UNION (
		SELECT (path_arr || authord2.authorid), authord2.authorid = any(search_path.path_arr)
		FROM search_path, authordetails as authord1, authordetails as authord2, authorpaperlist as p1, authorpaperlist as p2,

(SELECT authorpaperlist.authorid, inter.count
FROM 
(WITH RECURSIVE cite_path (cite_arr, cycle) AS (
	SELECT array[citationlist.paperid2, citationlist.paperid1], citationlist.paperid1 = citationlist.paperid2
	FROM citationlist
	WHERE citationlist.paperid1 != citationlist.paperid2

	UNION

	(	SELECT (cite_arr || citationlist.paperid1), citationlist.paperid1 = any(cite_path.cite_arr)
		FROM citationlist, cite_path
		WHERE cite_arr[array_length(cite_arr,1)] = citationlist.paperid2

	)
)

SELECT cite_arr[1] as paper, COUNT(*) as count from cite_path
WHERE NOT cite_path.cycle
GROUP BY cite_arr[1]
ORDER BY COUNT(*) DESC) as inter, authorpaperlist

WHERE authorpaperlist.paperid = inter.paper
ORDER BY inter.count DESC) as author_cites1, 

(SELECT authorpaperlist.authorid, inter.count
FROM 
(WITH RECURSIVE cite_path (cite_arr, cycle) AS (
	SELECT array[citationlist.paperid2, citationlist.paperid1], citationlist.paperid1 = citationlist.paperid2
	FROM citationlist
	WHERE citationlist.paperid1 != citationlist.paperid2

	UNION

	(	SELECT (cite_arr || citationlist.paperid1), citationlist.paperid1 = any(cite_path.cite_arr)
		FROM citationlist, cite_path
		WHERE cite_arr[array_length(cite_arr,1)] = citationlist.paperid2

	)
)

SELECT cite_arr[1] as paper, COUNT(*) as count from cite_path
WHERE NOT cite_path.cycle
GROUP BY cite_arr[1]
ORDER BY COUNT(*) DESC) as inter, authorpaperlist

WHERE authorpaperlist.paperid = inter.paper
ORDER BY inter.count DESC) as author_cites2


		WHERE path_arr[array_length(path_arr,1)] = authord1.authorid
        AND p1.authorid = authord1.authorid
        AND p2.authorid = authord2.authorid
        AND author_cites1.authorid = authord1.authorid
        AND author_cites2.authorid = authord2.authorid
        AND p1.paperid = p2.paperid
		AND NOT search_path.cycle
        AND NOT p1.authorid = p2.authorid
        AND NOT authord2.authorid = 1745
        AND (author_cites1.count < author_cites2.count  OR author_cites2.authorid = 456)
	)
)

SELECT path_arr[2:array_length(path_arr,1)-1] as path_array from search_path
WHERE search_path.path_arr[array_length(search_path.path_arr,1)] = 456
AND NOT search_path.cycle)


) as test

UNION 

(SELECT 0 as count)

ORDER BY count DESC
LIMIT 1;

-- 16 --

SELECT inter3.author_who_cites as authorid FROM
(SELECT a1.authorid as author_who_cites, a2.authorid as main_author
FROM 
(WITH RECURSIVE cite_path (cite_arr, cycle) AS (
	SELECT array[citationlist.paperid2, citationlist.paperid1], citationlist.paperid1 = citationlist.paperid2
	FROM citationlist
	WHERE citationlist.paperid1 != citationlist.paperid2

	UNION

	(	SELECT (cite_arr || citationlist.paperid1), citationlist.paperid1 = any(cite_path.cite_arr)
		FROM citationlist, cite_path
		WHERE cite_arr[array_length(cite_arr,1)] = citationlist.paperid2

	)
)

SELECT cite_arr[1] as cited_paper, cite_arr[array_length(cite_arr,1)] as paper from cite_path
WHERE NOT cite_path.cycle
GROUP BY cite_arr[1], cite_arr[array_length(cite_arr,1)]
ORDER BY COUNT(*) DESC) as inter, authorpaperlist as a1, authorpaperlist as a2

WHERE a2.paperid = inter.cited_paper
AND a1.paperid = inter.paper
AND a1.authorid != a2.authorid

GROUP BY a1.authorid, a2.authorid

INTERSECT

(SELECT a1.authorid as author_who_cites, a2.authorid as main_author
FROM authorpaperlist as a1, authorpaperlist as a2
WHERE a1.authorid!=a2.authorid

EXCEPT

(SELECT a1.authorid, a2.authorid
FROM authorpaperlist as a1, authorpaperlist as a2
WHERE a1.paperid = a2.paperid
AND a1.authorid!=a2.authorid
GROUP BY a1.authorid, a2.authorid))) as inter3

GROUP BY inter3.author_who_cites
ORDER BY COUNT(*) DESC, inter3.author_who_cites ASC
LIMIT 10;

-- 17 -- 

SELECT gamma.source as authorid
FROM
(SELECT alpha.source, alpha.dest, beta.count

FROM

(SELECT inter2.source, inter2.dest
FROM
(SELECT inter1.source, inter1.dest, MIN(inter1.path_length) as min_length
FROM 
(SELECT inter.path_array[1] as source, inter.path_array[array_length(inter.path_array,1)] as dest, array_length(inter.path_array,1)-1 as path_length
FROM 
(WITH RECURSIVE search_path (path_arr, cycle) AS (
	SELECT array[authord1.authorid, authord2.authorid], authord1.authorid = authord2.authorid
	FROM authordetails as authord1, authordetails as authord2, authorpaperlist as p1, authorpaperlist as p2
	WHERE p1.authorid = authord1.authorid
    AND p2.authorid = authord2.authorid
    AND p1.paperid = p2.paperid
    AND NOT authord1.authorid = authord2.authorid


	UNION (
		SELECT (path_arr || authord2.authorid), authord2.authorid = any(search_path.path_arr)
		FROM search_path, authordetails as authord1, authordetails as authord2, authorpaperlist as p1, authorpaperlist as p2
		WHERE path_arr[array_length(path_arr,1)] = authord1.authorid
        AND p1.authorid = authord1.authorid
        AND p2.authorid = authord2.authorid
        AND p1.paperid = p2.paperid
		AND NOT search_path.cycle
        AND NOT p1.authorid = p2.authorid
	)
)

SELECT path_arr as path_array from search_path
WHERE  NOT search_path.cycle) as inter) as inter1

GROUP BY inter1.source, inter1.dest 
ORDER BY inter1.source) as inter2

WHERE inter2.min_length = 3
ORDER BY inter2.source) as alpha,

(SELECT inter1.main_author, COUNT(*)
FROM
(SELECT a1.paperid, a2.paperid, a2.authorid as main_author
FROM 
(WITH RECURSIVE cite_path (cite_arr, cycle) AS (
	SELECT array[citationlist.paperid2, citationlist.paperid1], citationlist.paperid1 = citationlist.paperid2
	FROM citationlist
	WHERE citationlist.paperid1 != citationlist.paperid2

	UNION

	(	SELECT (cite_arr || citationlist.paperid1), citationlist.paperid1 = any(cite_path.cite_arr)
		FROM citationlist, cite_path
		WHERE cite_arr[array_length(cite_arr,1)] = citationlist.paperid2

	)
)

SELECT cite_arr[1] as cited_paper, cite_arr[array_length(cite_arr,1)] as paper from cite_path
WHERE NOT cite_path.cycle
GROUP BY cite_arr[1], cite_arr[array_length(cite_arr,1)]
ORDER BY COUNT(*) DESC) as inter, authorpaperlist as a1, authorpaperlist as a2, authorpaperlist as a3

WHERE a2.paperid = inter.cited_paper
AND a1.paperid = inter.paper
AND a1.authorid != a2.authorid
AND a3.authorid = a2.authorid
AND a3.paperid != a1.paperid

GROUP BY a1.paperid, a2.paperid, a2.authorid) as inter1

GROUP BY inter1.main_author
ORDER BY COUNT(*) DESC) as beta

WHERE alpha.dest = beta.main_author
ORDER BY alpha.source, beta.count DESC) as gamma

GROUP BY gamma.source
ORDER BY SUM(gamma.count) DESC,
gamma.source ASC

LIMIT 10;

-- 18 --

SELECT COUNT(*) as count FROM
(WITH RECURSIVE search_path (path_arr, cycle, is_there) AS (
	SELECT array[authord1.authorid, authord2.authorid], authord1.authorid = authord2.authorid, authord1.authorid = authord2.authorid
	FROM authordetails as authord1, authordetails as authord2, authorpaperlist as p1, authorpaperlist as p2

	WHERE authord1.authorid = 3552
    AND p1.authorid = authord1.authorid
    AND p2.authorid = authord2.authorid
    AND p1.paperid = p2.paperid
    AND NOT authord1.authorid = authord2.authorid
    AND NOT authord2.authorid = 321


	UNION (
		SELECT (path_arr || authord2.authorid), authord2.authorid = any(search_path.path_arr), 1436 = any(search_path.path_arr) OR 562 = any(search_path.path_arr) OR 921 = any(search_path.path_arr)
		FROM search_path, authordetails as authord1, authordetails as authord2, authorpaperlist as p1, authorpaperlist as p2
		WHERE path_arr[array_length(path_arr,1)] = authord1.authorid
        AND p1.authorid = authord1.authorid
        AND p2.authorid = authord2.authorid
        AND p1.paperid = p2.paperid
		AND NOT search_path.cycle
        AND NOT p1.authorid = p2.authorid
        AND NOT authord2.authorid = 3552
	)
)

SELECT path_arr[1:array_length(path_arr,1)] as path_array from search_path
WHERE  path_arr[array_length(path_arr,1)] = 321
AND NOT search_path.cycle
AND search_path.is_there) as alpha;

-- 19 --

    SELECT count FROM 

    (SELECT COUNT(*) as count
    
    FROM
    (
        SELECT inter1.path_arr
    FROM 
    (
        WITH RECURSIVE search_path (path_arr, city_arr, city_cycle, cycle) AS (
	SELECT array[authord1.authorid, authord2.authorid], array[authord1.city], authord1.authorid = authord2.authorid, authord1.authorid = authord2.authorid
	FROM authordetails as authord1, authordetails as authord2, authorpaperlist as p1, authorpaperlist as p2

	WHERE authord1.authorid = 3552
    AND p1.authorid = authord1.authorid
    AND p2.authorid = authord2.authorid
    AND p1.paperid = p2.paperid
    AND NOT authord1.authorid = authord2.authorid
    AND NOT authord2.authorid = 321


	UNION (
		SELECT (path_arr || authord2.authorid), (city_arr || authord1.city), authord1.city = any(search_path.city_arr[2:array_length(search_path.city_arr,1)]), authord2.authorid = any(search_path.path_arr)
		FROM search_path, authordetails as authord1, authordetails as authord2, authorpaperlist as p1, authorpaperlist as p2
		WHERE path_arr[array_length(path_arr,1)] = authord1.authorid
        AND p1.authorid = authord1.authorid
        AND p2.authorid = authord2.authorid
        AND p1.paperid = p2.paperid
		AND NOT search_path.cycle
        AND NOT search_path.city_cycle
        AND NOT p1.authorid = p2.authorid
        AND NOT authord2.authorid = 3552
	)
)

SELECT path_arr[2:array_length(path_arr,1)-1], city_arr[2:array_length(city_arr,1)] from search_path
WHERE path_arr[array_length(path_arr,1)] = 321
AND NOT search_path.cycle
AND NOT search_path.city_cycle

) as inter1,



(SELECT authord1.authorid as author1, authord2.authorid as author2

FROM authordetails as authord1, authordetails as authord2, authorpaperlist as a1, authorpaperlist as a2, citationlist

WHERE authord1.authorid != authord2.authorid
AND a1.authorid = authord1.authorid
AND a2.authorid = authord2.authorid

AND ((citationlist.paperid1 = a1.paperid AND NOT (citationlist.paperid2 = a2.paperid))
OR (citationlist.paperid1 = a2.paperid AND NOT(citationlist.paperid2 = a1.paperid)))

GROUP BY authord1.authorid, authord2.authorid) as inter2


WHERE (inter2.author1 = any(inter1.path_arr)
AND inter2.author2 = any(inter1.path_arr))
OR
(array_length(inter1.path_arr,1) = 1)

GROUP BY inter1.path_arr
HAVING (COUNT(*) = array_length(inter1.path_arr, 1)*(array_length(inter1.path_arr, 1) - 1) AND array_length(inter1.path_arr, 1) > 1) OR (array_length(inter1.path_arr, 1) = 1)
) as alpha
) as alpha2

UNION 

(SELECT -1 as count)

ORDER BY count DESC
LIMIT 1;

-- 20 --

    SELECT count FROM 

    (SELECT COUNT(*) as count
    
    FROM
    (
        SELECT inter1.path_arr
    FROM 
    (
        WITH RECURSIVE search_path (path_arr, cycle) AS (
	SELECT array[authord1.authorid, authord2.authorid], authord1.authorid = authord2.authorid
	FROM authordetails as authord1, authordetails as authord2, authorpaperlist as p1, authorpaperlist as p2

	WHERE authord1.authorid = 3552
    AND p1.authorid = authord1.authorid
    AND p2.authorid = authord2.authorid
    AND p1.paperid = p2.paperid
    AND NOT authord1.authorid = authord2.authorid
    AND NOT authord2.authorid = 321


	UNION (
		SELECT (path_arr || authord2.authorid), authord2.authorid = any(search_path.path_arr)
		FROM search_path, authordetails as authord1, authordetails as authord2, authorpaperlist as p1, authorpaperlist as p2
		WHERE path_arr[array_length(path_arr,1)] = authord1.authorid
        AND p1.authorid = authord1.authorid
        AND p2.authorid = authord2.authorid
        AND p1.paperid = p2.paperid
		AND NOT search_path.cycle
        AND NOT p1.authorid = p2.authorid
        AND NOT authord2.authorid = 3552
	)
)

SELECT path_arr[2:array_length(path_arr,1)-1] from search_path
WHERE path_arr[array_length(path_arr,1)] = 321
AND NOT search_path.cycle

) as inter1,

(
SELECT a1.authorid as author1, a2.authorid as author2
FROM authorpaperlist as a1, authorpaperlist as a2
WHERE a1.authorid != a2.authorid

EXCEPT
     
SELECT a1.authorid as author1, a2.authorid as author2
FROM 
(WITH RECURSIVE cite_path (cite_arr, cycle) AS (
	SELECT array[citationlist.paperid2, citationlist.paperid1], citationlist.paperid1 = citationlist.paperid2
	FROM citationlist
	WHERE citationlist.paperid1 != citationlist.paperid2

	UNION

	(	SELECT (cite_arr || citationlist.paperid1), citationlist.paperid1 = any(cite_path.cite_arr)
		FROM citationlist, cite_path
		WHERE cite_arr[array_length(cite_arr,1)] = citationlist.paperid2

	)
)

SELECT cite_arr[1] as cited_paper, cite_arr[array_length(cite_arr,1)] as paper from cite_path
WHERE NOT cite_path.cycle
GROUP BY cite_arr[1], cite_arr[array_length(cite_arr,1)]
ORDER BY COUNT(*) DESC) as inter, authorpaperlist as a1, authorpaperlist as a2

WHERE a2.paperid = inter.cited_paper
AND a1.paperid = inter.paper
AND a1.authorid != a2.authorid

GROUP BY a1.authorid, a2.authorid) as inter2


WHERE (inter2.author1 = any(inter1.path_arr)
AND inter2.author2 = any(inter1.path_arr))
OR
(array_length(inter1.path_arr,1) = 1)

GROUP BY inter1.path_arr
HAVING (COUNT(*) = array_length(inter1.path_arr, 1)*(array_length(inter1.path_arr, 1) - 1) AND array_length(inter1.path_arr, 1) > 1) OR (array_length(inter1.path_arr, 1) = 1)
) as alpha) as alpha2

UNION 

(SELECT -1 as count)

ORDER BY count DESC
LIMIT 1;

-- 21 --

-- 22 -- 

-- CLEANUP --

