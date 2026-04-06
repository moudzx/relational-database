CREATE OR REPLACE TRIGGER trg_match_result
BEFORE INSERT OR UPDATE ON FootballMatch
FOR EACH ROW
BEGIN
    IF :NEW.home_score IS NOT NULL AND :NEW.away_score IS NOT NULL THEN
        IF :NEW.home_score > :NEW.away_score THEN
            :NEW.match_result := 'HOME_WIN';
        ELSIF :NEW.home_score < :NEW.away_score THEN
            :NEW.match_result := 'AWAY_WIN';
        ELSE
            :NEW.match_result := 'DRAW';
        END IF;
    END IF;
END;
/