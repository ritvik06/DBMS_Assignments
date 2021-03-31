--1--

SELECT inter.match_id, player.player_name, team.team_name, COUNT(*) as num_wickets
FROM (SELECT wicket_taken.match_id, ball_by_ball.team_bowling, ball_by_ball.bowler    
FROM wicket_taken
INNER JOIN ball_by_ball
ON (wicket_taken.match_id = ball_by_ball.match_id 
AND wicket_taken.over_id = ball_by_ball.over_id 
AND wicket_taken.ball_id = ball_by_ball.ball_id
AND wicket_taken.innings_no = ball_by_ball.innings_no
AND wicket_taken.kind_out NOT IN(3, 5, 9)
AND ball_by_ball.innings_no IN (1,2)
)) as inter, team, player
WHERE inter.team_bowling = team.team_id
AND player.player_id = inter.bowler
GROUP BY inter.match_id, player.player_name, team.team_name
HAVING COUNT(*) >= 5
ORDER BY
num_wickets DESC,
player.player_name ASC,
team.team_name ASC;

--2--

SELECT player.player_name as Player_name, COUNT(*) as num_matches
FROM (SELECT match.match_id, match.man_of_the_match
FROM match 
INNER JOIN player_match
ON(
    match.match_id = player_match.match_id
AND match.man_of_the_match = player_match.player_id
AND player_match.team_id != match.match_winner
)) as inter, player
WHERE inter.man_of_the_match = player.player_id
GROUP BY player.player_name
ORDER BY
num_matches DESC,
player.player_name ASC
LIMIT 3;

--3--

SELECT player.player_name
FROM (SELECT wicket_taken.match_id, wicket_taken.fielders
FROM wicket_taken
INNER JOIN player
ON (player.player_id = wicket_taken.fielders
AND wicket_taken.kind_out IN (1)
)) as inter, player, match, season
WHERE inter.fielders = player.player_id
AND inter.match_id = match.match_id
AND match.season_id = season.season_id
AND season_year = 2012
GROUP BY player.player_name
ORDER BY 
COUNT(*) DESC,
player.player_name ASC
LIMIT 1;

--4--

SELECT season.season_year, player.player_name, inter1.num_matches 
FROM (SELECT inter.player_id, inter.season_id, COUNT(*) as num_matches
FROM (SELECT player_match.player_id, match.season_id, match.match_id
FROM match 
INNER JOIN player_match 
ON match.match_id = player_match.match_id
) as inter
GROUP BY inter.player_id, inter.season_id
ORDER BY
COUNT(*) DESC) as inter1, season, player
WHERE inter1.season_id = season.season_id
AND season.purple_cap = inter1.player_id
AND player.player_id = inter1.player_id
ORDER BY season.season_year ASC;

--5--

SELECT player.player_name
FROM (SELECT inter.striker as player_id, inter.match_id, inter.team_batting, SUM(inter.runs_scored) as player_score
FROM (SELECT ball_by_ball.striker, ball_by_ball.match_id, ball_by_ball.team_batting, batsman_scored.runs_scored
FROM ball_by_ball 
INNER JOIN batsman_scored
ON batsman_scored.match_id = ball_by_ball.match_id
AND batsman_scored.innings_no = ball_by_ball.innings_no
AND batsman_scored.over_id = ball_by_ball.over_id
AND batsman_scored.ball_id = ball_by_ball.ball_id
AND ball_by_ball.innings_no IN (1,2)
) as inter
GROUP BY inter.striker, inter.match_id, inter.team_batting) as inter1, match, player
WHERE player.player_id = inter1.player_id
AND match.match_id = inter1.match_id
AND inter1.team_batting != match.match_winner
AND inter1.player_score > 50
GROUP BY player.player_name
ORDER BY player.player_name ASC;

--6--

