-- STORED PROCEDURES — Logica de negocio

CREATE OR REPLACE PROCEDURE sp_create_project (
    p_client_id IN projects.client_id%TYPE, p_name IN projects.name%TYPE,
    p_description IN projects.description%TYPE, p_budget IN projects.budget%TYPE,
    p_start_date IN projects.start_date%TYPE, p_end_date IN projects.end_date%TYPE DEFAULT NULL,
    p_kit_code IN projects.kit_digital_code%TYPE DEFAULT NULL,
    p_kit_amount IN projects.kit_digital_amount%TYPE DEFAULT 0,
    p_project_id OUT projects.id%TYPE
) AS
BEGIN
    INSERT INTO projects (client_id,name,description,budget,start_date,end_date,kit_digital_code,kit_digital_amount)
    VALUES (p_client_id,p_name,p_description,p_budget,p_start_date,p_end_date,p_kit_code,p_kit_amount)
    RETURNING id INTO p_project_id;
    INSERT INTO sprints (project_id,name,goal,status,start_date,end_date,velocity_planned)
    VALUES (p_project_id,'Sprint 1','Setup inicial','PLANNED',p_start_date,p_start_date+14,20);
    COMMIT;
EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20001,SQLERRM);
END sp_create_project;
/

CREATE OR REPLACE PROCEDURE sp_close_sprint (p_sprint_id IN sprints.id%TYPE) AS
    v_vel NUMBER; v_status VARCHAR2(20);
BEGIN
    SELECT status INTO v_status FROM sprints WHERE id=p_sprint_id;
    IF v_status!='ACTIVE' THEN RAISE_APPLICATION_ERROR(-20002,'Solo ACTIVE puede cerrarse'); END IF;
    SELECT NVL(SUM(story_points),0) INTO v_vel FROM tasks WHERE sprint_id=p_sprint_id AND status='DONE';
    UPDATE sprints SET status='COMPLETED',velocity_actual=v_vel WHERE id=p_sprint_id;
    UPDATE tasks SET sprint_id=NULL,status='TODO' WHERE sprint_id=p_sprint_id AND status NOT IN ('DONE','CANCELLED');
    COMMIT;
END sp_close_sprint;
/

CREATE OR REPLACE PROCEDURE sp_get_project_kpis (p_project_id IN projects.id%TYPE, p_cursor OUT SYS_REFCURSOR) AS
BEGIN
    OPEN p_cursor FOR
        SELECT ps.*, NVL(SUM(tl.hours),0) AS total_logged,
               COUNT(DISTINCT r.id) AS open_risks, COUNT(DISTINCT sp.id) AS sprints
        FROM v_project_summary ps
        LEFT JOIN tasks t ON t.project_id=ps.id
        LEFT JOIN time_logs tl ON tl.task_id=t.id
        LEFT JOIN risks r ON r.project_id=ps.id AND r.status='OPEN'
        LEFT JOIN sprints sp ON sp.project_id=ps.id
        WHERE ps.id=p_project_id
        GROUP BY ps.id,ps.project_name,ps.client_name,ps.status,ps.priority,ps.budget,ps.spent,
                 ps.budget_used_pct,ps.total_tasks,ps.done_tasks,ps.in_progress_tasks,ps.todo_tasks,
                 ps.completion_pct,ps.total_story_points,ps.done_story_points,
                 ps.estimated_hours,ps.logged_hours,ps.start_date,ps.end_date,
                 ps.kit_digital_code,ps.kit_digital_amount;
END sp_get_project_kpis;
/

COMMIT;
