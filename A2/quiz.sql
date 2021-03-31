(SELECT alpha.main_paper, COUNT(*) FROM
SELECT a1.paperid, a2.paperid as main_paper
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

GROUP BY a1.paperid, a2.paperid) as alpha

GROUP BY alpha.main_paper
HAVING COUNT(*)>4) as table1,


WITH RECURSIVE search_path (path_arr, cycle) AS (
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

SELECT path_arr FROM search_path
WHERE NOT search_path.cycle
AND search_path.path_arr[1] = 1
AND search_path.path_arr[array_length(search_path.path_arr,1)] = 5
GROUP BY path_arr
ORDER BY array_length(path_arr,1) as table2

WHERE 