CREATE OR REPLACE PACKAGE match_analyst_pkg AS
    -- User-defined exceptions
    invalid_match_id EXCEPTION;
    invalid_team_id EXCEPTION;
    no_match_data_found EXCEPTION;
    
    PROCEDURE get_match_stats(p_match_id IN NUMBER);
    PROCEDURE analyze_team_performance(
        p_team_id IN NUMBER,
        p_season IN VARCHAR2);
    PROCEDURE get_match_timeline(p_match_id IN NUMBER);
END match_analyst_pkg;
/

CREATE OR REPLACE PACKAGE BODY match_analyst_pkg AS
    
    PROCEDURE get_match_stats(p_match_id IN NUMBER) IS
        CURSOR match_cursor IS
            SELECT m.match_date, m.competition,
                   ht.category AS home_team,
                   at.category AS away_team,
                   m.home_score, m.away_score,
                   s.name AS stadium
            FROM FootballMatch m
            JOIN Team ht ON m.home_team_id = ht.team_id
            JOIN Team at ON m.away_team_id = at.team_id
            JOIN Stadium s ON m.stadium_id = s.stadium_id
            WHERE m.match_id = p_match_id;
            
        v_match match_cursor%ROWTYPE;
        v_match_exists NUMBER;
    BEGIN
        -- Validate match ID exists
        SELECT COUNT(*) INTO v_match_exists
        FROM FootballMatch
        WHERE match_id = p_match_id;
        
        IF v_match_exists = 0 THEN
            RAISE invalid_match_id;
        END IF;
        
        OPEN match_cursor;
        FETCH match_cursor INTO v_match;
        
        IF match_cursor%FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Match: ' || v_match.home_team || ' vs ' || v_match.away_team);
            DBMS_OUTPUT.PUT_LINE('Date: ' || TO_CHAR(v_match.match_date, 'DD-MON-YYYY'));
            DBMS_OUTPUT.PUT_LINE('Competition: ' || v_match.competition);
            DBMS_OUTPUT.PUT_LINE('Result: ' || v_match.home_score || ' - ' || v_match.away_score);
            DBMS_OUTPUT.PUT_LINE('Stadium: ' || v_match.stadium);
        END IF;
        
        CLOSE match_cursor;
        
    EXCEPTION
        WHEN invalid_match_id THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Invalid match ID - Match ' || p_match_id || ' does not exist.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error getting match stats: ' || SQLERRM);
    END get_match_stats;
    

    PROCEDURE analyze_team_performance(
        p_team_id IN NUMBER,
        p_season IN VARCHAR2
    ) IS
        CURSOR performance_cursor IS
            SELECT 
                COUNT(*) AS total_matches,
                SUM(CASE WHEN home_team_id = p_team_id AND match_result = 'W' THEN 1
                         WHEN away_team_id = p_team_id AND match_result = 'L' THEN 1
                         ELSE 0 END) AS wins,
                SUM(CASE WHEN match_result = 'D' THEN 1 ELSE 0 END) AS draws,
                SUM(CASE WHEN home_team_id = p_team_id AND match_result = 'L' THEN 1
                         WHEN away_team_id = p_team_id AND match_result = 'W' THEN 1
                         ELSE 0 END) AS losses,
                SUM(CASE WHEN home_team_id = p_team_id THEN home_score ELSE away_score END) AS goals_for,
                SUM(CASE WHEN home_team_id = p_team_id THEN away_score ELSE home_score END) AS goals_against
            FROM FootballMatch
            WHERE (home_team_id = p_team_id OR away_team_id = p_team_id)
                AND season = p_season;
            
        v_stats performance_cursor%ROWTYPE;
        v_team_exists NUMBER;
        v_season_exists NUMBER;
    BEGIN
        -- Validate team ID exists
        SELECT COUNT(*) INTO v_team_exists
        FROM Team
        WHERE team_id = p_team_id;
        
        IF v_team_exists = 0 THEN
            RAISE invalid_team_id;
        END IF;
        
        -- Validate season exists in matches
        SELECT COUNT(*) INTO v_season_exists
        FROM FootballMatch
        WHERE season = p_season
        AND ROWNUM = 1;
        
        IF v_season_exists = 0 THEN
            DBMS_OUTPUT.PUT_LINE('WARNING: No matches found for season ' || p_season);
        END IF;
        
        OPEN performance_cursor;
        FETCH performance_cursor INTO v_stats;
        
        IF v_stats.total_matches > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Team Performance Analysis - Season ' || p_season);
            DBMS_OUTPUT.PUT_LINE('===========================================');
            DBMS_OUTPUT.PUT_LINE('Total Matches: ' || v_stats.total_matches);
            DBMS_OUTPUT.PUT_LINE('Wins: ' || v_stats.wins);
            DBMS_OUTPUT.PUT_LINE('Draws: ' || v_stats.draws);
            DBMS_OUTPUT.PUT_LINE('Losses: ' || v_stats.losses);
            DBMS_OUTPUT.PUT_LINE('Goals For: ' || v_stats.goals_for);
            DBMS_OUTPUT.PUT_LINE('Goals Against: ' || v_stats.goals_against);
            DBMS_OUTPUT.PUT_LINE('Goal Difference: ' || (v_stats.goals_for - v_stats.goals_against));
            
            -- Calculate win percentage
            IF v_stats.total_matches > 0 THEN
                DBMS_OUTPUT.PUT_LINE('Win Rate: ' || 
                    ROUND((v_stats.wins / v_stats.total_matches) * 100, 1) || '%');
            END IF;
        ELSE
            RAISE no_match_data_found;
        END IF;
        
        CLOSE performance_cursor;
        
    EXCEPTION
        WHEN invalid_team_id THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Invalid team ID - Team ' || p_team_id || ' does not exist.');
        WHEN no_match_data_found THEN
            DBMS_OUTPUT.PUT_LINE('No matches found for team ' || p_team_id || ' in season ' || p_season);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error analyzing team performance: ' || SQLERRM);
    END analyze_team_performance;
    
    PROCEDURE get_match_timeline(p_match_id IN NUMBER) IS
        CURSOR timeline_cursor IS
            SELECT me.minute, me.event_type,
                   p.name AS player_name,
                   pl.jersey
            FROM MatchEvent me
            JOIN Player pl ON me.player_id = pl.player_id
            JOIN Person p ON pl.person_id = p.person_id
            WHERE me.match_id = p_match_id
            ORDER BY me.minute;
            
        v_events_count NUMBER := 0;
        v_match_exists NUMBER;
    BEGIN
        -- Validate match ID exists
        SELECT COUNT(*) INTO v_match_exists
        FROM FootballMatch
        WHERE match_id = p_match_id;
        
        IF v_match_exists = 0 THEN
            RAISE invalid_match_id;
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Match Timeline');
        DBMS_OUTPUT.PUT_LINE('--------------');
        
        FOR rec IN timeline_cursor LOOP
            v_events_count := v_events_count + 1;
            DBMS_OUTPUT.PUT_LINE(
                rec.minute || ''' - ' || rec.event_type || 
                ' by ' || rec.player_name || ' (#' || rec.jersey || ')'
            );
        END LOOP;
        
        IF v_events_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No events recorded for this match');
        END IF;
        
    EXCEPTION
        WHEN invalid_match_id THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Invalid match ID - Match ' || p_match_id || ' does not exist.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error getting match timeline: ' || SQLERRM);
    END get_match_timeline;
    
END match_analyst_pkg;
/