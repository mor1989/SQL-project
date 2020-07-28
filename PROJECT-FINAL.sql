/*QUERY 1- HIGH PAY CUSTOMERS-First Slide*/

SELECT customer_name, month, pay_per_month, num_times,
       pay_per_month-(LAG (pay_per_month) OVER (PARTITION BY customer_name ORDER BY month)) AS pay_difference
FROM  (
        SELECT  c.first_name || c.last_name AS customer_name, DATE_TRUNC ('month', p.payment_date) as month,
        SUM(p.amount) pay_per_month, COUNT(p.payment_date) num_times
        FROM payment p
        JOIN customer c
        ON c.customer_id=p.customer_id
        JOIN
                (SELECT customer_id customer, SUM(amount) amount_paid
                  FROM payment
                  GROUP BY 1
                  ORDER BY 2 DESC
                  LIMIT 10)t1
        ON t1.customer=c.customer_id
        GROUP BY 1, 2
        ORDER BY 1, 2
      )t2
  ORDER BY 1;


/*QUERY 2- CATEGORY QUARTILE-Second slide*/

SELECT category, standard_quartile, COUNT(film_title)
FROM            (
              SELECT f.title film_title, c.name category, f.rental_duration rental_duration,
              NTILE(4) OVER (ORDER BY f.rental_duration) standard_quartile
              FROM film f
              JOIN film_category FC
              ON f.film_id=fc.film_id
              JOIN category c
              ON c.category_id=fc.category_id
             )t1
  WHERE category IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
  GROUP BY 1, 2
  ORDER BY 1, 2;

  /*QUERY 3- FILM-CATOGERY-LEVEL-Third Slide)*/

  WITH t1 AS  (
              SELECT DISTINCT i.film_id id, f.title film, fa.actor_id actor, COUNT(r.rental_id) rent_count,
              COUNT(i.film_id) OVER (PARTITION BY fa.actor_id ORDER BY fa.actor_id) actor_count
              FROM rental r
              JOIN inventory i
              ON i.inventory_id=r.inventory_id
              JOIN film_actor fa
              ON fa.film_id=i.film_id
              JOIN film f
              ON f.film_id=fa.film_id
              GROUP BY 1, 2, 3
              ORDER BY 1
              )

  SELECT film, c.name category, rent_count,
  NTILE (3) OVER (ORDER BY MAX(actor_count)) AS actor_popular
  FROM t1
  JOIN film_category fc
  ON t1.id=fc.film_id
  JOIN category c
  ON fc.category_id=c.category_id
  GROUP BY 1, 2, 3
  ORDER BY 2;

  /*QUERY 4-RENTAL ORDERS- Forth slide*/

SELECT s.store_id, DATE_PART('year', r.rental_date) AS year, DATE_PART('month', r.rental_date) AS month,
COUNT(r.rental_id) rental_orders
FROM store s
JOIN staff st
ON st.store_id=s.store_id
JOIN rental r
ON st.staff_id=r.staff_id
GROUP BY 1 ,2, 3
ORDER BY 4 DESC;
