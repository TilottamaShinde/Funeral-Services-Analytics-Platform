SELECT
    survey_type,
    AVG(satisfaction_score) AS avg_satisfaction
FROM customer_feedback
GROUP BY survey_type;