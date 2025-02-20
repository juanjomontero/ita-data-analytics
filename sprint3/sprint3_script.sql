-- SPRINT 3 -- Manipulació de taules
-- Juanjo MONTERO



-- NIVELL 1 - Exercici 1 ----------------------------------------------------------------------------------
-- Creació de la taula credit_card

	CREATE TABLE IF NOT EXISTS transactions.credit_card (
		    id VARCHAR(15) PRIMARY KEY,
		    iban VARCHAR(50),
		    pin VARCHAR(4),
		    pan VARCHAR(25),
		    cvv INT,
		    expiring_date VARCHAR(20)
		    );

	-- després de poblar la taula credit_card amb el contingut de datos_introducir_credit.sql
		
	ALTER TABLE transaction
	ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);



-- NIVELL 1 - Exercici 2 ----------------------------------------------------------------------------------
-- modificació del IBAN per la tarja amb codi Ccu-2938

	UPDATE credit_card
	SET iban = "R323456312213576817699999"
	WHERE id = "Ccu-2938";



-- NIVELL 1 - Exercici 3 ----------------------------------------------------------------------------------
-- Insertar una transacció nova a la taula transaction

	SET foreign_key_checks = 0; -- es deixen de comprovar les claus forànies, ja que s'introdueixen dades a columnes
								-- designades com a foreign keys sense una correspondència amb primary keys
								-- (p.e. no existeixen la companyia b-9999 o la tarja CCu-9999)

	INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
	VALUES ("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999", "b-9999", 9999, 829.999, -117.999, 111.11, 0 );

	SET foreign_key_checks = 1;



-- NIVELL 1 - Exercici 4 ----------------------------------------------------------------------------------
-- Eliminació de la columna pan de la taula credit_card

	ALTER TABLE credit_card
	DROP COLUMN pan;




-- NIVELL 2 - Exercici 1 ----------------------------------------------------------------------------------
-- Eliminació del registre amb id de transacció 02C6201E-D90A-1859-B4EE-88D2986D3B02

	DELETE FROM transaction
	WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';



-- NIVELL 2 - Exercici 2 ----------------------------------------------------------------------------------
-- Creació de la vista VistaMarketing

	CREATE VIEW VistaMarketing AS
		SELECT 
			company_name AS "Companyia",
			phone AS "Telèfon",
			country AS "País",
			ROUND(AVG(COALESCE(amount,0)),2) AS "Mitjana de compres" -- tracta els NULLs com 0 per incloure'ls en la mitjana
		FROM transaction
		LEFT JOIN company ON company.id = transaction.company_id
        WHERE transaction.declined = 0 -- no es tenen en consideració les transactions rebujtades (declined = 1)
		GROUP BY 1, 2, 3
		ORDER BY 4 DESC;



-- NIVELL 2 - Exercici 3 ----------------------------------------------------------------------------------
-- Filtrat de VistaMarketing per mostrar només empreses amb seu a Alemanya ("Germany")

	SELECT * FROM transactions.VistaMarketing
	WHERE `País` = "Germany";



-- NIVELL 3 - Exercici 1 ----------------------------------------------------------------------------------
-- Modificació de l'esquema per tal que s'ajusti al diagrama donat

	ALTER TABLE credit_card
	MODIFY COLUMN id VARCHAR(20); 

	ALTER TABLE user
	RENAME TO data_user;

	ALTER TABLE data_user 
	RENAME COLUMN email TO personal_email;

	ALTER TABLE company
	DROP COLUMN website;

	ALTER TABLE credit_card
	ADD fecha_actual DATE;
	
	SET foreign_key_checks = 0;
	ALTER TABLE transaction
	ADD FOREIGN KEY (user_id) REFERENCES data_user(id);
	SET foreign_key_checks = 1;



-- NIVELL 3 - Exercici 2 ----------------------------------------------------------------------------------
-- Creació de la vista InformeTecnico

	CREATE VIEW InformeTecnico AS
	SELECT 
		transaction.id AS "Identificador de Transacció",
		data_user.name AS "Nom",
		data_user.surname AS "Cognom",
		credit_card.iban AS "IBAN",
		company.company_name AS "Companyia"
	FROM transaction
	JOIN data_user ON transaction.user_id = data_user.id
	JOIN credit_card ON transaction.credit_card_id = credit_card.id
	JOIN company ON transaction.company_id = company.id
	ORDER BY 1 DESC;
		