SELECT season_year, team_name, team_rank as rank FROM
(SELECT season_year, team_name, row_number()
OVER (PARTITION BY season_year ORDER BY num_left DESC, team_name ASC) as team_rank
FROM 
(SELECT inter2.team_name, inter2.season_year, COUNT(*) as num_left
FROM (SELECT inter1.player_id, inter1.team_name, inter1.season_year
FROM (SELECT inter.player_id, team.team_name, season.season_year
FROM (SELECT player.player_id, player_match.team_id, player_match.match_id
FROM player
INNER JOIN player_match 
ON  player.player_id = player_match.player_id
AND player.batting_hand = 1
AND player.country_id > 1) as inter, season, team, match
WHERE inter.team_id = team.team_id
AND inter.match_id = match.match_id
AND match.season_id = season.season_id
ORDER BY season.season_year,
team.team_name) as inter1
GROUP BY inter1.player_id, inter1.team_name, inter1.season_year
ORDER BY inter1.season_year,
inter1.team_name) as inter2

GROUP BY inter2.team_name, inter2.season_year
ORDER BY inter2.season_year ASC,
COUNT(*) DESC,
inter2.team_name ASC) as inter3) ranks
WHERE team_rank <=5
ORDER BY season_year;

--7--

SELECT team.team_name
FROM match, season, team
WHERE match.match_winner = team.team_id
AND season.season_year = 2009
AND match.season_id = season.season_id
GROUP BY team.team_name
ORDER BY COUNT(*) DESC,
team.team_name ASC;

--8--

SELECT team_name, player_name, player_score as runs FROM
(SELECT team_name, player_name, player_score, row_number()
OVER (PARTITION BY team_name ORDER BY player_score DESC) as player_rank
FROM (SELECT team.team_name, player.player_name, inter1.player_score
FROM (SELECT inter.striker as player_id, inter.team_batting as team_id, SUM(inter.runs_scored) as player_score
FROM (SELECT ball_by_ball.striker, ball_by_ball.match_id, ball_by_ball.team_batting, batsman_scored.runs_scored
FROM ball_by_ball 
INNER JOIN batsman_scored
ON batsman_scored.match_id = ball_by_ball.match_id
AND batsman_scored.innings_no = ball_by_ball.innings_no
AND batsman_scored.over_id = ball_by_ball.over_id
AND batsman_scored.ball_id = ball_by_ball.ball_id
AND ball_by_ball.innings_no IN (1,2)
) as inter, match, season
WHERE inter.match_id = match.match_id
AND match.season_id = season.season_id
AND season.season_year = 2010
GROUP BY inter.striker, inter.team_batting
ORDER BY inter.team_batting DESC) as inter1, player, team
WHERE player.player_id = inter1.player_id
AND team.team_id = inter1.team_id
ORDER BY team.team_name ASC) as t1) ranks
WHERE player_rank <=1;

--9--

SELECT team_batting as team_name, team_bowling as opponent_team_name, num_sixes_match as number_of_sixes
FROM (SELECT inter.match_id, team.team_name as team_batting, team2.team_name as team_bowling, COUNT(*) as num_sixes_match
FROM (SELECT ball_by_ball.match_id, ball_by_ball.team_batting, ball_by_ball.team_bowling
FROM ball_by_ball 
INNER JOIN batsman_scored
ON batsman_scored.match_id = ball_by_ball.match_id
AND batsman_scored.innings_no = ball_by_ball.innings_no
AND batsman_scored.over_id = ball_by_ball.over_id
AND batsman_scored.ball_id = ball_by_ball.ball_id
AND batsman_scored.runs_scored = 6
AND ball_by_ball.innings_no IN (1,2)
) as inter, season, match, team, team as team2
WHERE match.match_id = inter.match_id
AND season.season_id = match.season_id
AND season.season_year = 2008
AND team.team_id = inter.team_batting
AND team2.team_id = inter.team_bowling
GROUP BY inter.match_id, team.team_name, team2.team_name
ORDER BY COUNT(*) DESC,
team.team_name
LIMIT 3) as inter1
ORDER BY num_sixes_match DESC, 
team_batting ASC;

