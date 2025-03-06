-- SPRINT 4 -- Creació de base de dades
-- Juanjo MONTERO


	CREATE SCHEMA `sprint4` ;
	USE sprint4;


-- OPT_LOCAL_INFILE=1 -- es configura la connexió al servidor perquè permeti entrada local
-- The command sets the local-infile option to ON, making it possible to run a LOAD DATA statement
-- that includes the LOCAL option. It appears on the connection’s Advanced tab. This setting applies
-- only to this user’s connections in Workbench. Other connections must be configured individually.
	SET GLOBAL local_infile = 1; -- indica al servidor que es permet l'entrada des de fitxers locals


-- NIVELL 1 - Exercici 1 ----------------------------------------------------------------------------------
-- Creació de les taules, en estrella, amb transactions al centre

	CREATE TABLE IF NOT EXISTS users (
		id INT,
		name VARCHAR(50),
		surname VARCHAR(50),
		phone VARCHAR(25),
		email VARCHAR(70),
		birth_date VARCHAR(30),
		country VARCHAR(50),
		city VARCHAR(50),
		postal_code VARCHAR(50),
		address VARCHAR(100),
		PRIMARY KEY (id)
	);

	CREATE TABLE IF NOT EXISTS companies (
		company_id VARCHAR(10),
		company_name VARCHAR(100),
		phone VARCHAR(25),
		email VARCHAR(70),
		country VARCHAR(50),
		website VARCHAR(150),
		PRIMARY KEY (company_id)
	);

	CREATE TABLE IF NOT EXISTS credit_card (
		id VARCHAR(10),
		user_id INT,
		iban VARCHAR(34),
		pan VARCHAR(30),
		pin VARCHAR(4),
		cvv VARCHAR(3),
		track1 VARCHAR(100),
		track2 VARCHAR(100),
		expiring_date VARCHAR(20),
		PRIMARY KEY (id)
	);

	CREATE TABLE IF NOT EXISTS transactions (
		id VARCHAR(40),
		card_id VARCHAR(10),
		business_id VARCHAR(10),
		timestamp TIMESTAMP,
		amount DECIMAL(10,2),
		declined TINYINT,
		product_ids VARCHAR(100),
		user_id INT,
		lat FLOAT,
		longitude FLOAT,
		PRIMARY KEY (id),
		FOREIGN KEY (card_id) REFERENCES credit_card(id),
		FOREIGN KEY (business_id) REFERENCES companies(company_id),
		FOREIGN KEY (user_id) REFERENCES users(id)
	);

	-- carreguem les dades des del respectius CSVs
    LOAD DATA LOCAL INFILE "/home/soliton/Desktop/ITAcademy/SPRINTS/03-10 Sprint 4/csv/users_ca.csv"
	INTO TABLE users -- usuaris de Canada
	FIELDS TERMINATED BY ',' -- indica el separador de camp
	ENCLOSED BY '"' -- com s'acoten les cadenes de text
	LINES TERMINATED BY '\r\n' -- Carriage Return (CR) i Line Feed (LF)
	IGNORE 1 LINES; -- ignora la primera línia que conté el nom de columna

	LOAD DATA LOCAL INFILE "/home/soliton/Desktop/ITAcademy/SPRINTS/03-10 Sprint 4/csv/users_uk.csv"
	INTO TABLE users -- usuaris Regne Unit
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\r\n'
	IGNORE 1 LINES;

	LOAD DATA LOCAL INFILE "/home/soliton/Desktop/ITAcademy/SPRINTS/03-10 Sprint 4/csv/users_usa.csv"
	INTO TABLE users -- usuaris Estats Units
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\r\n'
	IGNORE 1 LINES;

	LOAD DATA LOCAL INFILE "/home/soliton/Desktop/ITAcademy/SPRINTS/03-10 Sprint 4/csv/companies.csv"
	INTO TABLE companies
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\r\n'
	IGNORE 1 LINES;

	LOAD DATA LOCAL INFILE "/home/soliton/Desktop/ITAcademy/SPRINTS/03-10 Sprint 4/csv/credit_cards.csv"
	INTO TABLE credit_card
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n' -- no conté el \r (CARRIAGE RETURN)
	IGNORE 1 LINES;

	LOAD DATA LOCAL INFILE "/home/soliton/Desktop/ITAcademy/SPRINTS/03-10 Sprint 4/csv/transactions.csv"
	INTO TABLE transactions
	FIELDS TERMINATED BY ';' -- utilitza punt i coma com a separador
	ENCLOSED BY '"'
	LINES TERMINATED BY '\r\n'
	IGNORE 1 LINES;
   
	-- Es modifiquen les columnes users.birth_date i credit_card.expiring_date
	-- per tal que tinguin el datatype DATE i es puguin ordenar o comparar
	SET SQL_SAFE_UPDATES = 0; -- es modifiquen totes les files, sense cap filtre WHERE

	UPDATE users
	SET birth_date = STR_TO_DATE(birth_date, '%M %d, %Y'); -- "Dec 31, 99" a 1999-12-31

	UPDATE credit_card
	SET expiring_date = STR_TO_DATE(expiring_date, '%m/%d/%y'); -- "12/31/1999" a 1999-12-31

	SET SQL_SAFE_UPDATES = 1;

	ALTER TABLE users
	MODIFY birth_date DATE; 
	ALTER TABLE credit_card
	MODIFY expiring_date DATE; 
    
    
