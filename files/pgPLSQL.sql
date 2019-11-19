SELECT version();

/*
DECLARACIÓN DE FUNCIONES Y PROCEDIMIENTOS
*/

-- FUNCIÓN
CREATE FUNCTION test_function_tx() RETURNS VOID AS $$
BEGIN
    CREATE TABLE a (id int);
    CREATE INDEX a_id_idx ON a(id);
    SELECT 1/0;
END;
$$ LANGUAGE plpgsql ;

-- PROCEDIMIENTO
CREATE PROCEDURE test_procedure_tx() AS $$
BEGIN
    CREATE TABLE a (id int);
    COMMIT;
    CREATE INDEX a_id_idx ON a(id);
    SELECT 1/0;
END;
$$ LANGUAGE plpgsql ;

/*
LLAMADO DE FUNCIONES Y PROCEDIMIENTOS
*/

-- FUNCIÓN
SELECT test_function_tx();
TABLE a;

-- PROCEDIMIENTO
CALL test_procedure_tx();
TABLE a;

/*
 Mas procedimientos
 */
CREATE TABLE test_table (un_numero NUMERIC);

CREATE PROCEDURE insert_data(a integer, b integer) AS $$
INSERT INTO test_table VALUES (a);
INSERT INTO test_table VALUES (b);
$$  LANGUAGE SQL;


TABLE test_table;
CALL insert_data(1, 2);
TABLE test_table;

/*
 Más funciones
 */

CREATE FUNCTION greetingsFunction() RETURNS text AS $$
SELECT 'Hola mundo de funciones';
$$ LANGUAGE SQL;

SELECT greetingsFunction() AS saludo;

CREATE FUNCTION myIncrementFunction(variable int) RETURNS int AS $$
BEGIN
    RETURN variable + 1;
END;
$$ LANGUAGE plpgsql;

SELECT myIncrementFunction(10);

DROP FUNCTION myIncrementFunction(int);

/*
 Declaración de variables
 */

CREATE FUNCTION test_vardeclarations() RETURNS TEXT AS $$
DECLARE
    counter    INTEGER := 1;
    first_name VARCHAR(50) := 'John';
    last_name  VARCHAR(50) := 'Doe';
    payment    NUMERIC(11,2) := 20.5;
BEGIN
    RETURN CONCAT(first_name, ' ', last_name,' recibió ',payment);
END
$$ LANGUAGE plpgsql;

SELECT test_vardeclarations();

/*
 Ejecutar código pgPL/SQL sin función ni procedimiento
 */

DO $$
    DECLARE
        number_of_accounts INTEGER:=0;
    BEGIN
        number_of_accounts:= (SELECT COUNT(*) FROM actor)::INTEGER;
        RAISE NOTICE 'number_of actors: %', number_of_accounts;
    END;$$
LANGUAGE plpgsql;

/*
 Variable tipo record
 */

DO $$
    DECLARE
        test record;
    BEGIN
        test = ROW (1,'hello', 3.14);
        RAISE notice '%', test;
    END;
$$ LANGUAGE plpgsql;

/*
 Condicionales
 */

-- IF ELSE END

CREATE FUNCTION cast_rank_to_text (rank int) RETURNS TEXT AS $$
DECLARE
    rank ALIAS FOR $1;
    rank_result TEXT;
BEGIN
    IF rank = 5 THEN rank_result = 'Excellent';
    ELSIF rank = 4 THEN rank_result = 'Very Good';
    ELSIF rank = 3 THEN rank_result = 'Good';
    ELSIF rank = 2 THEN rank_result ='Fair';
    ELSIF rank = 1 THEN rank_result ='Poor';
    ELSE rank_result ='No such rank';
    END IF;
    RETURN rank_result;
END;
$$ Language plpgsql;

SELECT cast_rank_to_text(4);
SELECT n FROM generate_series(1,6) as n;
SELECT n, cast_rank_to_text(n) FROM generate_series(1,6) as n;

-- CASE

CREATE FUNCTION cast_rank_to_text_2 (rank int) RETURNS TEXT AS $$
DECLARE
    rank ALIAS FOR $1;
    rank_result TEXT;
BEGIN
    CASE
        WHEN rank=5 THEN rank_result = 'Excellent';
        WHEN rank=4 THEN rank_result = 'Very Good';
        WHEN rank=3 THEN rank_result = 'Good';
        WHEN rank=2 THEN rank_result ='Fair';
        WHEN rank=1 THEN rank_result ='Poor';
        WHEN rank IS NULL THEN RAISE EXCEPTION 'Rank should be not NULL';
        ELSE rank_result ='No such rank';
        END CASE;
    RETURN rank_result;
END;
$$ Language plpgsql;

SELECT n, cast_rank_to_text_2(n) FROM generate_series(1,6) as n;

/*
 LOOPS
 */

CREATE FUNCTION fibonacci (n INTEGER) RETURNS INTEGER AS $$
DECLARE
    counter INTEGER := 0 ;
    i INTEGER := 0 ;
    j INTEGER := 1 ;
BEGIN

    IF (n < 1) THEN
        RETURN 0 ;
    END IF;

    LOOP
        EXIT WHEN counter = n ;
        counter := counter + 1 ;
        SELECT j, i + j INTO i, j ;
    END LOOP ;

    RETURN i ;
END ;
$$ LANGUAGE plpgsql;

-- WHILE

DO $$
DECLARE
    first_day_in_month date := date_trunc('month', current_date)::date;
    last_day_in_month date := (date_trunc('month', current_date) + INTERVAL '1 MONTH - 1 day')::date;
    counter date = first_day_in_month;
BEGIN
    WHILE (counter <= last_day_in_month) LOOP
            RAISE notice '%', counter;
            counter := counter + interval '1 day';
        END LOOP;
END;
$$ LANGUAGE plpgsql;