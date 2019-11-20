-- FOR en ARREGLO

DO $$
    BEGIN
        FOR j IN REVERSE -1 .. -10 BY 2 LOOP
            Raise notice '%', j;
        END LOOP;
    END;
$$ LANGUAGE plpgsql;

-- FOR EN RESULT SET

DO $$
    DECLARE
        database RECORD;
    BEGIN
        FOR database IN SELECT * FROM category LOOP
            RAISE notice '%', database;
        END LOOP;
    END;
$$;

-- EJEMPLO FUNCIÓN VOID

SELECT pg_sleep(3);

-- RETORNANDO RECORD DESDE SQL

CREATE OR REPLACE FUNCTION get_actor (nactor_id INT) RETURNS RECORD AS $$
	SELECT * FROM actor WHERE actor_id = $1;
$$ LANGUAGE SQL;

SELECT get_actor(1);

-- RETORNANDO RECORD DESDE plpgsql

CREATE OR REPLACE FUNCTION get_actor_2 (nactor_id INT) RETURNS RECORD AS $$
	DECLARE
		resultado RECORD;
	BEGIN
		SELECT * INTO resultado FROM actor WHERE actor_id = $1;
		RETURN resultado;
	END;
$$ LANGUAGE plpgsql;

SELECT get_actor_2(1);

-- RETORNANDO RECORD DESDE plpgsql (Selectivo)

CREATE OR REPLACE FUNCTION get_actor_3 (nactor_id INT) RETURNS RECORD AS $$
	DECLARE
		resultado RECORD;
	BEGIN
		SELECT actor_id, last_name, first_name INTO resultado FROM actor WHERE actor_id = $1;
		RETURN resultado;
	END;
$$ LANGUAGE plpgsql;

SELECT get_actor_3(1);

-- RETORNANDO JSON DESDE SQL

CREATE OR REPLACE FUNCTION get_actor_in_json (nactor_id INT) RETURNS JSON AS $$
SELECT row_to_json(actor) FROM actor WHERE actor_id = $1;
$$ LANGUAGE SQL;

SELECT get_actor_in_json(1);

-- RETORNANDO JSON DESDE plpgsql

CREATE OR REPLACE FUNCTION get_actor_in_json_2 (nactor_id INT) RETURNS JSON AS $$
	BEGIN
		RETURN (SELECT row_to_json(actor) FROM actor WHERE actor_id = $1);
	END;
$$ LANGUAGE plpgsql;

SELECT get_actor_in_json_2(1);

-- RETORNANDO MULTIPLES FILAS

-- SQL

CREATE OR REPLACE FUNCTION movie_by_type(type_name TEXT) RETURNS SETOF film AS $$
SELECT fi.*
FROM film fi 
JOIN film_category fc ON fc.film_id = fi.film_id
JOIN category ca ON ca.category_id = fc.category_id
WHERE ca.name = $1;
$$ LANGUAGE SQL;

SELECT movie_by_type('Horror');

-- plpgsql

CREATE OR REPLACE FUNCTION movie_by_type_2(type_name TEXT) 
RETURNS SETOF film AS $$
	BEGIN
		RETURN QUERY SELECT fi.* FROM film fi 
						JOIN film_category fc ON fc.film_id = fi.film_id
						JOIN category ca ON ca.category_id = fc.category_id
						WHERE ca.name = $1;
	END;
$$ LANGUAGE plpgsql;

SELECT movie_by_type_2('Horror');

-- si no tenemos tipo de dato TABLA definido

--SQL
CREATE OR REPLACE FUNCTION movie_by_type_3(type_name TEXT)
RETURNS TABLE (film_name TEXT , film_lenght SMALLINT) AS $$
SELECT fi.title, fi.length
FROM film fi 
JOIN film_category fc ON fc.film_id = fi.film_id
JOIN category ca ON ca.category_id = fc.category_id
WHERE ca.name = $1;
$$ LANGUAGE SQL;

SELECT movie_by_type_3('Horror');

--plpgsql
CREATE OR REPLACE FUNCTION movie_by_type_4(type_name TEXT)
RETURNS TABLE (film_name VARCHAR(255) , film_lenght SMALLINT) AS $$
	BEGIN
		RETURN QUERY SELECT fi.title, fi.length FROM film fi 
						JOIN film_category fc ON fc.film_id = fi.film_id
						JOIN category ca ON ca.category_id = fc.category_id
						WHERE ca.name = $1;
	END;
$$ LANGUAGE plpgsql;

SELECT movie_by_type_4('Horror');

/* 
SQL DINAMICO
*/

CREATE OR REPLACE FUNCTION get_actors (predicate TEXT)
RETURNS SETOF actor AS
$$
	BEGIN
		RETURN QUERY EXECUTE 'SELECT * FROM actor WHERE ' || predicate;
	END;
$$ LANGUAGE plpgsql;

SELECT get_actors('true');
