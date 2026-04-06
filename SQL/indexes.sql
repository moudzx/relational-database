
--  CLUB MANAGER ROLE

CREATE INDEX idx_club_country_city ON Club(country, city);
CREATE INDEX idx_club_budget ON Club(budget);

CREATE INDEX idx_team_club_id ON Team(club_id);

CREATE INDEX idx_player_team_season ON Player(team_id, season);
CREATE INDEX idx_player_position ON Player(position);
CREATE INDEX idx_player_jersey_team ON Player(team_id, jersey, season);

CREATE INDEX idx_contract_club_person ON Contract(club_id, person_id);
CREATE INDEX idx_contract_dates ON Contract(start_date, end_date);
CREATE INDEX idx_contract_salary ON Contract(salary);

CREATE INDEX idx_stadium_club_id ON Stadium(club_id);

CREATE INDEX idx_president_club_dates ON President(club_id, start_date, end_date);

CREATE INDEX idx_coach_team_season ON Coach(team_id, season);

CREATE INDEX idx_clubsponsor_club_id ON ClubSponsor(club_id);


--  MATCH ANALYST ROLE 



CREATE INDEX idx_match_season_competition ON FootballMatch(season, competition);
CREATE INDEX idx_match_date ON FootballMatch(match_date);
CREATE INDEX idx_match_teams ON FootballMatch(home_team_id, away_team_id, match_date);
CREATE INDEX idx_match_result ON FootballMatch(match_result);
CREATE INDEX idx_match_home_away ON FootballMatch(home_team_id, away_team_id);


CREATE INDEX idx_matchevent_match_minute ON MatchEvent(match_id, minute);
CREATE INDEX idx_matchevent_player_match ON MatchEvent(player_id, match_id);
CREATE INDEX idx_matchevent_type ON MatchEvent(event_type);

CREATE INDEX idx_playerstats_player_season ON PlayerStats(player_id, season);
CREATE INDEX idx_playerstats_goals_assists ON PlayerStats(goals, assists);
CREATE INDEX idx_playerstats_performance ON PlayerStats(goals, assists, minutes_played);

CREATE INDEX idx_player_team_season ON Player(team_id, season);


--  AGENT ROLE

CREATE INDEX idx_person_name ON Person(name);
CREATE INDEX idx_person_nationality ON Person(nationality);
CREATE INDEX idx_person_birth_date ON Person(birth_date);

CREATE INDEX idx_player_person_id ON Player(person_id);
CREATE INDEX idx_player_team_season ON Player(team_id, season);

CREATE INDEX idx_contract_person_dates ON Contract(person_id, start_date, end_date);
CREATE INDEX idx_contract_salary ON Contract(salary);

CREATE INDEX idx_playersponsor_player_id ON PlayerSponsor(player_id);

CREATE INDEX idx_sponsor_company ON Sponsor(company);
