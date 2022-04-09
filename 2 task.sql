--Однотабличные запросы
--SELECT name, surname FROM student WHERE score >= 4 AND score <= 4.5;
--SELECT st.name, st.surname FROM student st WHERE score >= 4 AND score <= 4.5;

--SELECT name, surname, n_group FROM student WHERE CAST(n_group AS varchar) LIKE '2%';

--SELECT name, surname, n_group FROM student ORDER BY n_group DESC, name ASC;

--SELECT name, surname, score FROM student WHERE score > 4 ORDER BY score DESC;

--SElECT name, risk FROM hobby WHERE name = 'Football' OR name = 'Hockey';

--SELECT student_id, hobby_id FROM student_hobby WHERE started_at BETWEEN '2016-01-01'
--AND '2018-12-31' AND finished_at IS NULL;

--SELECT name, surname, score FROM student WHERE score > 4.5 ORDER BY score DESC;

--SELECT name, surname, score FROM student WHERE score > 4.5 ORDER BY score DESC LIMIT 5;

/*SELECT name, risk, CASE
 WHEN risk < 2 THEN 'очень низкий'
 WHEN risk >= 2 AND risk < 4 THEN 'низкий'
 WHEN risk >= 4 AND risk < 6 THEN 'средний'
 WHEN risk >= 6 AND risk < 8 THEN 'высокий'
 WHEN risk >= 8 THEN 'очень высокий'
 END
 FROM hobby;*/
 
--SELECT name, risk FROM hobby ORDER BY risk DESC LIMIT 3;

--Групповые функции
--SELECT n_group, COUNT(n_group) AS stud_count FROM student GROUP BY n_group ORDER BY n_group DESC;

--SELECT n_group, MAX(score) AS max_score FROM student GROUP BY n_group ORDER BY n_group DESC;

--SELECT surname, COUNT(surname) AS surname_count FROM student GROUP BY surname;

--SELECT date_birth, COUNT(date_birth) AS date_count FROM student GROUP BY date_birth;

/*SELECT substr(CAST(n_group AS varchar), 1, 1), AVG(score) AS avg_score 
FROM student GROUP BY substr(CAST(n_group AS varchar), 1, 1) 
ORDER BY substr(CAST(n_group AS varchar), 1, 1);*/

/*SELECT n_group, AVG(score) AS avg_score 
FROM student WHERE CAST(n_group AS varchar) LIKE '2%' GROUP BY n_group 
ORDER BY avg_score DESC LIMIT 1;*/

/*SELECT n_group, AVG(score) AS avg_score 
FROM student GROUP BY n_group HAVING AVG(score) <= 3.5
ORDER BY avg_score ASC;*/

/*SELECT n_group, COUNT(n_group) AS stud_count, MAX(score) AS max_score, AVG(score) AS avg_score,
MIN(score) AS min_score FROM student GROUP BY n_group ORDER BY n_group DESC;*/

/*SELECT n_group, id as id_stud, surname, score FROM student WHERE n_group = 3081 
ORDER BY score DESC LIMIT 1;*/