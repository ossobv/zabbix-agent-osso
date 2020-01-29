# mysqldump --defaults-file=/etc/mysql/debian.cnf zabbix regexps expressions --skip-extended-insert | sed -e '/^[-/]/d'



DROP TABLE IF EXISTS `regexps`;
CREATE TABLE `regexps` (
  `regexpid` bigint(20) unsigned NOT NULL,
  `name` varchar(128) COLLATE utf8_bin NOT NULL DEFAULT '',
  `test_string` text COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`regexpid`),
  UNIQUE KEY `regexps_1` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


LOCK TABLES `regexps` WRITE;
INSERT INTO `regexps` VALUES (1,'File systems for discovery','ext3');
INSERT INTO `regexps` VALUES (2,'Network interfaces for discovery','eth0');
INSERT INTO `regexps` VALUES (3,'Storage devices for SNMP discovery','/boot');
INSERT INTO `regexps` VALUES (4,'ZFS dataset discovery','rpool/ROOT/ubuntu/0b7c168417af5b8448fb17988e23f534fe464715fd4b35aa36ca3eaf234d66af');
INSERT INTO `regexps` VALUES (7,'Exclude filesystems for discovery','');
INSERT INTO `regexps` VALUES (9,'RabbitMQ vhost discovery','');
UNLOCK TABLES;


DROP TABLE IF EXISTS `expressions`;
CREATE TABLE `expressions` (
  `expressionid` bigint(20) unsigned NOT NULL,
  `regexpid` bigint(20) unsigned NOT NULL,
  `expression` varchar(255) COLLATE utf8_bin NOT NULL DEFAULT '',
  `expression_type` int(11) NOT NULL DEFAULT '0',
  `exp_delimiter` varchar(1) COLLATE utf8_bin NOT NULL DEFAULT '',
  `case_sensitive` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`expressionid`),
  KEY `expressions_1` (`regexpid`),
  CONSTRAINT `c_expressions_1` FOREIGN KEY (`regexpid`) REFERENCES `regexps` (`regexpid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


LOCK TABLES `expressions` WRITE;
INSERT INTO `expressions` VALUES (1,1,'^(btrfs|ext2|ext3|ext4|jfs|reiser|xfs|ffs|ufs|jfs|jfs2|vxfs|hfs|ntfs|fat32)$',3,',',0);
INSERT INTO `expressions` VALUES (2,2,'^lo$',4,',',1);
INSERT INTO `expressions` VALUES (3,3,'^(Physical memory|Virtual memory|Memory buffers|Cached memory|Swap space)$',4,',',1);
INSERT INTO `expressions` VALUES (4,2,'^Software Loopback Interface',4,',',1);
INSERT INTO `expressions` VALUES (5,4,'/',0,',',1);
INSERT INTO `expressions` VALUES (8,7,'^/var/lib/lxd/containers/.*/rootfs/',4,',',0);
INSERT INTO `expressions` VALUES (9,7,'^/var/lib/docker/containers/.*/mounts/',4,',',0);
INSERT INTO `expressions` VALUES (10,7,'^/var/lib/kubelet/plugins/',4,',',0);
INSERT INTO `expressions` VALUES (11,7,'^/var/lib/kubelet/pods/',4,',',0);
INSERT INTO `expressions` VALUES (15,2,'^(br-|docker|tap|tun|veth|vmbr|cali)',4,',',1);
INSERT INTO `expressions` VALUES (16,7,'^/var/lib/docker/overlay2/',4,',',0);
INSERT INTO `expressions` VALUES (18,4,'^.*/[0-9a-f]{64}(-init)?$',4,',',1);
INSERT INTO `expressions` VALUES (19,9,'.',3,',',0);
UNLOCK TABLES;


