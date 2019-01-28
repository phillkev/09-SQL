-- * 1a. Display the first and last names of all actors from the table `actor`.
SELECT a.first_name, a.last_name
FROM sakila.actor a;

-- * 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT UPPER(CONCAT(a.first_name, ' ', a.last_name))  AS 'Actor Name'
FROM sakila.actor a;

-- * 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT a.actor_id, a.first_name, a.last_name
FROM sakila.actor a
WHERE LOWER(a.first_name) = 'joe';


-- * 2b. Find all actors whose last name contain the letters `GEN`:
SELECT UPPER(CONCAT(a.first_name, ' ', a.last_name))  AS 'Actor Name'
FROM sakila.actor a
WHERE UPPER(a.last_name) LIKE '%GEN%';

-- * 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT UPPER(CONCAT(a.first_name, ' ', a.last_name))  AS 'Actor Name'
FROM sakila.actor a
WHERE UPPER(a.last_name) LIKE '%LI%'
ORDER BY a.last_name, a.first_name;

-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT ct.country_id, ct.country
FROM sakila.country ct
WHERE ct.country in ('Afghanistan', 'Bangladesh', 'China');


-- * 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE sakila.actor 
ADD COLUMN Description BLOB;


-- * 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE sakila.actor 
DROP COLUMN Description;


-- * 4a. List the last names of actors, as well as how many actors have that last name.
SELECT UPPER(a.last_name), count(a.actor_id)
FROM sakila.actor a
GROUP BY a.last_name
ORDER BY COUNT(a.actor_id) DESC;

-- * 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT UPPER(a.last_name), count(a.actor_id)
FROM sakila.actor a
GROUP BY a.last_name
HAVING COUNT(actor_id) >= 2
ORDER BY COUNT(actor_id) DESC;

-- * 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
-- this table has a timestamp table to track when records are updated.  Include the current_timestamp() in the update statement.
UPDATE sakila.actor
SET first_name = 'HARPO',
	last_update = CURRENT_TIMESTAMP()
WHERE UPPER(last_name) = 'WILLIAMS'
	AND UPPER(first_name) = 'GROUCHO';
    


-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
-- this table has a timestamp table to track when records are updated.  Include the current_timestamp() in the update statement.
UPDATE sakila.actor
SET first_name = 'GROUCHO',
	last_update = CURRENT_TIMESTAMP()
WHERE UPPER(last_name) = 'WILLIAMS'
	AND UPPER(first_name) = 'HARPO';


-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
--  * Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)
SHOW CREATE TABLE sakila.address;

-- * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT s.first_name, s.last_name, a.address
FROM sakila.staff s
JOIN sakila.address a
ON s.address_id = a.address_id;

-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT UPPER(CONCAT(s.first_name, ' ', s.last_name))  AS 'Staff Name', sum(p.amount) as 'Total Rung'
FROM sakila.staff s
JOIN sakila.payment p
ON s.staff_id = p.staff_id
WHERE YEAR(p.payment_date) = 2005
	AND MONTH(p.payment_date) = 8
GROUP BY CONCAT(s.first_name, ' ', s.last_name);


-- * 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT f.title, count(fa.actor_id)
FROM sakila.film f
JOIN sakila.film_actor fa
ON f.film_id = fa.film_id
GROUP BY f.title;

-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT COUNT(i.inventory_id)
FROM sakila.film f
JOIN sakila.inventory i
ON f.film_id = i.film_id
WHERE UPPER(f.title) = 'HUNCHBACK IMPOSSIBLE';


-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
--  ![Total amount paid](Images/total_payment.png)
SELECT UPPER(CONCAT(c.first_name, ' ', c.last_name))  AS 'Customer Name', sum(p.amount)
FROM sakila.customer c
JOIN sakila.payment p
ON c.customer_id = p.customer_id
GROUP BY CONCAT(c.first_name, ' ', c.last_name)
ORDER BY c.last_name;

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

