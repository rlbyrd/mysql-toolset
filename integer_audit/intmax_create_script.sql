
/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
/*Table structure for table `intmax` */

-- Tables necessary for the intmax script to operate.  These should be created in a schemata named dbaudit.

CREATE TABLE `intaudit` (
  `intaudit_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `table_schema` varchar(128) DEFAULT NULL,
  `table_name` varchar(128) DEFAULT NULL,
  `column_name` varchar(128) DEFAULT NULL,
  `data_type` varchar(32) DEFAULT NULL,
  `is_signed` enum('Y','N') NOT NULL DEFAULT 'Y',
  `column_type` varchar(32) DEFAULT NULL,
  `is_nullable` enum('YES','NO') DEFAULT 'YES',
  `extra` varchar(128) DEFAULT NULL,
  `currentmaxval` bigint(20) unsigned DEFAULT NULL,
  `maxval` bigint(20) unsigned DEFAULT NULL,
  `pct_used` decimal(10,2) unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`intaudit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `intmax` (
  `intmax_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `data_type` varchar(32) NOT NULL,
  `is_signed` enum('Y','N') NOT NULL DEFAULT 'Y',
  `maxval` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`intmax_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

/*Data for the table `intmax` */

insert  into `intmax`(`intmax_id`,`data_type`,`is_signed`,`maxval`) values 
(1,'tinyint','Y',127),
(2,'tinyint','N',255),
(3,'smallint','Y',32767),
(4,'smallint','N',65535),
(5,'mediumint','Y',8388607),
(6,'mediumint','N',16777215),
(7,'int','Y',2147483647),
(8,'int','N',4294967295),
(9,'integer','Y',2147483647),
(10,'integer','N',4294967295),
(11,'bigint','Y',9223372036854775807),
(12,'bigint','N',18446744073709551615);

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
