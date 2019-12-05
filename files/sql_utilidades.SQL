-- TIPOS DE DATOS

--- Numéricos

----- Seriales
CREATE SEQUENCE s START 1;
CREATE TABLE stuff(id bigint DEFAULT nextval('s') PRIMARY KEY, name text);
INSERT INTO stuff (name) VALUES ('Primero');
INSERT INTO stuff (name) VALUES ('Segundo');
SELECT nextval('s');
INSERT INTO stuff (name) VALUES ('Tercer');
SELECT * FROM stuff;

CREATE TABLE stuff2(id serial PRIMARY KEY, name TEXT);

--- Series
SELECT x FROM generate_series(1,51,13) As x;

--- Strings

----- Truncar
SELECT
lpad('ab', 4, '0') As ab_lpad,
rpad('ab', 4, '0') As ab_rpad,
lpad('abcde', 4, '0') As ab_lpad_trunc;

----- Trimming
SELECT repeat(' ', 4) || i || repeat(' ', 4) As a, '0' || i As i
	FROM generate_series(0, 200, 50) As i;
	
SELECT
	a As a_before, trim(a) As a_trim, rtrim(a) As a_rt,
	i As i_before, ltrim(i, '0') As i_lt_0,
	rtrim(i, '0') As i_rt_0, trim(i, '0') As i_t_0
FROM (
	SELECT repeat(' ', 4) || i || repeat(' ', 4) As a, '0' || i As i
	FROM generate_series(0, 200, 50) As i
) As x;

----- Partir strins en arrays
SELECT split_part('abc.123.z45','.',2) As x;

SELECT unnest(string_to_array('abc.123.z45', '.')) As x;

----- Expresiones regulares
SELECT regexp_replace(
'6197306254',
'([0-9]{3})([0-9]{3})([0-9]{4})',
E'\(\\1\) \\2-\\3'
) As x;

SELECT address FROM address;
SELECT address, regexp_replace(address, '([0-9]+) +(.*)', E'\\2 # \\1') FROM address;

--- Temporales

SELECT '2012-03-11 3:10 AM America/Los_Angeles'::timestamptz - '2012-03-11 1:50 AM America/Los_Angeles'::timestamptz;
SELECT '2012-03-11 3:10 AM'::timestamp - '2012-03-11 1:50 AM'::timestamp;

SELECT '2019-12-05 10:00 PM America/Bogota'::timestamptz AT TIME ZONE 'Europe/Paris';
SELECT current_timestamp::timestamptz AT TIME ZONE 'Europe/Paris';
SELECT now() AT TIME ZONE 'Europe/Paris';

----- Operadores
--Adicion en fecha
SELECT '2012-02-10 11:00 PM'::timestamp + interval '1 hour';
--Adicion en intervalo
SELECT '23 hours 20 minutes'::interval + '1 hour'::interval;
--Overlaps
SELECT
('2019-12-16 10:00 AM'::timestamp, '2019-12-24 2:00 PM'::timestamp)
OVERLAPS
('2019-12-09 11:00 AM'::timestamp,'2019-12-10 2:00 PM'::timestamp) AS x;

-- Generate series
SELECT dt::date as inicio_mes, (dt + interval '1 month' - interval '1 day')::date As fin_mes
FROM generate_series('2019-1-1', '2019-12-1', interval '1 month') As dt;

-- Extrayendo partes
SELECT dt, date_part('hour',dt) As hr, to_char(dt,'HH12:MI AM') As mn
FROM generate_series(
'2012-03-11 12:30 AM',
'2012-03-11 3:00 AM',
interval '15 minutes') as dt;
) As dt;

--- Rangos
SELECT '[2013-01-05,2013-08-13]'::daterange;
SELECT '(2013-01-05,2013-08-13]'::daterange;
SELECT '(0,)'::int8range;
SELECT '(2013-01-05 10:00,2013-08-13 14:00]'::tsrange;

--Tablas con rangos
DROP TABLE employment;
CREATE TABLE employment (id serial PRIMARY KEY, 
						 employee varchar(20),
						 period daterange);
						 
CREATE INDEX ix_employment_period ON employment USING gist (period);

INSERT INTO employment (employee,period)
VALUES
	('Alex','[2012-04-24, infinity)'::daterange),
	('Sonia','[2011-04-24, 2012-06-01)'::daterange),
	('Leo','[2012-06-20, 2013-04-20)'::daterange),
	('Regina','[2012-06-20, 2013-04-20)'::daterange);
	
SELECT
	e1.employee,
	string_agg(DISTINCT e2.employee, ', ' ORDER BY e2.employee) As colleagues
FROM 
	employment As e1 INNER JOIN employment As e2
	ON e1.period && e2.period
WHERE e1.employee <> e2.employee
GROUP BY e1.employee;

SELECT employee FROM employment WHERE period @> current_date GROUP BY employee;

-- JSON

DROP TABLE persons;
CREATE TABLE persons (id serial PRIMARY KEY, person json);

INSERT INTO persons (person)
VALUES (
'{ 
   "name":"Sonia",
   "spouse":{ 
      "name":"Alex",
      "parents":{ 
         "father":"Rafael",
         "mother":"Ofelia"
      },
      "phones":[ 
         { 
            "type":"work",
            "number":"619-722-6719"
         },
         { 
            "type":"cell",
            "number":"619-852-5083"
         }
      ]
   },
   "children":[ 
      { 
         "name":"Brandon",
         "gender":"M"
      },
      { 
         "name":"Azaleah",
         "girl":true,
         "phones":[ 

         ]
      }
   ]
}'
);

-- Queries
SELECT person->'name' FROM persons;
SELECT person->'spouse'->'parents'->'father' FROM persons;

-- Path array
SELECT person#>array['spouse','parents','father'] FROM persons;

SELECT person->'children'->0->'name' FROM persons
SELECT person#>array['children','0','name'] FROM persons; -- JSON Primitivas
SELECT person#>>array['children','0','name'] FROM persons; -- Text Object

SELECT json_array_elements(person->'children')->>'name' As name FROM persons;

SELECT json_array_elements(person->'spouse'->'phones')->>'number' As phone_number FROM persons;




