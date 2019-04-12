-- Table level permissions
SELECT *
FROM
    (
    SELECT
        schemaname
        ,objectname
        ,usename
        ,HAS_TABLE_PRIVILEGE(usrs.usename, fullobj, 'select') AND has_schema_privilege(usrs.usename, schemaname, 'usage')  AS sel
        ,HAS_TABLE_PRIVILEGE(usrs.usename, fullobj, 'insert') AND has_schema_privilege(usrs.usename, schemaname, 'usage')  AS ins
        ,HAS_TABLE_PRIVILEGE(usrs.usename, fullobj, 'update') AND has_schema_privilege(usrs.usename, schemaname, 'usage')  AS upd
        ,HAS_TABLE_PRIVILEGE(usrs.usename, fullobj, 'delete') AND has_schema_privilege(usrs.usename, schemaname, 'usage')  AS del
        ,HAS_TABLE_PRIVILEGE(usrs.usename, fullobj, 'references') AND has_schema_privilege(usrs.usename, schemaname, 'usage')  AS ref
    FROM
        (
        SELECT schemaname, 't' AS obj_type, tablename AS objectname, schemaname + '.' + tablename AS fullobj FROM pg_tables
        WHERE schemaname NOT IN ('pg_internal')
        UNION
        SELECT schemaname, 'v' AS obj_type, viewname AS objectname, schemaname + '.' + viewname AS fullobj FROM pg_views
        WHERE schemaname NOT IN ('pg_internal')
        ) AS objs
        ,(SELECT * FROM pg_user) AS usrs
    ORDER BY fullobj
    )
WHERE (sel = TRUE OR ins = TRUE OR upd = TRUE OR del = TRUE OR ref = TRUE)
AND schemaname='reporting'
AND usename = 'emilybrown';

-- check perms for a table
\dp units



-- show all privs for role
SELECT
    u.usename,
    s.schemaname,
    has_schema_privilege(u.usename,s.schemaname,'create') AS user_has_select_permission,
    has_schema_privilege(u.usename,s.schemaname,'usage') AS user_has_usage_permission
FROM
    pg_user u
CROSS JOIN
    (SELECT DISTINCT schemaname FROM pg_tables) s
WHERE
    u.usename = 'job_analyst'
    AND s.schemaname = 'marketo'
;

-- grants for a specific table
SELECT
    u.usename,
    t.schemaname||'.'||t.tablename,
    has_table_privilege(u.usename,t.tablename,'select') AS user_has_select_permission,
    has_table_privilege(u.usename,t.tablename,'insert') AS user_has_insert_permission,
    has_table_privilege(u.usename,t.tablename,'update') AS user_has_update_permission,
    has_table_privilege(u.usename,t.tablename,'delete') AS user_has_delete_permission,
    has_table_privilege(u.usename,t.tablename,'references') AS user_has_references_permission
FROM
    pg_user u
CROSS JOIN
    pg_tables t
WHERE
    u.usename = 'marcurbaitel'
    AND t.tablename = 'trust_rev_payments'
;

-- Users and their groups
SELECT usename, groname
FROM pg_user, pg_group
WHERE pg_user.usesysid = ANY(pg_group.grolist)
AND pg_group.groname in (SELECT DISTINCT pg_group.groname from pg_group) order by usename;

-- Users in a particular group
select usename from pg_user , pg_group  where
pg_user.usesysid = ANY(pg_group.grolist) and 
pg_group.groname='grp_maxbi'
ORDER BY BY usename;

-- Grant and future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA hubspot GRANT SELECT ON  TABLES TO GROUP grp_fivetran_analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA hubspot TO GROUP grp_fivetran_analyst; 
GRANT USAGE ON SCHEMA hubspot TO GROUP grp_fivetran_analyst;

-- Same for single user
ALTER DEFAULT PRIVILEGES IN SCHEMA reporting GRANT SELECT ON TABLES TO looker;
GRANT SELECT ON ALL TABLES IN SCHEMA reporting TO looker; 
GRANT USAGE ON SCHEMA reporting TO looker;
