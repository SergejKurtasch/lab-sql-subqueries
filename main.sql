-- Write SQL queries to perform the following tasks using the Sakila database:
USE sakila;

-- Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT
	count(*)
from inventory
where film_id in 
	( SELECT film_id
	FROM film
    where title = "Hunchback Impossible" );
    
-- List all films whose length is longer than the average length of all the films in the Sakila database.
select * from film
where length > (
select avg(length) from film
);

-- Use a subquery to display all actors who appear in the film "Alone Trip".
select actor_id, first_name, last_name
from actor
where actor_id in (	
    select actor_id from film_actor
    where film_id =
		(select film_id from film
		where title = "Alone Trip"
		)
	);

-- Bonus:

-- Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.

select film_id, title 
from film
where film_id in
	(select film_id from film_category
	where category_id = 
		(select category_id
		from category
		where name = "family"
		)
	);
-- Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.

select first_name, last_name, email
from customer
where address_id in
	(   select a.address_id 
		from address a
		join city ct
		using (city_id)
		join country cntr
		using (country_id)
		where cntr.country = "Canada"
    );

-- Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.

select title from film f
join film_actor fa
using (film_id)
join 
	(select 
		actor_id
        ,count(film_id) as num_films
	from film_actor
	group by (actor_id)
	order by num_films DESC
	limit 1
    ) as sub
on fa.actor_id = sub.actor_id;


-- Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.

select title
from film
where film_id in
	(select film_id
	from inventory
	where inventory_id in
		(select inventory_id from rental
		join 
			(select 
				customer_id
				,sum(amount) as total_amount
			from payment
			group by (customer_id)
			order by total_amount desc
			limit 1
			) as sub_pay
		using (customer_id)
		)
	);



    
-- Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.


select 
	 customer_id
	 , sum(amount) as total_amount_spent
from payment
group by (customer_id)

having total_amount > 
	(	
	select avg(total_amount) AS avg_total_amount
	from
	(
		select 
			sum(amount) as total_amount
		from payment
		group by (customer_id)
	) as revenue_pro_customer
	)
order by total_amount;