--10--

--11--

SELECT player_scores.season_year, player_scores.player_name, bowler_wickets.num_wickets, player_scores.player_season_score as runs
FROM 
(SELECT player.player_name, season.season_year, SUM(inter1.player_score) as player_season_score
    FROM (SELECT inter.striker as player_id, inter.match_id, SUM(inter.runs_scored) as player_score
    FROM (SELECT ball_by_ball.striker, ball_by_ball.match_id, ball_by_ball.team_batting, batsman_scored.runs_scored

    FROM ball_by_ball 
    INNER JOIN batsman_scored
    ON batsman_scored.match_id = ball_by_ball.match_id
    AND batsman_scored.innings_no = ball_by_ball.innings_no
    AND batsman_scored.over_id = ball_by_ball.over_id
    AND batsman_scored.ball_id = ball_by_ball.ball_id
    AND ball_by_ball.innings_no IN (1,2)
    ) as inter
    GROUP BY inter.striker, inter.match_id) as inter1, match, player, season
    WHERE player.player_id = inter1.player_id
    AND match.match_id = inter1.match_id
    AND season.season_id = match.season_id
    AND player.batting_hand = 1 
    GROUP BY player.player_name, season.season_year
    HAVING SUM(inter1.player_score) > 150  
    ORDER BY player.player_name ASC,
    season.season_year ASC) as player_scores,

(SELECT player.player_name, season.season_year, COUNT(*) as num_wickets
FROM (SELECT wicket_taken.match_id, ball_by_ball.bowler    
FROM wicket_taken
INNER JOIN ball_by_ball
ON (wicket_taken.match_id = ball_by_ball.match_id 
AND wicket_taken.over_id = ball_by_ball.over_id 
AND wicket_taken.ball_id = ball_by_ball.ball_id
AND wicket_taken.innings_no = ball_by_ball.innings_no
AND wicket_taken.kind_out NOT IN(3, 5, 9)
AND ball_by_ball.innings_no IN (1,2)
)) as wt_inter, player, match, season
WHERE player.player_id = wt_inter.bowler 
AND wt_inter.match_id = match.match_id
AND match.season_id = season.season_id
GROUP BY player.player_name, season.season_year
HAVING COUNT(*) >=5
ORDER BY player.player_name ASC,
season.season_year ASC) as bowler_wickets,

(SELECT player.player_name, season.season_year, COUNT(*) as num_matches
FROM player_match, match, season, player
WHERE player.player_id = player_match.player_id
AND player.batting_hand = 1
AND player_match.match_id = match.match_id
AND season.season_id = match.season_id
GROUP BY player.player_name, season.season_year
HAVING COUNT(*) >= 10
ORDER BY player.player_name ASC,
season.season_year ASC) as player_matches

WHERE (player_scores.player_name = bowler_wickets.player_name AND bowler_wickets.player_name = player_matches.player_name)
AND (player_scores.season_year = bowler_wickets.season_year AND bowler_wickets.season_year= player_matches.season_year)

ORDER BY bowler_wickets.num_wickets DESC,
         player_scores.player_season_score DESC,
         player_scores.player_name ASC;

--12--

SELECT match.match_id, player.player_name, team.team_name, num_wickets, season.season_year
FROM (SELECT wicket_taken.match_id, ball_by_ball.bowler, COUNT(*) as num_wickets   
FROM wicket_taken
INNER JOIN ball_by_ball
ON (wicket_taken.match_id = ball_by_ball.match_id 
AND wicket_taken.over_id = ball_by_ball.over_id 
AND wicket_taken.ball_id = ball_by_ball.ball_id
AND wicket_taken.innings_no = ball_by_ball.innings_no
AND wicket_taken.kind_out NOT IN(3, 5, 9)
AND ball_by_ball.innings_no IN (1,2)
)
GROUP BY wicket_taken.match_id, ball_by_ball.bowler
) as wt_inter, player, match, season, team, player_match


