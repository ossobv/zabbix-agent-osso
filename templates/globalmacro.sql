-- SELECT 'INSERT INTO regexps (globalmacroid, macro, value, description, type) VALUES ('||globalmacroid||', '''||REPLACE(macro, '''', '''''')||''', '''||REPLACE(value, '''', '''''')||''', '''||REPLACE(description, '''', '''''')||''', '||type||');' AS sql FROM globalmacro ORDER BY globalmacroid;
INSERT INTO regexps (globalmacroid, macro, value, description, type) VALUES (2, '{$SNMP_COMMUNITY}', 'public', '', 0);
INSERT INTO regexps (globalmacroid, macro, value, description, type) VALUES (3, '{$OFFICE_HOURS_BEGIN}', '080000', 'HHMMSS office-hours start', 0);
INSERT INTO regexps (globalmacroid, macro, value, description, type) VALUES (4, '{$OFFICE_HOURS_END}', '180000', 'HHMMSS office-hours end', 0);
INSERT INTO regexps (globalmacroid, macro, value, description, type) VALUES (5, '{$HAS_DISASTER}', '1', '1=disaster, 0=no_disaster, 9to5=office-hours-disaster', 0);
