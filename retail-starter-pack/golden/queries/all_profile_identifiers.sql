with email as  (
    SELECT DISTINCT 
    canonical_id as ${unification_id},
    id AS id,
    'email' as id_type,
    canonical_id_first_seen_at AS timestamp
    FROM cdp_unification_${sub}.${unification_id}_lookup
    WHERE id_key_type =
        (SELECT key_type
         FROM cdp_unification_${sub}.${unification_id}_keys
         WHERE key_name ='email')
),
phone as (
    SELECT DISTINCT 
    canonical_id as ${unification_id},
    id AS id,
    'phone_number' as id_type,
    canonical_id_first_seen_at AS timestamp
    FROM cdp_unification_${sub}.${unification_id}_lookup
    WHERE id_key_type =
        (SELECT KEY_TYPE
         FROM cdp_unification_${sub}.${unification_id}_keys
         WHERE key_name ='phone_number')
)
select * from email
union all
select * from phone
;