WHERE player.player_id = wt_inter.bowler 
AND wt_inter.match_id = match.match_id
AND match.season_id = season.season_id
AND match.match_id = player_match.match_id
AND player_match.player_id = player.player_id
AND team.team_id = player_match.team_id
ORDER BY wt_inter.num_wickets DESC,
player.player_name ASC,
season.season_year ASC
LIMIT 1;

--13--

SELECT inter.player_name
FROM (SELECT player.player_name, season.season_year, COUNT(*) as num_matches
FROM player_match, match, season, player
WHERE player.player_id = player_match.player_id
AND player_match.match_id = match.match_id
AND season.season_id = match.season_id
GROUP BY player.player_name, season.season_year
ORDER BY player.player_name ASC,
season.season_year ASC) as inter
GROUP BY inter.player_name
HAVING COUNT(*) = 9
ORDER BY inter.player_name ASC;

--14--

SELECT season_year, match_id, team_name FROM
(SELECT season_year, match_id, team_name, num_fifties, row_number()
OVER (PARTITION BY season_year ORDER BY num_fifties DESC) as fifties_rank
FROM (SELECT inter2.season_year, inter2.match_id, inter2.team_name, COUNT(*) as num_fifties
FROM (SELECT player.player_name, inter1.match_id, team.team_name, season.season_year,  SUM(inter1.player_score) as player_season_score
    FROM (SELECT inter.striker as player_id, inter.match_id, inter.team_batting, SUM(inter.runs_scored) as player_score
    FROM (SELECT ball_by_ball.striker, ball_by_ball.match_id, ball_by_ball.team_batting, batsman_scored.runs_scored

    FROM ball_by_ball 
    INNER JOIN batsman_scored
    ON batsman_scored.match_id = ball_by_ball.match_id
    AND batsman_scored.innings_no = ball_by_ball.innings_no
    AND batsman_scored.over_id = ball_by_ball.over_id
    AND batsman_scored.ball_id = ball_by_ball.ball_id
    AND ball_by_ball.innings_no IN (1,2)
    ) as inter
    GROUP BY inter.striker, inter.match_id, inter.team_batting
    HAVING SUM(inter.runs_scored) >= 50) as inter1, match, player, season, team
    WHERE player.player_id = inter1.player_id
    AND match.match_id = inter1.match_id
    AND season.season_id = match.season_id
    AND team.team_id = inter1.team_batting
    AND team.team_id = match.match_winner
    GROUP BY player.player_name, inter1.match_id, team.team_name, season.season_year
    ORDER BY inter1.match_id ASC,
    player.player_name ASC,
    season.season_year ASC) as inter2
    GROUP BY inter2.season_year, inter2.match_id, inter2.team_name
    ORDER BY inter2.season_year ASC,
    COUNT(*) DESC,
    inter2.team_name ASC) as inter3) ranks
    WHERE fifties_rank<=3
    ORDER BY season_year ASC,
    num_fifties DESC,
    team_name ASC,
    match_id;

--15--

--16--

SELECT inter.team_name
FROM (SELECT team2.team_name, match.match_id, season.season_year
FROM match, team as team1,team as team2, season
WHERE team1.team_name = 'Royal Challengers Bangalore'
AND season.season_year = 2008 
AND match.season_id = season.season_id
AND match.match_winner = team2.team_id
AND team2.team_id != team1.team_id
AND (match.team_1 = team1.team_id OR match.team_2 = team1.team_id)
ORDER BY match.match_id) as inter
GROUP BY inter.team_name
ORDER BY COUNT(*) DESC,
inter.team_name ASC;

--17--

