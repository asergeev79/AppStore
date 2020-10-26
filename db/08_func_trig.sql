USE appstore;

# Функция проверки сертификата на актуальность
DROP FUNCTION IF EXISTS is_certificate_active;
DELIMITER //
CREATE FUNCTION is_certificate_active (cert_id INT)
RETURNS VARCHAR(10) NO SQL
BEGIN
	DECLARE cert_end DATE;
	SELECT end_date INTO cert_end FROM certificates WHERE id = cert_id; 
	IF (cert_end < NOW()) THEN 
		RETURN 'expired';
	ELSE
		RETURN 'active';
	END IF;
END//

DELIMITER ;

# Триггер, проверяющий дату релиза в зависимости от версии ПО:
# Если minor_version вставляемой строки в пределах major_version для определённого ПО больше существующего
# и при этом release_date более поздний, то ошибка. 
DROP TRIGGER IF EXISTS check_app_release_date_insert;
DELIMITER //
CREATE TRIGGER check_app_release_date_insert BEFORE INSERT ON app_versions
FOR EACH ROW
BEGIN
  DECLARE rel_date DATE;
  DECLARE minor_ver INT;
  IF (SELECT COUNT(av.major_version) FROM app_versions av WHERE av.app_os_id = NEW.app_os_id) THEN
  	IF (SELECT COUNT(av.minor_version) FROM app_versions av 
  	WHERE av.app_os_id = NEW.app_os_id AND av.major_version = NEW.major_version) THEN
  		SELECT MAX(av2.minor_version) INTO minor_ver FROM app_versions av2
  		WHERE av2.app_os_id = NEW.app_os_id AND av2.major_version = NEW.major_version;
  		SELECT av.release_date INTO rel_date FROM app_versions av 
  		WHERE av.app_os_id = NEW.app_os_id 
  			AND av.major_version = NEW.major_version 
  			AND av.minor_version = minor_ver;
  		IF ((minor_ver < NEW.minor_version) AND (rel_date > NEW.release_date))
  			OR 
  			((minor_ver > NEW.minor_version) AND (rel_date < NEW.release_date))
  		THEN 
  			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'New version can not be older than existing';
  		END IF;
  	END IF; 
  END IF;
END//

DELIMITER ;
