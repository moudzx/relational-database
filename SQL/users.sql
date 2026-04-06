CREATE PROFILE user_profile LIMIT FAILED_LOGIN_ATTEMPTS 3;

CREATE ROLE club_manager;
CREATE ROLE player_agent;
CREATE ROLE match_analyst;

CREATE USER c##manager_user IDENTIFIED BY Manager123;
CREATE USER c##agent_user IDENTIFIED BY Agent123;
CREATE USER c##analyst_user IDENTIFIED BY Analyst123;

GRANT club_manager TO c##manager_user;
GRANT player_agent TO c##agent_user;
GRANT match_analyst TO c##analyst_user;

GRANT CREATE SESSION TO c##manager_user;
GRANT CREATE SESSION TO c##agent_user;
GRANT CREATE SESSION TO c##analyst_user;

GRANT SELECT, INSERT, UPDATE ON Club TO club_manager;
GRANT SELECT, INSERT, UPDATE ON Stadium TO club_manager;
GRANT SELECT, INSERT, UPDATE ON Team TO club_manager;
GRANT SELECT ON Person TO club_manager;
GRANT SELECT ON Player TO club_manager;

GRANT SELECT ON Club TO player_agent;
GRANT SELECT ON Team TO player_agent;
GRANT SELECT, INSERT, UPDATE ON Person TO player_agent;
GRANT SELECT, INSERT, UPDATE ON Player TO player_agent;
GRANT SELECT, INSERT, UPDATE ON Contract TO player_agent;

GRANT SELECT ON Club TO match_analyst;
GRANT SELECT ON Team TO match_analyst;
GRANT SELECT ON Player TO match_analyst;
GRANT SELECT, INSERT, UPDATE ON FootballMatch TO match_analyst;
GRANT SELECT, INSERT, UPDATE ON MatchEvent TO match_analyst;
GRANT SELECT, INSERT, UPDATE ON PlayerStats TO match_analyst;