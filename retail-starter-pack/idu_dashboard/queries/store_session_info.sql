
SELECT json_extract_scalar('${attempt}','$.id') as attempt_id
    ,json_extract_scalar('${attempt}','$.project.name') as project
    ,json_extract_scalar('${attempt}','$.workflow.name') as workflow
    ,json_extract_scalar('${attempt}','$.status') as status
    ,json_extract_scalar('${attempt}','$.sessionId') as session_id
    ,json_extract_scalar('${attempt}','$.sessionTime') as session_time
    ,json_extract_scalar('${attempt}','$.createdAt') as created_at
    ,json_extract_scalar('${attempt}','$.finishedAt') as finished_at

    

