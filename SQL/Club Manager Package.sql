CREATE OR REPLACE PACKAGE club_manager_pkg AS
    -- User-defined exceptions
    invalid_club_id EXCEPTION;
    invalid_jersey_number EXCEPTION;
    duplicate_jersey_number EXCEPTION;
    
    -- Get club details with stadium info
    PROCEDURE get_club_details(p_club_id IN NUMBER);
    
    -- Get team roster with player stats
    PROCEDURE get_team_roster(p_team_id IN NUMBER, p_season IN VARCHAR2);
    
    -- Update player jersey number with validation
    PROCEDURE update_player_jersey(
        p_player_id IN NUMBER,
        p_new_jersey IN NUMBER,
        p_success OUT VARCHAR2
    );
END club_manager_pkg;
/

CREATE OR REPLACE PACKAGE BODY club_manager_pkg AS
    
    PROCEDURE get_club_details(p_club_id IN NUMBER) IS
        CURSOR club_cursor IS
            SELECT c.name, c.country, c.city, c.budget,
                   s.name AS stadium_name, s.capacity
            FROM Club c
            LEFT JOIN Stadium s ON c.club_id = s.club_id
            WHERE c.club_id = p_club_id;
            
        v_club_info club_cursor%ROWTYPE;
        v_club_exists NUMBER;
    BEGIN
        -- Validate club ID exists
        SELECT COUNT(*) INTO v_club_exists
        FROM Club
        WHERE club_id = p_club_id;
        
        IF v_club_exists = 0 THEN
            RAISE invalid_club_id;
        END IF;
        
        OPEN club_cursor;
        FETCH club_cursor INTO v_club_info;
        
        IF club_cursor%FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Club: ' || v_club_info.name);
            DBMS_OUTPUT.PUT_LINE('Location: ' || v_club_info.city || ', ' || v_club_info.country);
            DBMS_OUTPUT.PUT_LINE('Budget: $' || v_club_info.budget);
            DBMS_OUTPUT.PUT_LINE('Stadium: ' || NVL(v_club_info.stadium_name, 'No stadium'));
            DBMS_OUTPUT.PUT_LINE('Capacity: ' || NVL(TO_CHAR(v_club_info.capacity), 'N/A'));
        END IF;
        
        CLOSE club_cursor;
        
    EXCEPTION
        WHEN invalid_club_id THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Invalid club ID - Club ' || p_club_id || ' does not exist.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error getting club details: ' || SQLERRM);
    END get_club_details;
    
    PROCEDURE get_team_roster(p_team_id IN NUMBER, p_season IN VARCHAR2) IS
        CURSOR roster_cursor IS
            SELECT p.name AS player_name, pl.jersey, pl.position,
                   ps.goals, ps.assists
            FROM Player pl
            JOIN Person p ON pl.person_id = p.person_id
            LEFT JOIN PlayerStats ps ON pl.player_id = ps.player_id 
                AND ps.season = p_season
            WHERE pl.team_id = p_team_id 
                AND pl.season = p_season
            ORDER BY pl.position, pl.jersey;
            
        v_count NUMBER := 0;
        v_team_exists NUMBER;
    BEGIN
        -- Validate team exists
        SELECT COUNT(*) INTO v_team_exists
        FROM Team
        WHERE team_id = p_team_id;
        
        IF v_team_exists = 0 THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Team ID ' || p_team_id || ' does not exist.');
            RETURN;
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Team Roster for Season ' || p_season);
        DBMS_OUTPUT.PUT_LINE('----------------------------------');
        
        FOR rec IN roster_cursor LOOP
            v_count := v_count + 1;
            DBMS_OUTPUT.PUT_LINE(
                '#' || rec.jersey || ' ' || rec.player_name || 
                ' (' || rec.position || ') - ' ||
                rec.goals || ' goals, ' || rec.assists || ' assists'
            );
        END LOOP;
        
        IF v_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No players found for this team/season');
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error getting roster: ' || SQLERRM);
    END get_team_roster;
    
    PROCEDURE update_player_jersey(
        p_player_id IN NUMBER,
        p_new_jersey IN NUMBER,
        p_success OUT VARCHAR2
    ) IS
        v_team_id NUMBER;
        v_season VARCHAR2(20);
        v_exists NUMBER;
        v_player_exists NUMBER;
    BEGIN
        -- Validate jersey number (1-99)
        IF p_new_jersey < 1 OR p_new_jersey > 99 THEN
            RAISE invalid_jersey_number;
        END IF;
        
        -- Check if player exists
        SELECT COUNT(*) INTO v_player_exists
        FROM Player
        WHERE player_id = p_player_id;
        
        IF v_player_exists = 0 THEN
            p_success := 'FAILURE: Player ID ' || p_player_id || ' does not exist';
            RETURN;
        END IF;
        
        -- Get team and season for the player
        SELECT team_id, season INTO v_team_id, v_season
        FROM Player
        WHERE player_id = p_player_id;
        
        -- Check if jersey number already exists in same team/season
        SELECT COUNT(*) INTO v_exists
        FROM Player
        WHERE team_id = v_team_id
            AND season = v_season
            AND jersey = p_new_jersey
            AND player_id != p_player_id;
            
        IF v_exists > 0 THEN
            RAISE duplicate_jersey_number;
        END IF;
        
        UPDATE Player
        SET jersey = p_new_jersey
        WHERE player_id = p_player_id;
        
        COMMIT;
        p_success := 'SUCCESS: Jersey updated to ' || p_new_jersey;
        
    EXCEPTION
        WHEN invalid_jersey_number THEN
            p_success := 'FAILURE: Jersey number must be between 1 and 99';
        WHEN duplicate_jersey_number THEN
            p_success := 'FAILURE: Jersey number ' || p_new_jersey || ' already exists in this team/season';
        WHEN OTHERS THEN
            ROLLBACK;
            p_success := 'FAILURE: ' || SQLERRM;
    END update_player_jersey;
    
END club_manager_pkg;
/