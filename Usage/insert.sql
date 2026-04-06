-------------------------------------------------------
-- INSERT INTO CLUB
-------------------------------------------------------
INSERT INTO Club (club_id, name, country, city, budget, founded_year) VALUES 
(1, 'Real Madrid', 'Spain', 'Madrid', 800000000, 1902),
(2, 'Barcelona', 'Spain', 'Barcelona', 750000000, 1899);

-------------------------------------------------------
-- INSERT INTO STADIUM
-------------------------------------------------------
INSERT INTO Stadium (stadium_id, name, capacity, location, club_id) VALUES
(1, 'Santiago Bernabeu', 81000, 'Madrid', 1),
(2, 'Camp Nou', 99000, 'Barcelona', 2);

-------------------------------------------------------
-- INSERT INTO PERSON
-------------------------------------------------------
INSERT INTO Person (person_id, name, nationality, birth_date, email) VALUES
(1, 'Florentino Perez', 'Spanish', DATE '1947-03-08', 'fperez@realmadrid.com'),
(2, 'Joan Laporta', 'Spanish', DATE '1962-06-29', 'jlaporta@fcbarcelona.com'),
(3, 'Carlo Ancelotti', 'Italian', DATE '1959-06-10', 'ancelotti@realmadrid.com'),
(4, 'Xavi Hernandez', 'Spanish', DATE '1980-01-25', 'xavi@fcbarcelona.com'),
(5, 'Vinicius Jr', 'Brazilian', DATE '2000-07-12', 'vjr@realmadrid.com'),
(6, 'Lewandowski', 'Polish', DATE '1988-08-21', 'lewa@barcelona.com');

-------------------------------------------------------
-- INSERT INTO PRESIDENT
-------------------------------------------------------
INSERT INTO President (president_id, person_id, club_id, start_date, end_date) VALUES
(1, 1, 1, DATE '2009-01-01', NULL),
(2, 2, 2, DATE '2021-03-01', NULL);

-------------------------------------------------------
-- INSERT INTO TEAM
-------------------------------------------------------
INSERT INTO Team (team_id, category, club_id) VALUES
(1, 'First Team', 1),
(2, 'First Team', 2);

-- INSERT INTO COACH
INSERT INTO Coach (coach_id, team_id, person_id, style_of_play, season) VALUES
(1, 1, 3, 'Possession', '2024/2025'),
(2, 2, 4, 'Tiki-Taka', '2024/2025');

-- INSERT INTO PLAYER
INSERT INTO Player (player_id, person_id, team_id, jersey, position, season) VALUES
(1, 5, 1, 7, 'LW', '2024/2025'),
(2, 6, 2, 9, 'ST', '2024/2025');

-- INSERT INTO PLAYER STATS
INSERT INTO PlayerStats (stats_id, player_id, season, goals, assists, yellow_cards, red_cards, minutes_played, key_passes, dribbles, duals_won, tackles, saves) VALUES
(1, 1, '2024/2025', 12, 7, 3, 0, 1800, 35, 60, 40, 10, 0),
(2, 2, '2024/2025', 20, 4, 2, 0, 1900, 25, 30, 50, 5, 0);

-- INSERT INTO FOOTBALL MATCH
INSERT INTO FootballMatch (match_id, match_date, competition, home_team_id, away_team_id, stadium_id, home_score, away_score, match_result, season) VALUES
(1, DATE '2024-10-20', 'La Liga', 1, 2, 1, 2, 1, 'HOME', '2024/2025');

-- INSERT INTO MATCH EVENT
INSERT INTO MatchEvent (event_id, match_id, player_id, event_type, minute) VALUES
(1, 1, 1, 'Goal', 23),
(2, 1, 2, 'Goal', 67),
(3, 1, 1, 'Assist', 23);

-- INSERT INTO SPONSOR
INSERT INTO Sponsor (sponsor_id, company, product, type) VALUES
(1, 'Adidas', 'Sportswear', 'Kit'),
(2, 'Spotify', 'Streaming', 'Main'),
(3, 'Emirates', 'Airline', 'Main');

-- INSERT INTO CLUB SPONSOR
INSERT INTO ClubSponsor (sponsor_id, club_id) VALUES
(1, 1),
(3, 1),
(2, 2);

-- INSERT INTO PLAYER SPONSOR
INSERT INTO PlayerSponsor (sponsor_id, player_id) VALUES
(1, 1),
(2, 2);

-- INSERT INTO CONTRACT
INSERT INTO Contract (contract_id, person_id, person_type, start_date, end_date, salary, club_id) VALUES
(1, 5, 'PLAYER', DATE '2024-07-01', DATE '2027-06-30', 8000000, 1),
(2, 6, 'PLAYER', DATE '2023-07-01', DATE '2026-06-30', 10000000, 2),
(3, 3, 'COACH', DATE '2024-07-01', DATE '2026-06-30', 12000000, 1),
(4, 4, 'COACH', DATE '2024-07-01', DATE '2026-06-30', 9000000, 2);
