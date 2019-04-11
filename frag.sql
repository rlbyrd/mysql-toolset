-- SQL snippet to calculate table fragmentation.
SELECT
  table_schema,
  TABLE_NAME,
  ROUND(DATA_LENGTH / 1024 / 1024) AS data_length,
  ROUND(INDEX_LENGTH / 1024 / 1024) AS index_length,
  ROUND(DATA_FREE / 1024 / 1024) AS data_free,
  CONCAT(
    ROUND(
      (
        data_free / (index_length + data_length)
      ) * 100
    ),
    '%'
  ) AS frag_ratio
FROM
  information_schema.tables
WHERE DATA_FREE > 0
AND TABLE_SCHEMA = '%%SCHEMA%%'
ORDER BY data_free / (index_length + data_length) DESC;
