SET SERVEROUTPUT ON
-- Club Manager usage
DECLARE
    v_result VARCHAR2(100);
BEGIN
    club_manager_pkg.get_club_details(1);
    club_manager_pkg.update_player_jersey(2, 60, v_result);
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/

-- Match Analyst usage
BEGIN
    match_analyst_pkg.analyze_team_performance(1, '2025/26');
END;
/

-- Agent usage
BEGIN
    agent_pkg.get_client_contracts(2);
    agent_pkg.search_available_players('Forward', 10, '2025/26');
END;
/