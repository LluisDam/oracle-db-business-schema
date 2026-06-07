-- VIEWS: Reporting y KPIs

CREATE OR REPLACE VIEW v_project_summary AS
SELECT p.id, p.name AS project_name, c.name AS client_name,
    p.status, p.priority, p.budget, p.spent,
    ROUND((p.spent/NULLIF(p.budget,0))*100,1) AS budget_used_pct,
    COUNT(DISTINCT t.id) AS total_tasks,
    COUNT(DISTINCT CASE WHEN t.status='DONE' THEN t.id END) AS done_tasks,
    COUNT(DISTINCT CASE WHEN t.status='IN_PROGRESS' THEN t.id END) AS in_progress_tasks,
    ROUND(COUNT(DISTINCT CASE WHEN t.status='DONE' THEN t.id END)/NULLIF(COUNT(DISTINCT t.id),0)*100,1) AS completion_pct,
    NVL(SUM(t.story_points),0) AS total_story_points,
    NVL(SUM(CASE WHEN t.status='DONE' THEN t.story_points END),0) AS done_story_points,
    NVL(SUM(t.estimated_hours),0) AS estimated_hours,
    NVL(SUM(t.logged_hours),0) AS logged_hours,
    p.start_date, p.end_date, p.kit_digital_code, p.kit_digital_amount
FROM projects p JOIN clients c ON c.id=p.client_id
LEFT JOIN tasks t ON t.project_id=p.id
GROUP BY p.id,p.name,c.name,p.status,p.priority,p.budget,p.spent,
    p.start_date,p.end_date,p.kit_digital_code,p.kit_digital_amount;

CREATE OR REPLACE VIEW v_sprint_kpi AS
SELECT s.id, s.project_id, p.name AS project_name, s.name AS sprint_name,
    s.status, s.start_date, s.end_date, s.velocity_planned, s.velocity_actual,
    COUNT(t.id) AS total_tasks,
    SUM(NVL(t.story_points,0)) AS total_points,
    SUM(CASE WHEN t.status='DONE' THEN NVL(t.story_points,0) ELSE 0 END) AS done_points
FROM sprints s JOIN projects p ON p.id=s.project_id
LEFT JOIN tasks t ON t.sprint_id=s.id
GROUP BY s.id,s.project_id,p.name,s.name,s.status,s.start_date,s.end_date,s.velocity_planned,s.velocity_actual;

CREATE OR REPLACE VIEW v_team_workload AS
SELECT tm.id, tm.name AS member_name, tm.role,
    COUNT(DISTINCT t.id) AS assigned_tasks,
    COUNT(DISTINCT CASE WHEN t.status NOT IN ('DONE','CANCELLED') THEN t.id END) AS open_tasks,
    NVL(SUM(t.estimated_hours),0) AS estimated_hours,
    NVL(SUM(tl.hours),0) AS logged_hours
FROM team_members tm
LEFT JOIN tasks t ON t.assignee_id=tm.id AND t.status!='CANCELLED'
LEFT JOIN time_logs tl ON tl.member_id=tm.id
WHERE tm.active='Y' GROUP BY tm.id,tm.name,tm.role;

COMMIT;