SELECT team_name, player_name, num_moftm as count FROM
(SELECT team_name, player_name, num_moftm, row_number()
OVER (PARTITION BY team_name ORDER BY num_moftm DESC, player_name ASC) as man_rank
FROM (SELECT inter.team_name, inter.player_name, COUNT(*) as num_moftm
FROM (
SELECT match.match_id, team.team_name, player.player_name 
FROM team, player, player_match, match
WHERE player.player_id = match.man_of_the_match
AND player.player_id = player_match.player_id
AND player_match.match_id = match.match_id
AND team.team_id = player_match.team_id
) as inter
GROUP BY inter.team_name, inter.player_name
ORDER BY inter.team_name ASC,
player_name ASC) as inter1) ranks
WHERE man_rank <=1
ORDER BY team_name ASC,
        man_rank DESC;

--18--

--19--

SELECT inter2.team_name, CAST(AVG(inter2.teamscore_every_match) AS DECIMAL(10,2)) as avg_runs
FROM (SELECT inter1.team_name, inter1.match_id, SUM(inter1.player_score) as teamscore_every_match
FROM (SELECT player.player_name, team.team_name, inter.match_id, SUM(inter.runs_scored) as player_score
FROM (SELECT ball_by_ball.striker, ball_by_ball.match_id, ball_by_ball.team_batting, batsman_scored.runs_scored
FROM ball_by_ball 
INNER JOIN batsman_scored
ON batsman_scored.match_id = ball_by_ball.match_id
AND batsman_scored.innings_no = ball_by_ball.innings_no
AND batsman_scored.over_id = ball_by_ball.over_id
AND batsman_scored.ball_id = ball_by_ball.ball_id
AND ball_by_ball.innings_no IN (1,2)
) as inter, player, team, season, match
WHERE inter.team_batting = team.team_id
AND player.player_id = inter.striker
AND inter.match_id = match.match_id
AND season.season_year = 2010
AND match.season_id = season.season_id
GROUP BY player.player_name, team.team_name, inter.match_id
ORDER BY team.team_name ASC) as inter1

GROUP BY inter1.team_name, inter1.match_id
ORDER BY inter1.team_name ASC) as inter2

GROUP BY inter2.team_name
ORDER BY inter2.team_name ASC;

--20--

SELECT player.player_name
FROM wicket_taken, player
WHERE player.player_id = wicket_taken.player_out
AND wicket_taken.over_id = 1
GROUP BY player.player_name
ORDER BY COUNT(*) DESC,
player.player_name ASC
LIMIT 10;

--21--

SELECT  inter1.match_id as Match_id, team_1.team_name as team_1_name, team_2.team_name as team_2_name, team_winner.team_name as match_winner_name, num_boundaries as number_of_boundaries
FROM 
(SELECT match.match_id, match.match_winner, match.team_1, match.team_2, COUNT(*) as num_boundaries
FROM (SELECT ball_by_ball.match_id, ball_by_ball.team_batting, ball_by_ball.team_bowling
FROM ball_by_ball 
INNER JOIN batsman_scored
ON batsman_scored.match_id = ball_by_ball.match_id
AND batsman_scored.innings_no = ball_by_ball.innings_no
AND batsman_scored.over_id = ball_by_ball.over_id
AND batsman_scored.ball_id = ball_by_ball.ball_id
AND batsman_scored.runs_scored IN (4,6)
AND ball_by_ball.innings_no = 2
ORDER BY ball_by_ball.match_id) as inter, match, team as team1, team as team2, season
WHERE match.match_id = inter.match_id
AND team1.team_id = match.match_winner
AND team1.team_id = inter.team_batting
AND team2.team_id = inter.team_bowling 
AND season.season_id = match.season_id
GROUP BY match.match_id, match.match_winner, match.team_1, match.team_2,season.season_year
ORDER BY num_boundaries ASC
) as inter1, team as team_1, team as team_2, team as team_winner

WHERE team_1.team_id = inter1.team_1
AND team_2.team_id = inter1.team_2
AND team_winner.team_id = inter1.match_winner

ORDER BY num_boundaries ASC,
team_winner.team_name ASC

LIMIT 3;

--22--
