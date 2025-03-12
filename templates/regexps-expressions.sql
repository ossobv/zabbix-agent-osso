-- SELECT 'INSERT INTO regexps (regexpid, name) VALUES ('||regexpid||', '''||REPLACE(name, '''', '''''')||''');' AS sql FROM regexps ORDER BY regexpid;
INSERT INTO regexps (regexpid, name) VALUES (1, 'File systems for discovery');
INSERT INTO regexps (regexpid, name) VALUES (2, 'Network interfaces for discovery');
INSERT INTO regexps (regexpid, name) VALUES (3, 'Storage devices for SNMP discovery');
INSERT INTO regexps (regexpid, name) VALUES (4, 'ZFS dataset discovery');
INSERT INTO regexps (regexpid, name) VALUES (7, 'Exclude filesystems for discovery');
INSERT INTO regexps (regexpid, name) VALUES (9, 'RabbitMQ vhost discovery');
INSERT INTO regexps (regexpid, name) VALUES (10, 'Rook ceph rbd csi filesystems for discovery');
INSERT INTO regexps (regexpid, name) VALUES (11, 'Minio filesystems for discovery');
INSERT INTO regexps (regexpid, name) VALUES (12, 'Exclude tank for discovery');

-- SELECT 'INSERT INTO expressions (expressionid, regexpid, expression, expression_type, exp_delimiter, case_sensitive)'||
--   E'\n  '||'VALUES ('||expressionid||', '||regexpid||', '''||REPLACE(expression, '''', '''''')||''', '||
--   expression_type||', '''||REPLACE(exp_delimiter, '''', '''''')||''', '||case_sensitive||');' AS sql
--   FROM expressions ORDER BY regexpid, expressionid;
INSERT INTO expressions (expressionid, regexpid, expression, expression_type, exp_delimiter, case_sensitive)
  VALUES (1, 1, '^(btrfs|ext2|ext3|ext4|jfs|reiser|xfs|ffs|ufs|jfs|jfs2|vxfs|hfs|ntfs|fat32)$', 3, ',', 0);
INSERT INTO expressions (expressionid, regexpid, expression, expression_type, exp_delimiter, case_sensitive)
  VALUES (2, 2, '^lo$', 4, ',', 1);
INSERT INTO expressions (expressionid, regexpid, expression, expression_type, exp_delimiter, case_sensitive)
  VALUES (4, 2, '^Software Loopback Interface', 4, ',', 1);
INSERT INTO expressions (expressionid, regexpid, expression, expression_type, exp_delimiter, case_sensitive)
  VALUES (23, 2, '.', 2, ',', 1);
INSERT INTO expressions (expressionid, regexpid, expression, expression_type, exp_delimiter, case_sensitive)
  VALUES (24, 2, '_', 2, ',', 1);
INSERT INTO expressions (expressionid, regexpid, expression, expression_type, exp_delimiter, case_sensitive)
  VALUES (25, 2, '^[A-Z0-9_]+$', 4, ',', 1);
INSERT INTO expressions (expressionid, regexpid, expression, expression_type, exp_delimiter, case_sensitive)
  VALUES (41, 2, '^(br-|cali|docker|fwbr|fwln|fwpr|lxc|ppp|tap|tun|veth|vmbr)', 4, ',', 1);
INSERT INTO expressions (expressionid, regexpid, expression, expression_type, exp_delimiter, case_sensitive)
  VALUES (3, 3, '^(Physical memory|Virtual memory|Memory buffers|Cached memory|Swap space)$', 4, ',', 1);
INSERT INTO expressions (expressionid, regexpid, expression, expression_type, exp_delimiter, case_sensitive)
  VALUES (34, 4, '^[^/]*/.*(backup|mysql|postgres).*$', 3, ',', 1);
INSERT INTO expressions (expressionid, regexpid, expression, expression_type, exp_delimiter, case_sensitive)
  VALUES (8, 7, '^/var/lib/lxd/containers/.*/rootfs/', 4, ',', 0);
INSERT INTO expressions (expressionid, regexpid, expression, expression_type, exp_delimiter, case_sensitive)
  VALUES (9, 7, '^/var/lib/docker/containers/.*/mounts/', 4, ',', 0);
INSERT INTO expressions (expressionid, regexpid, expression, expression_type, exp_delimiter, case_sensitive)
  VALUES (16, 7, '^/var/lib/docker/overlay2/', 4, ',', 0);
INSERT INTO expressions (expressionid, regexpid, expression, expression_type, exp_delimiter, case_sensitive)
  VALUES (20, 7, '^/run/docker/', 4, ',', 0);
INSERT INTO expressions (expressionid, regexpid, expression, expression_type, exp_delimiter, case_sensitive)
  VALUES (21, 7, '^/.*/[0-9a-f]{64}(/|$)', 4, ',', 0);
INSERT INTO expressions (expressionid, regexpid, expression, expression_type, exp_delimiter, case_sensitive)
  VALUES (26, 7, '^/media/', 4, ',', 0);
INSERT INTO expressions (expressionid, regexpid, expression, expression_type, exp_delimiter, case_sensitive)
  VALUES (27, 7, '^/mnt/', 4, ',', 0);
INSERT INTO expressions (expressionid, regexpid, expression, expression_type, exp_delimiter, case_sensitive)
  VALUES (45, 7, '^/var/lib/kubelet/pods/', 4, ',', 0);
INSERT INTO expressions (expressionid, regexpid, expression, expression_type, exp_delimiter, case_sensitive)
  VALUES (19, 9, '.', 3, ',', 0);
INSERT INTO expressions (expressionid, regexpid, expression, expression_type, exp_delimiter, case_sensitive)
  VALUES (39, 10, '^/var/lib/kubelet/plugins/kubernetes.io/csi/[^/]*(rbd|cephfs)[^/]*/', 3, ',', 0);
INSERT INTO expressions (expressionid, regexpid, expression, expression_type, exp_delimiter, case_sensitive)
  VALUES (40, 11, '^/mnt/minio*', 3, ',', 0);
INSERT INTO expressions (expressionid, regexpid, expression, expression_type, exp_delimiter, case_sensitive)
  VALUES (44, 12, '^/tank/.*', 4, ',', 0);
