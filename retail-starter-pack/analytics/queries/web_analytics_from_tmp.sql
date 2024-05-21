SELECT ${gvar},
       count(1) AS ${gvar}_count
FROM ${intablename}
group by ${gvar}