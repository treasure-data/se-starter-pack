SELECT
    e.trfmd_email AS id,
    e.trfmd_id_type,
    e.trfmd_consent_type,
    e.${unification_id},
    e.trfmd_consent_flag,
    CASE 
        WHEN pi.email IS NOT NULL THEN 'True' 
        ELSE 'False'
    END AS is_primary
FROM cdp_unification_${sub}.enriched_consents_email e
LEFT JOIN cdp_unification_${sub}.profile_identifiers pi
    ON e.trfmd_email = pi.email

UNION ALL

SELECT
    p.trfmd_phone_number AS id,
    p.trfmd_id_type,
    p.trfmd_consent_type,
    p.${unification_id},
    p.trfmd_consent_flag,
    CASE 
        WHEN pi.phone_number IS NOT NULL THEN 'True'
        ELSE 'False'
    END AS is_primary
FROM cdp_unification_${sub}.enriched_consents_phone p
LEFT JOIN cdp_unification_${sub}.profile_identifiers pi
    ON p.trfmd_phone_number = pi.phone_number