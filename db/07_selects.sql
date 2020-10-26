USE appstore;

# Список сертифицированного ПО
DROP VIEW cert_app;
CREATE VIEW cert_app AS
SELECT a.id, a.name, 
		CONCAT(av.major_version, '.', av.minor_version) AS "version", 
		r.name AS "reg_name",
		ct.requirement 
FROM 
	certificates t
	JOIN
	certificate_types ct 
	JOIN
	regulators r 
	JOIN
	app_versions av 
	JOIN
	app_os ao 
	JOIN
	app_arch aa 
	JOIN
	applications a 
ON
	t.app_version_id = av.id 
	AND 
	av.app_os_id = ao.id 
	AND 
	ao.app_arch_id = aa.id 
	AND 
	aa.app_id = a.id 
	AND 
	t.reg_id = r.id
	AND 
	t.cert_type_id = ct.id 
;


# Сертифицированное ПО по категориям
SELECT ca.name, ca.version, ca.reg_name, ca.requirement, c.name FROM 
	cert_app ca
	JOIN
	categories_apps ca2 
	JOIN
	categories c 
ON 
	ca.id = ca2.app_id 
	AND 
	ca2.category_id = c.id ;
	
# Выборка ПО от определённого разработчика
SELECT 
	COUNT(a.name) AS app_name,
	a2.email AS vendor_name
FROM 
	applications a
	JOIN
	accounts a2 
ON 
	a.vendor_id = a2.id
GROUP BY a2.id 
;


# Выборка ПО с указанием архитектуры, ОС и версии
DROP VIEW full_app;
CREATE VIEW full_app AS
SELECT
	a.name AS app_name,
	a2.name AS arch_name,
	a3.name AS os_name,
	CONCAT(av.major_version, '.', av.minor_version) AS version
FROM 
	app_versions av
	JOIN
	app_os ao 
	JOIN
	app_arch aa 
	JOIN
	applications a
	JOIN
	architectures a2
	JOIN
	applications a3 
ON 
	av.app_os_id = ao.id 
	AND 
	ao.app_arch_id = aa.id 
	AND 
	aa.app_id = a.id 
	AND 
	aa.arch_id = a2.id
	AND 
	ao.os_id = a3.id 
;
SELECT * FROM full_app;