-- Exercici 1.b Es mostren els usuaris que tenen més de 30 transaccions
	SELECT 
		users.id,
		users.name,
		users.surname
	FROM users
	wHERE users.id IN (
					SELECT 
						user_id
					FROM transactions
			        WHERE transactions.declined = 0
					GROUP BY transactions.user_id
					HAVING COUNT(transactions.id) > 30
					);


-- NIVELL 1 - Exercici 2 ----------------------------------------------------------------------------------
-- Preu mitjà de transacció per IBAN de l'empresa Donec Ltd

	SELECT 
		companies.company_name AS nom_companyia,
		credit_card.iban AS IBAN,
		ROUND(AVG(transactions.amount),2) AS import_mitja_transaccio_en_euros        
	FROM transactions
	JOIN credit_card ON transactions.card_id = credit_card.id
	JOIN companies ON transactions.business_id = companies.company_id
	WHERE
		companies.company_name = 'Donec Ltd'
        AND transactions.declined = 0
	GROUP BY nom_companyia, IBAN;


-- NIVELL 2 - Exercici 1 ----------------------------------------------------------------------------------
-- Estat de les targetes de crèdit en base a les transaccions rebutjades en les últimes 3 transaccions
 

	-- Opció fent servir vistes. Aquesta opció és la recomanada ja que les vistes es creen en base a 
	-- les dades actualitzades cada vegada que es criden.
	CREATE VIEW vista_credit_card_status AS
		SELECT 
			card_id AS "ID_targeta",
			IF(SUM(declined) = 3, "Inactiva", "Activa") AS "Estat_targeta",
			SUM(declined) AS "Errors_3_ultims_usos"
		FROM
			(
			SELECT 
				timestamp,
				declined,
				card_id,
				RANK() OVER(partition by card_id order by timestamp desc) AS ranking
			FROM transactions
			) AS last_card_uses_ranked
		WHERE ranking BETWEEN 1 AND 3
		GROUP by card_id;

	-- Opció amb taula
	-- CREATE TABLE credit_card_status AS
	-- SELECT 
	--	card_id AS "ID_targeta",
	--	IF(SUM(declined) = 3, "Inactiva", "Activa") AS "Estat_targeta",
	--	SUM(declined) AS "Errors_3_ultims_usos"
	-- FROM
	--	(
	--	SELECT 
	--		timestamp,
	--		declined,
	--		card_id,
	--		RANK() OVER(partition BY card_id ORDER BY timestamp DESC) AS ranking
	--	FROM transactions
	--	) AS last_card_uses_ranked
	-- WHERE ranking BETWEEN 1 AND 3
	-- GROUP BY card_id;
        

	-- Per mostrar el total de targetes actives
	SELECT COUNT(ID_targeta) AS targetes_actives
	FROM vista_credit_card_status
	WHERE Estat_targeta = "Activa";



-- NIVELL 3 - Exercici 1 ----------------------------------------------------------------------------------
-- Crear una taula per unir transaccions i productes

	-- es crea la taula products
	CREATE TABLE IF NOT EXISTS products (
		id INT,
		product_name VARCHAR(200),
		price VARCHAR(20),
		colour VARCHAR(7),
		weight FLOAT,
		warehouse_id VARCHAR(10),
		PRIMARY KEY (id)
	);

	-- s'importen les dades des de products.csv
    LOAD DATA LOCAL INFILE "/home/soliton/Desktop/ITAcademy/SPRINTS/03-10 Sprint 4/csv/products.csv"
	INTO TABLE products
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 LINES;

	-- es crea la tula intermitja transaction_product que mitja la 
    -- relació m:n entre transactions i products
	CREATE TABLE IF NOT EXISTS transaction_product AS
		SELECT 
			transactions.id as transaction_id,  
			products.id as product_id
		FROM transactions
		CROSS JOIN products
		WHERE 
			FIND_IN_SET(products.id , REPLACE(product_ids, ", ", ","))  > 0
	        AND transactions.declined = 0;

	ALTER TABLE transaction_product
	ADD FOREIGN KEY (transaction_id) REFERENCES transactions (id);
	ALTER TABLE transaction_product
	ADD FOREIGN KEY (product_id) REFERENCES products (id);


-- unitats venudes de cada producte
	SELECT
		products.id AS id_del_producte,
        COUNT(IF(transactions.declined = 0, transactions.id, NULL)) AS unitats_venudes,
		products.product_name AS nom_del_producte
	FROM products
	LEFT JOIN transaction_product ON products.id = transaction_product.product_id
	LEFT JOIN transactions ON transactions.id = transaction_product.transaction_id
	GROUP BY products.id
	ORDER BY products.id;
    
    SET GLOBAL local_infile = 0;

