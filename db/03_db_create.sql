CREATE DATABASE appstore;
USE appstore;

DROP TABLE IF EXISTS `accounts`;
CREATE TABLE `accounts` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `accounts_UN` (`email`)
) COMMENT='Учётные записи';

DROP TABLE IF EXISTS `app_account`;
CREATE TABLE `app_account` (
  `app_id` bigint unsigned NOT NULL,
  `account_id` bigint unsigned NOT NULL,
  `app_status_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`app_id`,`account_id`),
  KEY `app_account_FK_1` (`account_id`),
  KEY `app_account_FK_2` (`app_status_id`),
  CONSTRAINT `app_account_FK` FOREIGN KEY (`app_id`) REFERENCES `applications` (`id`) ON DELETE CASCADE,
  CONSTRAINT `app_account_FK_1` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `app_account_FK_2` FOREIGN KEY (`app_status_id`) REFERENCES `app_statuses` (`id`)
) COMMENT='Приложения, привязанные к аккаунту: приобретённые, заказанные, скаченные и т.п.';

DROP TABLE IF EXISTS `app_arch`;
CREATE TABLE `app_arch` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `app_id` bigint unsigned NOT NULL COMMENT 'Ссылка на приложение',
  `arch_id` bigint unsigned NOT NULL COMMENT 'Ссылка на архитектуру',
  `name` varchar(20) DEFAULT NULL COMMENT 'Название релиза',
  PRIMARY KEY (`id`),
  UNIQUE KEY `app_arch_UN` (`app_id`,`arch_id`),
  KEY `app_arch_FK_1` (`arch_id`),
  CONSTRAINT `app_arch_FK` FOREIGN KEY (`app_id`) REFERENCES `applications` (`id`) ON DELETE CASCADE,
  CONSTRAINT `app_arch_FK_1` FOREIGN KEY (`arch_id`) REFERENCES `architectures` (`id`) ON DELETE CASCADE
) COMMENT='Наличие ПО под определённую архитектуру';

DROP TABLE IF EXISTS `app_device`;
CREATE TABLE `app_device` (
  `app_version_id` bigint unsigned NOT NULL,
  `device_id` bigint unsigned NOT NULL,
  `app_status_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`app_version_id`,`device_id`),
  KEY `app_device_FK_1` (`device_id`),
  KEY `app_device_FK_2` (`app_status_id`),
  CONSTRAINT `app_device_FK` FOREIGN KEY (`app_version_id`) REFERENCES `app_versions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `app_device_FK_1` FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `app_device_FK_2` FOREIGN KEY (`app_status_id`) REFERENCES `app_statuses` (`id`)
) COMMENT='Приложения, привязанные к устройствам';

DROP TABLE IF EXISTS `app_os`;
CREATE TABLE `app_os` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `os_id` bigint unsigned DEFAULT NULL COMMENT 'Ссылка на ОС - приложение',
  `app_arch_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `app_os_FK` (`os_id`),
  KEY `app_os_FK_1` (`app_arch_id`),
  CONSTRAINT `app_os_FK` FOREIGN KEY (`os_id`) REFERENCES `applications` (`id`),
  CONSTRAINT `app_os_FK_1` FOREIGN KEY (`app_arch_id`) REFERENCES `app_arch` (`id`)
) COMMENT='Версии ПО для определённой ОС';

DROP TABLE IF EXISTS `app_statuses`;
CREATE TABLE `app_statuses` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `app_statuses_UN` (`name`)
) COMMENT='Статусы приложений';

DROP TABLE IF EXISTS `app_versions`;
CREATE TABLE `app_versions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `app_os_id` bigint unsigned NOT NULL,
  `major_version` smallint unsigned NOT NULL COMMENT 'Major версия',
  `minor_version` smallint unsigned NOT NULL COMMENT 'Minor версия',
  `release_date` date NOT NULL COMMENT 'Дата релиза',
  PRIMARY KEY (`id`),
  UNIQUE KEY `app_versions_UN` (`app_os_id`,`major_version`,`minor_version`),
  CONSTRAINT `app_versions_FK` FOREIGN KEY (`app_os_id`) REFERENCES `app_os` (`id`)
) COMMENT='Версии приложений';

DROP TABLE IF EXISTS `applications`;
CREATE TABLE `applications` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `vendor_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `applications_UN` (`name`),
  KEY `applications_FK` (`vendor_id`),
  CONSTRAINT `applications_FK` FOREIGN KEY (`vendor_id`) REFERENCES `accounts` (`id`)
) COMMENT='Приложения';

DROP TABLE IF EXISTS `architectures`;
CREATE TABLE `architectures` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(10) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `architectures_UN` (`name`)
) COMMENT='Аппаратные архитектуры';

DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT 'Название категории',
  PRIMARY KEY (`id`),
  UNIQUE KEY `categories_UN` (`name`)
) COMMENT='Категории ПО';

DROP TABLE IF EXISTS `categories_apps`;
CREATE TABLE `categories_apps` (
  `category_id` bigint unsigned NOT NULL COMMENT 'Ссылка на категорию',
  `app_id` bigint unsigned NOT NULL COMMENT 'Ссылка на приложение',
  PRIMARY KEY (`category_id`,`app_id`),
  KEY `categories_apps_FK` (`app_id`),
  CONSTRAINT `categories_apps_FK` FOREIGN KEY (`app_id`) REFERENCES `applications` (`id`) ON DELETE CASCADE,
  CONSTRAINT `categories_apps_FK_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE
) COMMENT='Соответствие ПО категориям';

DROP TABLE IF EXISTS `certificate_types`;
CREATE TABLE `certificate_types` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `requirement` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `certificate_types_UN` (`requirement`)
) COMMENT='Требования, по которым выдан сертификат';

DROP TABLE IF EXISTS `certificates`;
CREATE TABLE `certificates` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(10) NOT NULL COMMENT 'Номер сертификата',
  `reg_id` bigint unsigned NOT NULL COMMENT 'id регулятора',
  `cert_type_id` bigint unsigned NOT NULL COMMENT 'Требование, по которому выдан сертификат',
  `app_version_id` bigint unsigned NOT NULL,
  `issue_date` date NOT NULL COMMENT 'Дата выпуска сертификата',
  `end_date` date NOT NULL COMMENT 'Срок действия сертификата',
  PRIMARY KEY (`id`),
  UNIQUE KEY `certificates_UN` (`name`,`reg_id`),
  KEY `certificates_FK` (`reg_id`),
  KEY `certificates_FK_1` (`cert_type_id`),
  KEY `certificates_FK_2` (`app_version_id`),
  CONSTRAINT `certificates_FK` FOREIGN KEY (`reg_id`) REFERENCES `regulators` (`id`),
  CONSTRAINT `certificates_FK_1` FOREIGN KEY (`cert_type_id`) REFERENCES `certificate_types` (`id`),
  CONSTRAINT `certificates_FK_2` FOREIGN KEY (`app_version_id`) REFERENCES `app_versions` (`id`),
  CONSTRAINT `certificates_CHECK` CHECK ((`issue_date` < `end_date`))
) COMMENT='Сертификаты регуляторов';

DROP TABLE IF EXISTS `data`;
CREATE TABLE `data` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `data_type_id` bigint unsigned NOT NULL,
  `app_version_id` bigint unsigned NOT NULL,
  `url` varchar(255) NOT NULL COMMENT 'Местоположение данных',
  PRIMARY KEY (`id`),
  KEY `data_FK` (`app_version_id`),
  KEY `data_FK_1` (`data_type_id`),
  CONSTRAINT `data_FK` FOREIGN KEY (`app_version_id`) REFERENCES `app_versions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `data_FK_1` FOREIGN KEY (`data_type_id`) REFERENCES `data_types` (`id`)
) COMMENT='Логотипы и скриншоты приложений, сканы сертификатов';

DROP TABLE IF EXISTS `data_types`;
CREATE TABLE `data_types` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `description` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `media_types_UN` (`description`)
) COMMENT='Типы данных';

DROP TABLE IF EXISTS `devices`;
CREATE TABLE `devices` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `account_id` bigint unsigned NOT NULL,
  `profile` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'Профиль устройства',
  PRIMARY KEY (`id`),
  KEY `devices_FK` (`account_id`),
  CONSTRAINT `devices_FK` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `devices_chk_1` CHECK (json_valid(`profile`))
) COMMENT='Устройства, привязанные к аккаунту';

DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `profiles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `account_id` bigint unsigned NOT NULL,
  `is_org` tinyint(1) NOT NULL COMMENT 'Метка компания/пользователь',
  `is_dev` tinyint(1) NOT NULL COMMENT 'Разработчик или нет',
  `org_id` bigint unsigned DEFAULT NULL COMMENT 'Ссылка на корпоративный аккаунт',
  PRIMARY KEY (`id`),
  KEY `profiles_FK` (`account_id`),
  KEY `profiles_FK_1` (`org_id`),
  KEY `profiles_is_org_IDX` (`is_org`,`account_id`) USING BTREE,
  KEY `profiles_is_dev_IDX` (`is_dev`,`account_id`) USING BTREE,
  CONSTRAINT `profiles_FK` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `profiles_FK_1` FOREIGN KEY (`org_id`) REFERENCES `accounts` (`id`) ON DELETE SET NULL
) COMMENT='Профили учётных записей';

DROP TABLE IF EXISTS `regulators`;
CREATE TABLE `regulators` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `regulators_UN` (`name`)
) COMMENT='Регуляторы';
