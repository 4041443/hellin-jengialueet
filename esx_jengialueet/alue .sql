CREATE TABLE IF NOT EXISTS jengialueet (
  alue int(11) NOT NULL,
  valtausaika int(11) DEFAULT NULL,
  omistaja varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  rahaa int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO jengialueet (alue, valtausaika, omistaja, rahaa) VALUES
    (1, 1597081959, 'vapaa', 0),
    (2, 1596916563, 'vapaa', 0),
    (3, 1596916564, 'vapaa', 0),
    (4, 1598292029, 'vapaa', 0),
    (5, 1596916566, 'vapaa', 0),
    (6, 1596916567, 'vapaa', 0),
    (7, 1598895753, 'vapaa', 0),
    (8, 1598891993, 'vapaa', 0),
    (9, 1597506406, 'vapaa', 0);