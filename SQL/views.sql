CREATE OR REPLACE VIEW club_manager_view AS
SELECT 
    c.club_id,
    c.name,
    c.country,
    c.city,
    c.founded_year,
    s.name AS stadium_name,
    s.capacity,
    s.location,
    t.category,
    p.name AS president_name
FROM Club c
JOIN Stadium s ON c.club_id = s.club_id
JOIN Team t ON c.club_id = t.club_id
JOIN President pr ON c.club_id = pr.club_id
JOIN Person p ON pr.person_id = p.person_id
WHERE pr.end_date IS NULL;

CREATE OR REPLACE VIEW player_agent_view AS
SELECT 
    pl.player_id,
    p.name AS player_name,
    p.nationality,
    p.birth_date,
    t.category AS team_category,
    c.name AS club_name,
    pl.jersey,
    pl.position,
    pl.season,
    con.salary,
    con.start_date,
    con.end_date
FROM Player pl
JOIN Person p ON pl.person_id = p.person_id
JOIN Team t ON pl.team_id = t.team_id
JOIN Club c ON t.club_id = c.club_id
LEFT JOIN Contract con ON p.person_id = con.person_id AND con.person_type = 'PLAYER';

CREATE OR REPLACE VIEW match_analyst_view AS
SELECT 
    m.match_id,
    m.match_date,
    m.competition,
    ht.category AS home_team,
    at.category AS away_team,
    s.name AS stadium,
    m.home_score,
    m.away_score,
    m.match_result,
    p.name AS player_name,
    ps.goals,
    ps.assists,
    ps.yellow_cards,
    ps.red_cards,
    ps.minutes_played
FROM FootballMatch m
JOIN Team ht ON m.home_team_id = ht.team_id
JOIN Team at ON m.away_team_id = at.team_id
JOIN Stadium s ON m.stadium_id = s.stadium_id
LEFT JOIN Player pl ON (pl.team_id = ht.team_id OR pl.team_id = at.team_id)
LEFT JOIN Person p ON pl.person_id = p.person_id
LEFT JOIN PlayerStats ps ON pl.player_id = ps.player_id AND ps.season = m.season;

GRANT SELECT ON club_manager_view TO club_manager;
GRANT SELECT ON player_agent_view TO player_agent;
GRANT SELECT ON match_analyst_view TO match_analyst;