-- SPRINT 2 -- NOCIONS BÀSIQUES DE SQL
-- Juanjo MONTERO



-- Nivell 1 Ex2 ------------------------------------------------------------------------------
-- Llista de països que fan compres: 

		SELECT DISTINCT(company.country) AS "LListat de països que fan compres"
		FROM transaction
		INNER JOIN company ON transaction.company_id = company.id
		ORDER BY 1;



-- Nivell 1 Ex2 ------------------------------------------------------------------------------
-- Des de quants països es fan compres?

		SELECT COUNT(DISTINCT(company.country)) AS "Desde quants països es fan compres?"
		FROM transaction
		INNER JOIN company ON transaction.company_id = company.id;



-- Nivell 1 Ex2 ------------------------------------------------------------------------------
-- Identifica la companyia amb la mitjana més gran de vendes

		SELECT 
			company_id,
			company_name,
			round(avg(amount),2) AS "Mitjana de vendes",
			count(transaction.id) AS "Número de transaccions",
			sum(amount) AS "Total vendes"
		FROM transaction
		INNER JOIN company ON transaction.company_id = company.id
		GROUP BY company_id
		ORDER BY 3 DESC
		LIMIT 1;



-- Nivell 1 Ex3 ------------------------------------------------------------------------------
-- Totes les transaccions amb païs Alemanya (118 resultats)

		SELECT *
		FROM transaction
		WHERE company_id IN (
				            SELECT id
				            FROM company
				            WHERE country = "Germany"
				            ); 



-- Nivell 1 Ex3 ------------------------------------------------------------------------------
-- Totes les empreses amb transaccions amb valor per sobre de la mitjana (70 resultats)

		SELECT * FROM company
		WHERE id IN (
				    SELECT DISTINCT(company_id) FROM transaction
				    WHERE amount > (
				        			SELECT AVG(amount)FROM transaction
				    				)
					);



-- Nivell 1 Ex3 ------------------------------------------------------------------------------
-- Totes les empreses sense transaccions (0 resultats)

		SELECT * FROM company
		WHERE id NOT IN (
						SELECT DISTINCT(company_id) FROM transaction
						);



-- Nivell 2 Ex1 ------------------------------------------------------------------------------
-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
-- Mostra la data de cada transacció juntament amb el total de les vendes.

		SELECT 
			date(timestamp) AS "Data transacció",
			sum(amount) AS "Total vendes" 
		FROM transaction
		GROUP BY 1
		ORDER BY 2 DESC
		LIMIT 5;



-- Nivell 2 Ex2 ------------------------------------------------------------------------------
-- Quina és la mitjana de vendes per país?
-- Presenta els resultats ordenats de major a menor mitja.

		SELECT 
			country AS "País",
			ROUND(AVG(amount),2) AS "Mitjana de vendes"  
		FROM transaction
		LEFT JOIN company ON company.id = transaction.company_id
		GROUP BY country
		ORDER BY 2 DESC;



-- Nivell 2 Ex3 ------------------------------------------------------------------------------
-- En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes 
-- publicitàries per a fer competència a la companyia "Non Institute".
-- Per a això, et demanen la llista de totes les transaccions realitzades per empreses
-- que estan situades en el mateix país que aquesta companyia.

--    Mostra el llistat aplicant JOIN i subconsultes.

		SELECT * FROM transaction
		INNER JOIN company ON transaction.company_id = company.id
		WHERE country = (SELECT country FROM company WHERE company_name = "Non Institute");

--    Mostra el llistat aplicant solament subconsultes.

		SELECT *
		FROM transaction
		WHERE company_id IN (
				            SELECT id
				            FROM company
				            WHERE country = (
				                            SELECT country
				                            FROM company
				                            WHERE company_name = "Non Institute"
				                            )
							);



-- Nivell 3 Ex1
-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros 
-- i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. (2021-04-29 , 2021-07-20, 2022-03-13)	
-- Ordena els resultats de major a menor quantitat.

		SELECT company_name, phone, country, timestamp, amount 
		FROM transaction
		LEFT JOIN company ON company.id = transaction.company_id
		WHERE 
			amount BETWEEN 100 AND 200 
			AND 
			(date(timestamp) = "2021-04-29" OR 
			 date(timestamp) = "2021-07-20" OR 
			 date(timestamp) = "2022-03-13%")
		ORDER BY amount DESC;



-- Nivell 3 Ex2
-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
-- per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
-- però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.

		SELECT 
			company_id,
			company_name,
			COUNT(transaction.id) AS "Número de transaccions",
			CASE
				WHEN COUNT(transaction.id) > 4 THEN "Sí"
				ELSE "No"
			END AS "Més de 4 transaccions?",
			phone,
			email,
			country,
			website
		FROM transaction
		INNER JOIN company ON transaction.company_id = company.id
		GROUP BY company_id;

