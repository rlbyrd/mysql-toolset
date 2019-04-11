WITH object_list(schema_name,object_name,permission_info) 
 AS (
    SELECT N.nspname, C.relname, array_to_string(relacl,',')
    FROM pg_class AS C
        INNER JOIN pg_namespace AS N
        ON C.relnamespace = N.oid
    WHERE C.relkind in ('v','r')
    AND  N.nspname NOT IN ('pg_catalog', 'pg_toast', 'information_schema')
    AND C.relacl[1] IS NOT NULL
  ),
  object_permissions(schema_name,object_name,permission_string)
  AS (
    SELECT schema_name,object_name, SPLIT_PART(permission_info,',',1) FROM object_list
    UNION ALL
    SELECT schema_name,object_name, SPLIT_PART(permission_info,',',2) FROM object_list
    UNION ALL
    SELECT schema_name,object_name, SPLIT_PART(permission_info,',',3) FROM object_list
    UNION ALL
    SELECT schema_name,object_name, SPLIT_PART(permission_info,',',4) FROM object_list
    UNION ALL
    SELECT schema_name,object_name, SPLIT_PART(permission_info,',',5) FROM object_list
    UNION ALL
    SELECT schema_name,object_name, SPLIT_PART(permission_info,',',6) FROM object_list
    UNION ALL
    SELECT schema_name,object_name, SPLIT_PART(permission_info,',',7) FROM object_list
    UNION ALL
    SELECT schema_name,object_name, SPLIT_PART(permission_info,',',8) FROM object_list
    UNION ALL
    SELECT schema_name,object_name, SPLIT_PART(permission_info,',',9) FROM object_list
    UNION ALL
    SELECT schema_name,object_name, SPLIT_PART(permission_info,',',10) FROM object_list
  ),
  permission_parts(schema_name, object_name,security_principal, permission_pattern)
  AS (
      SELECT
          schema_name,
          object_name,
          LEFT(permission_string ,CHARINDEX('=',permission_string)-1),
          SPLIT_PART(SPLIT_PART(permission_string,'=',2),'/',1)
      FROM object_permissions
      WHERE permission_string >''
  )
SELECT
    schema_name,
    object_name,
    'GRANT ' ||
    SUBSTRING(
        case when charindex('r',permission_pattern) > 0 then ',SELECT ' else '' end
      ||case when charindex('w',permission_pattern) > 0 then ',UPDATE ' else '' end
      ||case when charindex('a',permission_pattern) > 0 then ',INSERT ' else '' end
      ||case when charindex('d',permission_pattern) > 0 then ',DELETE ' else '' end
      ||case when charindex('R',permission_pattern) > 0 then ',RULE ' else '' end
      ||case when charindex('x',permission_pattern) > 0 then ',REFERENCES ' else '' end
      ||case when charindex('t',permission_pattern) > 0 then ',TRIGGER ' else '' end
      ||case when charindex('X',permission_pattern) > 0 then ',EXECUTE ' else '' end
      ||case when charindex('U',permission_pattern) > 0 then ',USAGE ' else '' end
      ||case when charindex('C',permission_pattern) > 0 then ',CREATE ' else '' end
      ||case when charindex('T',permission_pattern) > 0 then ',TEMPORARY ' else '' end
    ,2,10000
    )
    || ' ON ' || schema_name||'.'||object_name
     || ' TO ' || security_principal
     || ';' as grantsql
FROM permission_parts

;
