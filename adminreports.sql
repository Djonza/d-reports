CREATE TABLE IF NOT EXISTS `admin_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_name` varchar(100) DEFAULT NULL,
  `admin_name` varchar(100) DEFAULT 'No admin',
  `time` datetime DEFAULT current_timestamp(),
  `category` varchar(50) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `player_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;