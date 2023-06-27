DROP DATABASE IF EXISTS homework5;
CREATE DATABASE homework5;
USE homework5;

DROP TABLE IF EXISTS das_auto;
CREATE TABLE das_auto
(
	id INT NOT NULL PRIMARY KEY,
    `name` VARCHAR(45),
    cost INT
);

SELECT * FROM das_auto;

-- LOAD DATA INFILE '/home/valery/musor/fileHW5.csv'
LOAD DATA INFILE '/var/lib/mysql-files/fileHW5.csv'
INTO TABLE das_auto
FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- mysql ..... with the --secure-file-priv option:
-- https://stackoverflow.com/questions/32737478/how-should-i-resolve-secure-file-priv-in-mysql
-- SHOW VARIABLES LIKE "secure_file_priv";
-- /var/lib/mysql-files/
SELECT * FROM das_auto;

-- TASK 1
CREATE OR REPLACE VIEW cheaper_cars 
AS SELECT * 
FROM das_auto
WHERE cost <= 25000;
SELECT * FROM cheaper_cars;

-- TASK 2
ALTER VIEW cheaper_cars AS 
SELECT * 
FROM das_auto
WHERE cost <= 30000;
SELECT * FROM cheaper_cars;

-- TASK 3
CREATE OR REPLACE VIEW skodaudi
AS SELECT * 
FROM das_auto
-- почему-то в файле пробелы после названия марки, лень убирать, поэтому в where с пробелами
WHERE `name` IN ("Skoda ", "Audi ");
SELECT * FROM skodaudi;

-- TASK 4
DROP TABLE IF EXISTS train_time;
CREATE TABLE train_time
(
	id INT NOT NULL PRIMARY KEY,
    id_train INT,
    station_name VARCHAR(50),
    station_time_without TIME
);
LOAD DATA INFILE '/var/lib/mysql-files/MOCK_DATA.csv'
-- приложу сгенерированный файл таблицы
INTO TABLE train_time
FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@id, @id_train, @station_name, @station_time_without)
SET 
	id = @id, 
	id_train = @id_train, 
	station_name = @station_name, 
	station_time_without = STR_TO_DATE(@station_time_without, '%H:%i:%s');
SELECT * FROM train_time;

-- LAG смещение:
CREATE OR REPLACE VIEW train_time_view AS
SELECT id, id_train, station_name, station_time_without,
     TIMEDIFF(station_time_without, LAG(station_time_without) OVER (PARTITION BY id_train ORDER BY station_time_without)) AS travel_time
FROM train_time;
-- каждый номер поезда окно, в котором сортируем по времени на станции и LAG либо LEAD со временем на следующей станции
-- LAG - смещение от текущей строки к началу раздела.. LEAD смещение от текущей строки к концу раздела
-- LEAD смещение:
CREATE OR REPLACE VIEW train_time_view AS
SELECT id, id_train, station_name, station_time_without,
    TIMEDIFF(LEAD(station_time_without) OVER (PARTITION BY id_train ORDER BY station_time_without), station_time_without) AS travel_time
FROM train_time;

SELECT * FROM train_time_view;