-- Create a view to show sales revenue by category for the current quarter
CREATE VIEW sales_revenue_by_category_qtr AS
SELECT
    fc.category,
    SUM(p.amount) AS total_sales_revenue
FROM
    payment p
    JOIN rental r ON p.rental_id = r.rental_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film_category fc ON i.film_id = fc.film_id
WHERE
    QUARTER(p.payment_date) = QUARTER(CURRENT_DATE) AND YEAR(p.payment_date) = YEAR(CURRENT_DATE)
GROUP BY
    fc.category
HAVING
    total_sales_revenue > 0;

-- Create a query language function to get sales revenue by category for a given quarter
DELIMITER //
CREATE FUNCTION get_sales_revenue_by_category_qtr(IN quarter INT)
RETURNS TABLE(category VARCHAR(255), total_sales_revenue DECIMAL(10, 2))
BEGIN
    RETURN (
        SELECT
            fc.category,
            SUM(p.amount) AS total_sales_revenue
        FROM
            payment p
            JOIN rental r ON p.rental_id = r.rental_id
            JOIN inventory i ON r.inventory_id = i.inventory_id
            JOIN film_category fc ON i.film_id = fc.film_id
        WHERE
            QUARTER(p.payment_date) = quarter AND YEAR(p.payment_date) = YEAR(CURRENT_DATE)
        GROUP BY
            fc.category
        HAVING
            total_sales_revenue > 0
    );
END //
DELIMITER ;

-- Create a procedure language function to add a new movie
DELIMITER //
CREATE PROCEDURE new_movie(IN movie_title VARCHAR(255))
BEGIN
    DECLARE new_film_id INT;
    DECLARE lang_exists INT;

    -- Generate a new unique film ID
    SELECT MAX(film_id) + 1 INTO new_film_id FROM film;

    -- Check if the language exists in the language table
    SELECT COUNT(*) INTO lang_exists FROM language WHERE name = 'Klingon';

    -- If the language does not exist, insert it
    IF lang_exists = 0 THEN
        INSERT INTO language (name) VALUES ('Klingon');
    END IF;

    -- Insert the new movie into the film table if the title is unique
    IF NOT EXISTS (SELECT 1 FROM film WHERE title = movie_title) THEN
        INSERT INTO film (film_id, title, rental_rate, rental_duration, replacement_cost, release_year, language_id)
        VALUES (new_film_id, movie_title, 4.99, 3, 19.99, YEAR(CURRENT_DATE), (SELECT language_id FROM language WHERE name = 'Klingon'));
    END IF;
END //
DELIMITER ;
