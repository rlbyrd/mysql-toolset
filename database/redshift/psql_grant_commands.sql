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
AND schemaname='property_nexus'
AND usename = 'matillion_master';


-- Full listing of all grants in a database (\c first)
select
namespace as schemaname , item as object, pu.groname as groupname
, decode(charindex('r',split_part(split_part(array_to_string(relacl, '|'),pu.groname,2 ) ,'/',1)),0,0,1)  as select
, decode(charindex('w',split_part(split_part(array_to_string(relacl, '|'),pu.groname,2 ) ,'/',1)),0,0,1)  as update
, decode(charindex('a',split_part(split_part(array_to_string(relacl, '|'),pu.groname,2 ) ,'/',1)),0,0,1)  as insert
, decode(charindex('d',split_part(split_part(array_to_string(relacl, '|'),pu.groname,2 ) ,'/',1)),0,0,1)  as delete
from
(select
use.usename as subject,
nsp.nspname as namespace,
c.relname as item,
c.relkind as type,
use2.usename as owner,
c.relacl
from
pg_user use
cross join pg_class c
left join pg_namespace nsp on (c.relnamespace = nsp.oid)
left join pg_user use2 on (c.relowner = use2.usesysid)
where c.relowner = use.usesysid
and  nsp.nspname not in ('pg_catalog', 'pg_toast', 'information_schema')
)
join pg_group pu on array_to_string(relacl, '|') like '%'||pu.groname||'%';

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
    u.usename = 'matillion_master'
    AND s.schemaname = 'property_nexus'
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
    u.usename = 'svc_example_gps'
    AND t.tablename = 'all_transactions'
;


-- Users and their groups
SELECT usename, groname
FROM pg_user, pg_group
WHERE pg_user.usesysid = ANY(pg_group.grolist)
AND pg_group.groname in (SELECT DISTINCT pg_group.groname from pg_group) order by usename;


-- specific user's groups
SELECT usename, groname
FROM pg_user, pg_group
WHERE pg_user.usesysid = ANY(pg_group.grolist)
AND pg_group.groname in (SELECT DISTINCT pg_group.groname from pg_group) AND usename='etleapuser'
ORDER by groname;


-- Users in a particular group
select usename from pg_user , pg_group  where
pg_user.usesysid = ANY(pg_group.grolist) and 
pg_group.groname='grp_etl'
ORDER BY usename;


-- Create new group
CREATE GROUP grp_dataeng;


-- Grant group access to database
GRANT CREATE ON DATABASE dev TO GROUP grp_dataeng;


-- Grant and future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA hubspot GRANT SELECT ON  TABLES TO GROUP grp_fivetran_analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA secure_scrubbed TO GROUP grp_secure; 
GRANT USAGE ON SCHEMA secure_scrubbed TO GROUP grp_grp_secure;


-- Same for single user
ALTER DEFAULT PRIVILEGES IN SCHEMA reporting GRANT SELECT ON TABLES TO looker;
GRANT SELECT ON ALL TABLES IN SCHEMA reporting TO looker; 
GRANT USAGE ON SCHEMA reporting TO looker;


-- Raw listing of all GRANTs for a group (existing objects only)
select  
'grant ' || substring(
            case when charindex('r',split_part(split_part(array_to_string(relacl, '|'),pu.groname,2 ) ,'/',1)) > 0 then ',select ' else '' end 
          ||case when charindex('w',split_part(split_part(array_to_string(relacl, '|'),pu.groname,2 ) ,'/',1)) > 0 then ',update ' else '' end 
          ||case when charindex('a',split_part(split_part(array_to_string(relacl, '|'),pu.groname,2 ) ,'/',1)) > 0 then ',insert ' else '' end 
          ||case when charindex('d',split_part(split_part(array_to_string(relacl, '|'),pu.groname,2 ) ,'/',1)) > 0 then ',delete ' else '' end 
          ||case when charindex('R',split_part(split_part(array_to_string(relacl, '|'),pu.groname,2 ) ,'/',1)) > 0 then ',rule ' else '' end 
          ||case when charindex('x',split_part(split_part(array_to_string(relacl, '|'),pu.groname,2 ) ,'/',1)) > 0 then ',references ' else '' end 
          ||case when charindex('t',split_part(split_part(array_to_string(relacl, '|'),pu.groname,2 ) ,'/',1)) > 0 then ',trigger ' else '' end 
          ||case when charindex('X',split_part(split_part(array_to_string(relacl, '|'),pu.groname,2 ) ,'/',1)) > 0 then ',execute ' else '' end 
          ||case when charindex('U',split_part(split_part(array_to_string(relacl, '|'),pu.groname,2 ) ,'/',1)) > 0 then ',usage ' else '' end 
          ||case when charindex('C',split_part(split_part(array_to_string(relacl, '|'),pu.groname,2 ) ,'/',1)) > 0 then ',create ' else '' end 
          ||case when charindex('T',split_part(split_part(array_to_string(relacl, '|'),pu.groname,2 ) ,'/',1)) > 0 then ',temporary ' else '' end 
       , 2,10000)
|| ' on '||namespace||'.'||item ||' to group '||pu.groname||';' as grantsql
from 
(SELECT 
 use.usename as subject, 
 nsp.nspname as namespace, 
 c.relname as item, 
 c.relkind as type, 
 use2.usename as owner, 
 c.relacl 
FROM 
pg_user use 
 cross join pg_class c 
 left join pg_namespace nsp on (c.relnamespace = nsp.oid) 
 left join pg_user use2 on (c.relowner = use2.usesysid)
WHERE 
 c.relowner = use.usesysid  
 and  nsp.nspname   NOT IN ('pg_catalog', 'pg_toast', 'information_schema')
ORDER BY 
 subject,   namespace,   item 
) join pg_group pu on array_to_string(relacl, '|') like '%'||pu.groname||'%' 
where relacl is not null
  and pu.groname='grp_etl'
order by 1;


-- Identify Top 20 disk spill queries 
select 
  a.userid, 
  c.usename,
  a.query, 
  blocks_to_disk, 
  service_class,
  cpu_time,
  convert_timezone('PST',b.starttime) as starttime, 
  convert_timezone('PST',b.endtime) as endtime, 
  datediff(seconds, b.starttime, b.endtime) as duration_seconds,
  trim(b.querytxt) text
from stl_query_metrics a
join stl_query b on b.query = a.query
join pg_user c on c.usesysid = a.userid
where segment=-1 and step = -1 and max_blocks_to_disk > 0 
   and convert_timezone('PST', b.starttime) between '2019-03-26 03:00:00' and '2019-03-26 05:30:00'
order by 4 desc limit 20;
