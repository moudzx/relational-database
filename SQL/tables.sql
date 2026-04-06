CREATE TABLE Club (
    club_id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    country VARCHAR2(50) NOT NULL,
    city VARCHAR2(50) NOT NULL,
    budget NUMBER(15,2),
    founded_year NUMBER(4)
);

CREATE TABLE Person (
    person_id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    nationality VARCHAR2(50),
    birth_date DATE,
    email VARCHAR2(100)
);

CREATE TABLE Sponsor (
    sponsor_id NUMBER PRIMARY KEY,
    company VARCHAR2(100) NOT NULL,
    product VARCHAR2(100),
    type VARCHAR2(50)
);

CREATE TABLE Stadium (
    stadium_id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    capacity NUMBER,
    location VARCHAR2(100),
    club_id NUMBER NOT NULL,
    CONSTRAINT fk_stadium_club FOREIGN KEY (club_id) REFERENCES Club(club_id)
);

CREATE TABLE Team (
    team_id NUMBER PRIMARY KEY,
    category VARCHAR2(50) NOT NULL,
    club_id NUMBER NOT NULL,
    CONSTRAINT fk_team_club FOREIGN KEY (club_id) REFERENCES Club(club_id)
);

CREATE TABLE President (
    president_id NUMBER PRIMARY KEY,
    person_id NUMBER NOT NULL,
    club_id NUMBER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    CONSTRAINT fk_president_person FOREIGN KEY (person_id) REFERENCES Person(person_id),
    CONSTRAINT fk_president_club FOREIGN KEY (club_id) REFERENCES Club(club_id)
);

CREATE TABLE Coach (
    coach_id NUMBER PRIMARY KEY,
    team_id NUMBER NOT NULL,
    person_id NUMBER NOT NULL,
    style_of_play VARCHAR2(50),
    season VARCHAR2(20) NOT NULL,
    CONSTRAINT fk_coach_team FOREIGN KEY (team_id) REFERENCES Team(team_id),
    CONSTRAINT fk_coach_person FOREIGN KEY (person_id) REFERENCES Person(person_id)
);

CREATE TABLE Player (
    player_id NUMBER PRIMARY KEY,
    person_id NUMBER NOT NULL,
    team_id NUMBER NOT NULL,
    jersey NUMBER,
    position VARCHAR2(30),
    season VARCHAR2(20) NOT NULL,
    CONSTRAINT fk_player_person FOREIGN KEY (person_id) REFERENCES Person(person_id),
    CONSTRAINT fk_player_team FOREIGN KEY (team_id) REFERENCES Team(team_id)
);

CREATE TABLE PlayerStats (
    stats_id NUMBER PRIMARY KEY,
    player_id NUMBER NOT NULL,
    season VARCHAR2(20) NOT NULL,
    goals NUMBER DEFAULT 0,
    assists NUMBER DEFAULT 0,
    yellow_cards NUMBER DEFAULT 0,
    red_cards NUMBER DEFAULT 0,
    minutes_played NUMBER DEFAULT 0,
    key_passes NUMBER DEFAULT 0,
    dribbles NUMBER DEFAULT 0,
    duals_won NUMBER DEFAULT 0,
    tackles NUMBER DEFAULT 0,
    saves NUMBER DEFAULT 0,
    CONSTRAINT fk_playerstats_player FOREIGN KEY (player_id) REFERENCES Player(player_id)
);

CREATE TABLE FootballMatch (
    match_id NUMBER PRIMARY KEY,
    match_date DATE NOT NULL,
    competition VARCHAR2(100) NOT NULL,
    home_team_id NUMBER NOT NULL,
    away_team_id NUMBER NOT NULL,
    stadium_id NUMBER NOT NULL,
    home_score NUMBER,
    away_score NUMBER,
    match_result VARCHAR2(10),
    season VARCHAR2(20) NOT NULL,
    CONSTRAINT fk_match_home_team FOREIGN KEY (home_team_id) REFERENCES Team(team_id),
    CONSTRAINT fk_match_away_team FOREIGN KEY (away_team_id) REFERENCES Team(team_id),
    CONSTRAINT fk_match_stadium FOREIGN KEY (stadium_id) REFERENCES Stadium(stadium_id),
    CONSTRAINT chk_match_teams CHECK (home_team_id != away_team_id)
);

CREATE TABLE MatchEvent (
    event_id NUMBER PRIMARY KEY,
    match_id NUMBER NOT NULL,
    player_id NUMBER NOT NULL,
    event_type VARCHAR2(50) NOT NULL,
    minute NUMBER NOT NULL,
    CONSTRAINT fk_matchevent_match FOREIGN KEY (match_id) REFERENCES FootballMatch(match_id),
    CONSTRAINT fk_matchevent_player FOREIGN KEY (player_id) REFERENCES Player(player_id)
);

CREATE TABLE Contract (
    contract_id NUMBER PRIMARY KEY,
    person_id NUMBER NOT NULL,
    person_type VARCHAR2(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    salary NUMBER(12,2),
    club_id NUMBER NOT NULL,
    CONSTRAINT fk_contract_person FOREIGN KEY (person_id) REFERENCES Person(person_id),
    CONSTRAINT fk_contract_club FOREIGN KEY (club_id) REFERENCES Club(club_id),
    CONSTRAINT chk_contract_dates CHECK (end_date > start_date)
);

CREATE TABLE ClubSponsor (
    sponsor_id NUMBER,
    club_id NUMBER,
    CONSTRAINT pk_clubsponsor PRIMARY KEY (sponsor_id, club_id),
    CONSTRAINT fk_clubsponsor_sponsor FOREIGN KEY (sponsor_id) REFERENCES Sponsor(sponsor_id),
    CONSTRAINT fk_clubsponsor_club FOREIGN KEY (club_id) REFERENCES Club(club_id)
);

CREATE TABLE PlayerSponsor (
    sponsor_id NUMBER,
    player_id NUMBER,
    CONSTRAINT pk_playersponsor PRIMARY KEY (sponsor_id, player_id),
    CONSTRAINT fk_playersponsor_sponsor FOREIGN KEY (sponsor_id) REFERENCES Sponsor(sponsor_id),
    CONSTRAINT fk_playersponsor_player FOREIGN KEY (player_id) REFERENCES Player(player_id)
);