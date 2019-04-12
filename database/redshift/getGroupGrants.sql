select relacl , 
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
|| ' on '||namespace||'.'||item ||' to "'||pu.groname||'";' as grantsql
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
  and pu.groname='job_analyst'
order by 2;