CREATE OR REPLACE PACKAGE agent_pkg AS
    -- User-defined exceptions
    invalid_agent_id EXCEPTION;
    invalid_person_id EXCEPTION;
    invalid_season EXCEPTION;
    no_clients_found EXCEPTION;
    
    -- Get client portfolio
    PROCEDURE get_client_portfolio(p_agent_id IN NUMBER); -- Assuming agent_id in Person
    
    -- Get client contract details
    PROCEDURE get_client_contracts(p_person_id IN NUMBER);
    
    -- Search for available players by criteria
    PROCEDURE search_available_players(
        p_position IN VARCHAR2 DEFAULT NULL,
        p_min_goals IN NUMBER DEFAULT 0,
        p_season IN VARCHAR2
    );
    
END agent_pkg;
/

CREATE OR REPLACE PACKAGE BODY agent_pkg AS
    
    PROCEDURE get_client_portfolio(p_agent_id IN NUMBER) IS
        CURSOR clients_cursor IS
            SELECT p.person_id, p.name, p.nationality,
                   pl.position, t.category AS team_name,
                   c.salary
            FROM Person p
            JOIN Player pl ON p.person_id = pl.person_id
            JOIN Team t ON pl.team_id = t.team_id
            LEFT JOIN Contract c ON p.person_id = c.person_id
                AND c.end_date > SYSDATE  -- Active contracts only
            WHERE p.person_id IN (
                -- Assuming agent-player relationship exists
                SELECT person_id FROM Contract 
                WHERE person_type = 'Player' 
                -- Add your agent-player relationship logic here
            )
            ORDER BY c.salary DESC NULLS LAST;
            
        v_total_clients NUMBER := 0;
        v_total_value NUMBER := 0;
        v_agent_exists NUMBER;
    BEGIN
        -- Validate agent ID exists
        SELECT COUNT(*) INTO v_agent_exists
        FROM Person
        WHERE person_id = p_agent_id;
        
        IF v_agent_exists = 0 THEN
            RAISE invalid_agent_id;
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Client Portfolio');
        DBMS_OUTPUT.PUT_LINE('================');
        
        FOR rec IN clients_cursor LOOP
            v_total_clients := v_total_clients + 1;
            v_total_value := v_total_value + NVL(rec.salary, 0);
            
            DBMS_OUTPUT.PUT_LINE(
                'Client: ' || rec.name || ' (' || rec.nationality || ')'
            );
            DBMS_OUTPUT.PUT_LINE(
                'Position: ' || rec.position || ' | Team: ' || rec.team_name
            );
            DBMS_OUTPUT.PUT_LINE(
                'Salary: $' || NVL(TO_CHAR(rec.salary), 'Not available')
            );
            DBMS_OUTPUT.PUT_LINE('---');
        END LOOP;
        
        IF v_total_clients = 0 THEN
            RAISE no_clients_found;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Total Clients: ' || v_total_clients);
            DBMS_OUTPUT.PUT_LINE('Total Portfolio Value: $' || v_total_value);
            
            -- Calculate average salary
            DBMS_OUTPUT.PUT_LINE('Average Salary: $' || 
                ROUND(v_total_value / v_total_clients, 2)
            );
        END IF;
        
    EXCEPTION
        WHEN invalid_agent_id THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Invalid agent ID - Agent ' || p_agent_id || ' does not exist.');
        WHEN no_clients_found THEN
            DBMS_OUTPUT.PUT_LINE('No clients found for agent ID ' || p_agent_id);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error getting client portfolio: ' || SQLERRM);
    END get_client_portfolio;
    
    PROCEDURE get_client_contracts(p_person_id IN NUMBER) IS
        CURSOR contracts_cursor IS
            SELECT c.contract_id, c.person_type,
                   c.start_date, c.end_date,
                   c.salary, cl.name AS club_name
            FROM Contract c
            JOIN Club cl ON c.club_id = cl.club_id
            WHERE c.person_id = p_person_id
            ORDER BY c.start_date DESC;
            
        v_contract_count NUMBER := 0;
        v_person_exists NUMBER;
        v_person_name VARCHAR2(100);
    BEGIN
        -- Validate person ID exists
        SELECT COUNT(*), MAX(name) INTO v_person_exists, v_person_name
        FROM Person
        WHERE person_id = p_person_id;
        
        IF v_person_exists = 0 THEN
            RAISE invalid_person_id;
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Client Contracts for ' || v_person_name);
        DBMS_OUTPUT.PUT_LINE('==================================');
        
        FOR rec IN contracts_cursor LOOP
            v_contract_count := v_contract_count + 1;
            
            DBMS_OUTPUT.PUT_LINE('Contract #' || rec.contract_id);
            DBMS_OUTPUT.PUT_LINE('Type: ' || rec.person_type);
            DBMS_OUTPUT.PUT_LINE('Club: ' || rec.club_name);
            DBMS_OUTPUT.PUT_LINE('Period: ' || 
                TO_CHAR(rec.start_date, 'DD-MON-YYYY') || ' to ' ||
                TO_CHAR(rec.end_date, 'DD-MON-YYYY')
            );
            DBMS_OUTPUT.PUT_LINE('Salary: $' || rec.salary);
            
            -- Enhanced status calculation
            DECLARE
                v_status VARCHAR2(20);
                v_days_remaining NUMBER;
            BEGIN
                IF rec.end_date < SYSDATE THEN
                    v_status := 'Expired';
                ELSIF rec.start_date > SYSDATE THEN
                    v_status := 'Future';
                    v_days_remaining := rec.start_date - SYSDATE;
                ELSE
                    v_status := 'Active';
                    v_days_remaining := rec.end_date - SYSDATE;
                END IF;
                
                DBMS_OUTPUT.PUT_LINE('Status: ' || v_status);
                IF v_days_remaining IS NOT NULL AND v_status != 'Expired' THEN
                    DBMS_OUTPUT.PUT_LINE('Days Remaining: ' || ROUND(v_days_remaining));
                END IF;
            END;
            
            DBMS_OUTPUT.PUT_LINE('---');
        END LOOP;
        
        IF v_contract_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No contracts found for this client');
        END IF;
        
    EXCEPTION
        WHEN invalid_person_id THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Invalid person ID - Person ' || p_person_id || ' does not exist.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error getting client contracts: ' || SQLERRM);
    END get_client_contracts;
    
    PROCEDURE search_available_players(
        p_position IN VARCHAR2 DEFAULT NULL,
        p_min_goals IN NUMBER DEFAULT 0,
        p_season IN VARCHAR2
    ) IS
        CURSOR players_cursor IS
            SELECT p.name, p.nationality, p.birth_date,
                   pl.position, ps.goals, ps.assists,
                   t.category AS team_name,
                   c.salary
            FROM Person p
            JOIN Player pl ON p.person_id = pl.person_id
            JOIN PlayerStats ps ON pl.player_id = ps.player_id
            JOIN Team t ON pl.team_id = t.team_id
            LEFT JOIN Contract c ON p.person_id = c.person_id
                AND c.end_date > SYSDATE
            WHERE pl.season = p_season
                AND ps.season = p_season
                AND ps.goals >= p_min_goals
                AND (p_position IS NULL OR pl.position = p_position)
                -- Add contract expiration logic for "available" players
                AND (c.end_date IS NULL OR c.end_date < ADD_MONTHS(SYSDATE, 6))
            ORDER BY ps.goals DESC, c.salary DESC NULLS LAST;
            
        v_player_count NUMBER := 0;
        v_season_exists NUMBER;
    BEGIN
        -- Validate season exists
        SELECT COUNT(*) INTO v_season_exists
        FROM Player
        WHERE season = p_season
        AND ROWNUM = 1;
        
        IF v_season_exists = 0 THEN
            RAISE invalid_season;
        END IF;
        
        -- Validate minimum goals is not negative
        IF p_min_goals < 0 THEN
            DBMS_OUTPUT.PUT_LINE('WARNING: Minimum goals cannot be negative. Using 0 instead.');
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Available Players Search - Season ' || p_season);
        DBMS_OUTPUT.PUT_LINE('============================================');
        
        IF p_position IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('Position: ' || p_position);
        END IF;
        DBMS_OUTPUT.PUT_LINE('Minimum Goals: ' || GREATEST(p_min_goals, 0));
        DBMS_OUTPUT.PUT_LINE('---');
        
        FOR rec IN players_cursor LOOP
            v_player_count := v_player_count + 1;
            
            DBMS_OUTPUT.PUT_LINE('Player: ' || rec.name);
            DBMS_OUTPUT.PUT_LINE('Nationality: ' || rec.nationality);
            DBMS_OUTPUT.PUT_LINE('Age: ' || 
                TRUNC(MONTHS_BETWEEN(SYSDATE, rec.birth_date)/12) || ' years'
            );
            DBMS_OUTPUT.PUT_LINE('Position: ' || rec.position);
            DBMS_OUTPUT.PUT_LINE('Team: ' || rec.team_name);
            DBMS_OUTPUT.PUT_LINE('Performance: ' || rec.goals || ' goals, ' || rec.assists || ' assists');
            DBMS_OUTPUT.PUT_LINE('Current Salary: $' || NVL(TO_CHAR(rec.salary), 'Unknown'));
            
            -- Add contract status
            IF rec.salary IS NULL THEN
                DBMS_OUTPUT.PUT_LINE('Contract Status: Free agent');
            ELSE
                DBMS_OUTPUT.PUT_LINE('Contract Status: Contracted');
            END IF;
            
            DBMS_OUTPUT.PUT_LINE('---');
        END LOOP;
        
        IF v_player_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No players match the search criteria');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Total Found: ' || v_player_count || ' players');
        END IF;
        
    EXCEPTION
        WHEN invalid_season THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Invalid season - No players found for season ' || p_season);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error searching players: ' || SQLERRM);
    END search_available_players;
    
END agent_pkg;
/