SELECT
    feedback_category,
    COUNT(*) AS feedback_count
FROM customer_feedback
GROUP BY feedback_category;