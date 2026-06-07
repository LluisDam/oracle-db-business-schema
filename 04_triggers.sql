-- TRIGGERS — Automatizacion de reglas de negocio

CREATE OR REPLACE TRIGGER trg_projects_updated_at
BEFORE UPDATE ON projects FOR EACH ROW
BEGIN :NEW.updated_at:=SYSTIMESTAMP; END;
/

CREATE OR REPLACE TRIGGER trg_tasks_updated_at
BEFORE UPDATE ON tasks FOR EACH ROW
BEGIN
    :NEW.updated_at:=SYSTIMESTAMP;
    IF :NEW.status='DONE' AND (:OLD.status IS NULL OR :OLD.status!='DONE') THEN
        :NEW.completed_at:=SYSTIMESTAMP;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_time_log_update_task
AFTER INSERT OR UPDATE OR DELETE ON time_logs FOR EACH ROW
DECLARE v_task_id NUMBER;
BEGIN
    v_task_id:=CASE WHEN DELETING THEN :OLD.task_id ELSE :NEW.task_id END;
    UPDATE tasks SET logged_hours=(SELECT NVL(SUM(hours),0) FROM time_logs WHERE task_id=v_task_id)
    WHERE id=v_task_id;
END;
/

CREATE OR REPLACE TRIGGER trg_update_project_spent
AFTER INSERT OR DELETE ON time_logs FOR EACH ROW
DECLARE v_proj_id NUMBER;
BEGIN
    SELECT t.project_id INTO v_proj_id FROM tasks t
    WHERE t.id=CASE WHEN INSERTING THEN :NEW.task_id ELSE :OLD.task_id END;
    UPDATE projects SET spent=(
        SELECT NVL(SUM(tl.hours*tm.hourly_rate),0)
        FROM time_logs tl JOIN tasks t2 ON t2.id=tl.task_id
        JOIN team_members tm ON tm.id=tl.member_id
        WHERE t2.project_id=v_proj_id AND tl.billable='Y'
    ) WHERE id=v_proj_id;
END;
/

CREATE OR REPLACE TRIGGER trg_prevent_reopen_completed
BEFORE UPDATE OF status ON projects FOR EACH ROW
BEGIN
    IF :OLD.status='COMPLETED' AND :NEW.status='IN_PROGRESS' THEN
        RAISE_APPLICATION_ERROR(-20010,'No reabrir COMPLETED. Usa ON_HOLD.');
    END IF;
END;
/

COMMIT;