SELECT f.title
FROM sakila.film f
WHERE f.language_id IN 
	(
	SELECT ls.language_id
	FROM sakila.language ls
	WHERE ls.name = 'ENGLISH'
    )
	AND (f.title like 'K%'
	OR f.title like 'Q%');
    
-- While subqueries can be used to answer the business question.  Join syntax feels more natural for this particular question and it is easier to read.
-- I typically only use subqueries when it will reduce the liklyhood of product joins in my result set.
SELECT f.title
FROM sakila.film f
JOIN sakila.language l
ON f.language_id = l.language_id
WHERE ls.name = 'ENGLISH' 
AND (fs.title like 'K%'
			OR fs.title like 'Q%');



-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT UPPER(CONCAT(a.first_name, ' ', a.last_name))  AS 'Actor Name'
FROM sakila.actor a
WHERE a.actor_id in 
	(
	SELECT actor_id
    FROM sakila.film_actor fas
    WHERE fas.film_id IN 
		(
		SELECT fs.film_id
        FROM sakila.film fs
        WHERE fs.title = 'ALONE TRIP'
        )
	);


-- * 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT UPPER(CONCAT(c.first_name, ' ', c.last_name))  AS 'Customer Name', c.email
FROM sakila.customer c
JOIN sakila.address a
ON c.address_id = a.address_id
JOIN sakila.city ci
ON a.city_id = ci.city_id
JOIN sakila.country ct
ON ci.country_id = ct.country_id
WHERE ct.country = 'CANADA';


-- * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT f.title
FROM sakila.film f
JOIN sakila.film_category fc
ON f.film_id = fc.film_id
JOIN sakila.category c
ON fc.category_id = c.category_id 
WHERE c.name='family';


-- * 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(r.rental_id)
FROM sakila.film f
JOIN sakila.inventory i 
ON f.film_id = i.film_id
JOIN sakila.rental r
ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY COUNT(r.rental_id) DESC;


-- * 7f. Write a query to display how much business, in dollars, each store brought in.
-- The easy way to do this is use the already defined view sales_by_store
SELECT store, total_sales
FROM sakila.sales_by_store;

-- But I'm sure the point of the exercise is to write it out long hand
SELECT s.store_id, 
	CONCAT(c.city,', ', ct.country) AS store,
	SUM(p.amount) AS total_sales 
FROM sakila.payment p 
JOIN sakila.rental r 
ON p.rental_id = r.rental_id
JOIN sakila.inventory i 
ON r.inventory_id = i.inventory_id
JOIN sakila.store s 
ON i.store_id = s.store_id
JOIN sakila.address a 
ON s.address_id = a.address_id
JOIN sakila.city c 
ON a.city_id = c.city_id
JOIN sakila.country ct
ON c.country_id = ct.country_id
GROUP BY CONCAT(c.city,', ', ct.country)
ORDER BY s.store_id;



-- * 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, 
	c.city,
    ct.country
FROM sakila.store s 
JOIN sakila.address a 
ON s.address_id = a.address_id
JOIN sakila.city c 
ON a.city_id = c.city_id
JOIN sakila.country ct
ON c.country_id = ct.country_id
ORDER BY s.store_id;


-- * 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name, SUM(p.amount)
FROM sakila.category c
JOIN sakila.film_category fc
ON c.category_id = fc.category_id
JOIN sakila.inventory i
ON fc.film_id = i.film_id
JOIN sakila.rental r 
ON i.inventory_id = r.inventory_id
JOIN sakila.payment p
ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY SUM(p.amount) DESC
LIMIT 5;



-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW sakila.top_5_genres
AS (SELECT c.name, SUM(p.amount)
FROM sakila.category c
JOIN sakila.film_category fc
ON c.category_id = fc.category_id
JOIN sakila.inventory i
ON fc.film_id = i.film_id
JOIN sakila.rental r 
ON i.inventory_id = r.inventory_id
JOIN sakila.payment p
ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY SUM(p.amount) DESC
LIMIT 5);


-- * 8b. How would you display the view that you created in 8a?
SELECT *
FROM sakila.top_5_genres;


-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW sakila.top_5_genres;
