CREATE TABLE student(
id serial PRIMARY KEY,
name varchar(255) NOT NULL,
surname varchar(255) NOT NULL,
address varchar(255),
n_group int,
score numeric(3, 2),
address varchar(255),
date_birth date);

CREATE TABLE hobby(
id serial PRIMARY KEY,
name varchar(255),
risk int);

CREATE TABLE student_hobby(
student_id int NOT NULL REFERENCES student(id),
hobby_id int NOT NULL REFERENCES hobby(id),
started_at date,
finished_at date);