-- SEED DATA — Datos de ejemplo para desarrollo y testing

INSERT INTO clients (name,nif,email,phone,city,sector,kit_digital) VALUES ('Ferreteria Lopez SL','B12345678','info@ferreteria.es','971 234 567','Palma','Comercio','Y');
INSERT INTO clients (name,nif,email,phone,city,sector,kit_digital) VALUES ('Fontaneria Garcia SA','A87654321','garcia@fontaneria.com','971 345 678','Manacor','Servicios','Y');
INSERT INTO clients (name,nif,email,phone,city,sector,kit_digital) VALUES ('Boutique Raquel','B98765432','raquel@boutique.es','971 456 789','Palma','Moda','Y');

INSERT INTO team_members (name,email,role,hourly_rate) VALUES ('Lluis Soberats','llsobi@gmail.com','Technical PM / Full Stack',45);
INSERT INTO team_members (name,email,role,hourly_rate) VALUES ('Laura Garcia','laura@itcm.es','Frontend Developer',35);
INSERT INTO team_members (name,email,role,hourly_rate) VALUES ('Marc Torrens','marc@itcm.es','Backend Developer',38);

DECLARE v_id NUMBER;
BEGIN
    sp_create_project(
        p_client_id=>1, p_name=>'Web Corporativa Kit Digital - Ferreteria Lopez',
        p_description=>'WordPress y SEO. 100% aceptacion.',
        p_budget=>2500, p_start_date=>DATE '2024-01-15', p_end_date=>DATE '2024-03-15',
        p_kit_code=>'KD-2024-001', p_kit_amount=>2000, p_project_id=>v_id
    );
    INSERT INTO tasks (project_id,sprint_id,title,status,priority,story_points,estimated_hours,assignee_id)
    SELECT v_id,s.id,'Diseno mockups','DONE','HIGH',5,8,2 FROM sprints s WHERE s.project_id=v_id;
    INSERT INTO tasks (project_id,sprint_id,title,status,priority,story_points,estimated_hours,assignee_id)
    SELECT v_id,s.id,'Config WordPress','DONE','HIGH',3,4,3 FROM sprints s WHERE s.project_id=v_id;
    INSERT INTO tasks (project_id,sprint_id,title,status,priority,story_points,estimated_hours,assignee_id)
    SELECT v_id,s.id,'Tema personalizado','DONE','HIGH',8,16,2 FROM sprints s WHERE s.project_id=v_id;
    UPDATE projects SET status='COMPLETED' WHERE id=v_id;
END;
/

COMMIT;

-- Verificacion
SELECT 'Clients:'||COUNT(*) FROM clients UNION ALL SELECT 'Projects:'||COUNT(*) FROM projects UNION ALL SELECT 'Tasks:'||COUNT(*) FROM tasks;
