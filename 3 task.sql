--Многотабличные запросы

--1) Вывести все имена и фамилии студентов, и название хобби, которым занимается этот студент.
/*SELECT st.name,
	st.surname,
	hobby.name
FROM student st, hobby, student_hobby sh
WHERE st.id = sh.student_id AND hobby.id = sh.hobby_id;*/

--2) Вывести информацию о студенте, занимающимся хобби самое продолжительное время.
/*SELECT st.id,
	st.name,
	st.surname,
	hobby.name,
	age(sh.finished_at, sh.started_at) AS term
FROM student st, hobby, student_hobby sh
WHERE st.id = sh.student_id AND hobby.id = sh.hobby_id 
AND age(sh.finished_at, sh.started_at) is NOT null
ORDER BY term DESC
LIMIT 1;*/

--3) Вывести имя, фамилию, номер зачетки и дату рождения для студентов, средний балл которых выше среднего, а сумма риска --всех хобби, которыми он занимается в данный момент, больше 0.9.
/*SELECT st.id,
	st.name,
	st.surname,
	st.date_birth,
	st.score,
	SUM(hobby.risk) AS sum_risk
FROM student st
INNER JOIN student_hobby sh ON st.id = sh.student_id
INNER JOIN hobby ON hobby.id = sh.hobby_id
WHERE st.score > (SELECT SUM(score)/COUNT(score) FROM student)
GROUP BY st.id
HAVING SUM(hobby.risk) > 9;*/

--4) Вывести фамилию, имя, зачетку, дату рождения, название хобби и длительность в месяцах, для всех завершенных хобби
/*SELECT st.id,
	st.name,
	st.surname,
	st.date_birth,
	hobby.name AS name_hobby,
	12*extract(year from age(sh.finished_at, sh.started_at)) AS months
FROM student st
INNER JOIN student_hobby sh ON st.id = sh.student_id
INNER JOIN hobby ON hobby.id = sh.hobby_id
WHERE age(sh.finished_at, sh.started_at) is NOT null;*/

--5) Вывести фамилию, имя, зачетку, дату рождения студентов, которым исполнилось N полных лет на текущую дату, и которые --имеют более 1 действующего хобби.
/*SELECT st.id,
	st.name,
	st.surname,
	st.date_birth,
	extract(year from age(current_date, st.date_birth)) AS years
FROM student st
INNER JOIN student_hobby sh ON st.id = sh.student_id
INNER JOIN hobby ON hobby.id = sh.hobby_id
WHERE extract(year from age(current_date, st.date_birth)) > 19
AND (SELECT COUNT(hobby.name) FROM hobby WHERE sh.finished_at is null) > 1
GROUP BY st.id;*/

--6) Найти средний балл в каждой группе, учитывая только баллы студентов, которые имеют хотя бы одно действующее хобби.
/*SELECT st.n_group,
	round(AVG(score), 2)
FROM student st
INNER JOIN student_hobby sh ON st.id = sh.student_id
INNER JOIN hobby ON hobby.id = sh.hobby_id
WHERE (SELECT COUNT(hobby.name) FROM hobby WHERE sh.finished_at is null) >= 1
GROUP BY st.n_group;*/

--7) Найти название, риск, длительность в месяцах самого продолжительного хобби из действующих, указав номер зачетки --студента.
/*SELECT st.id AS student_id, 
	hobby.name,
	hobby.risk,
	12*extract(year from age(current_date, sh.started_at)) AS months
FROM student st
INNER JOIN student_hobby sh ON st.id = sh.student_id
INNER JOIN hobby ON hobby.id = sh.hobby_id
WHERE sh.finished_at is null
ORDER BY months DESC
LIMIT 1;*/

--8) Найти все хобби, которыми увлекаются студенты, имеющие максимальный балл.
/*SELECT hobby.name
FROM hobby
INNER JOIN student_hobby sh ON hobby.id = sh.hobby_id
INNER JOIN student st ON st.id = sh.student_id
WHERE st.score = (SELECT MAX(score) FROM student) AND sh.finished_at IS null;*/

--9) Найти все действующие хобби, которыми увлекаются троечники 2-го курса.
/*SELECT hobby.name
FROM hobby
INNER JOIN student_hobby sh ON hobby.id = sh.hobby_id
INNER JOIN student st ON st.id = sh.student_id
WHERE st.score < 4 AND sh.finished_at IS null AND CAST(st.n_group AS varchar) LIKE '2%';*/

--10) Найти номера курсов, на которых более 50% студентов имеют более одного действующего хобби.
/*SELECT course_act.course
FROM
(SELECT course, COUNT(DISTINCT sh.student_id )as zanim
FROM student_hobby sh
INNER JOIN (
SELECT DISTINCT n_group/1000 as course, st.id
FROM student st) as nt on nt.id = sh.student_id
WHERE finished_at IS NULL
GROUP BY course) as course_act
RIGHT JOIN
(SELECT n_group/1000 as course, COUNT(*) from student st GROUP BY n_group/1000) as course_all
on course_act.course = course_all.course
WHERE course_act.zanim*1./course_all.count>0.5;*/

--11) Вывести номера групп, в которых не менее 60% студентов имеют балл не ниже 4.
/*SELECT st1.n_group
FROM (SELECT n_group, COUNT(id) FROM student WHERE score >= 4 GROUP BY n_group) AS st1
INNER JOIN (SELECT n_group, COUNT(id) FROM student GROUP BY n_group) AS st2
ON st1.n_group = st2.n_group
WHERE st2.count/st1.count >= 0.6;*/