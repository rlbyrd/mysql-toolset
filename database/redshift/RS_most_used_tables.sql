SELECT *
FROM stl_scan ss
JOIN pg_user pu
    ON ss.userid = pu.usesysid
JOIN svl_query_metrics_summary sqms
    ON ss.query = sqms.query
JOIN temp_mone_tables tmt
    ON tmt.table_id = ss.tbl AND tmt.table = ss.perm_table_name
	
	
select perm_table_name,sum(rows),sum(bytes)sum(fetches) from stl_scan where starttime >= '2018-09-01 00:00:00' group by perm_table_name order by sum(bytes) desc limit 40;