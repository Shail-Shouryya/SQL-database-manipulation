# Homework Assignment
## Installation Instructions
#* Refer to the [installation guide](Installation.md) to install the necessary files.

## Instructions indicated by "*"
#show databases;
use sakila;
show tables;
select * FROM actor;
#* 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name FROM actor;
#* 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT(UCASE(first_name)," ",UCASE(last_name)) as "Actor Name" FROM actor;
#* 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor
WHERE locate(first_name, "Joe") != 0;
#WHERE first_name = "Joe";
#* 2b. Find all actors whose last name contain the letters `GEN`:
SELECT last_name FROM actor
WHERE last_name LIKE '%gen%';
#* 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;
#* 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');
#* 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD COLUMN description BLOB after last_name;
#select * from actor;
#* 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor DROP COLUMN description;
#select * from actor;
#* 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS "Number of actors with last name"
FROM actor
GROUP BY last_name;
#* 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS "Number of actors with last name"
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;
#* 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
#SELECT first_name, last_name FROM actor WHERE first_name = "Groucho" and last_name = "Williams"
UPDATE actor
SET first_name = "HARPO" WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";
#SELECT first_name, last_name FROM actor WHERE last_name = "Williams";
#* 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name = "GROUCHO" WHERE first_name = "HARPO" AND last_name = "WILLIAMS";
#SELECT first_name, last_name FROM actor WHERE last_name = "Williams";
#* 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE sakila.address;
/*'CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
`address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8';
*/
#  * Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>

#* 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT first_name, last_name, address from staff s
INNER JOIN address a ON s.address_id = a.address_id;
SELECT * FROM staff s;
#* 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT s.staff_id, first_namee, last_name, SUM(amount) AS "Total amount rung up" FROM staff s
INNER JOIN payment p ON s.staff_id = p.staff_id
GROUP BY s.staff_id;
SELECT * FROM staff s;
#* 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT f.title, COUNT(fa.actor_id) AS "Number of actors in film" FROM film f
INNER JOIN film_actor fa ON f.film_id = fa.film_id
GROUP BY f.film_id;
#* 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT f.title, COUNT(i.inventory_id) as "Number of Hunchback Impossibles in inverntory" FROM film f
INNER JOIN inventory i ON f.film_id = i.film_id
GROUP BY f.film_id HAVING title = "Hunchback Impossible";

#* 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.last_name, c.first_name, SUM(p.amount) "Total paid by customer" FROM customer c
INNER JOIN payment p ON c.customer_id = p.customer_id
GROUP BY p.customer_id
ORDER BY last_name, first_name;
#  ```
#  	![Total amount paid](Images/total_payment.png)
#  ```

#* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title FROM film
WHERE language_id IN (SELECT language_id FROM language WHERE name = "English")
AND (title LIKE "K%") OR (title LIKE "Q%");
#* 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name FROM actor
WHERE actor_id IN (SELECT actor_id FROM film_actor WHERE film_id IN
	(SELECT film_id FROM film WHERE title = "Alone Trip")
);
#* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT c.first_name, c.last_name, c.email, co.country FROM customer c
LEFT JOIN address a ON c.address_id = a.address_id
LEFT JOIN city ci ON ci.city_id = a.city_id
LEFT JOIN country co ON co.country_id = ci.country_id
WHERE country = "Canada";
#* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT * FROM film WHERE film_id IN
(SELECT film_id from film_category WHERE category_id IN
(SELECT category_id FROM category WHERE name = "family"
)
);

#* 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_5_genres AS
SELECT c.name, sum(p.amount) as "Revenue per Category" FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
GROUP BY name
ORDER BY SUM(p.amount) DESC
LIMIT 5;
#* 8b. How would you display the view that you created in 8a?
SELECT * FROM top_5_genres;
#* 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_5_genres;
## Appendix: List of Tables in the Sakila DB

#* A schema is also available as `sakila_schema.svg`. Open it with a browser to view.

#```sql
#	'actor'
#	'actor_info'
#	'address'
#	'category'
#	'city'
#	'country'
#	'customer'
#	'customer_list'
#	'film'
#	'film_actor'
#	'film_category'
#	'film_list'
#	'film_text'
#	'inventory'
##	'nicer_but_slower_film_list'
#	'payment'
#	'rental'
#	'sales_by_film_category'
#	'sales_by_store'
#	'staff'
#	'staff_list'
#	'store'
#```

## Uploading Homework

#* To submit this homework using BootCampSpot:

#  * Create a GitHub repository.
#  * Upload your .sql file with the completed queries.
#  * Submit a link to your GitHub repo through BootCampSpot.
