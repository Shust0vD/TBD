## Создание таблиц
### 1. Таблица пользователей
```SQL
CREATE TABLE users (
	id serial PRIMARY KEY,
	name varchar(255) NOT NULL,
	email varchar(255) NOT NULL,
	password varchar(255) NOT NULL,
	account decimal(16,2) NOT NULL, --Баланс пользователя
	blocked bool NOT NULL DEFAULT false, --Заблокирован ли пользователь (true-заблокирован, false-не заблокирован)
	status varchar(255) NOT NULL DEFAULT 'client' --Статус пользователя (only read, client, admin)
);
```
### 1. Таблица тикеров акций
CREATE TABLE stocks (
	id serial PRIMARY KEY,
	ticker varchar(255) NOT NULL,
	name varchar(255) NOT NULL, --Полное название компании
	industry varchar(255) NOT NULL, --Отрасль компании
	info text --Доп. информация о компании
);
CREATE TABLE pricePerSecond (
	idStock int NOT NULL REFERENCES stocks(id),
	price decimal(16, 2) NOT NULL,
	dateAndTime timestamp with time zone NOT NULL
);
CREATE TABLE indicators (
	idStock int NOT NULL REFERENCES stocks(id),
	marketCap decimal(16, 4) NOT NULL,
	marketCapUnit varchar(4) NOT NULL,
	income decimal(16, 4) NOT NULL,
	incomeUnit varchar(4)  NOT NULL,
	PE decimal(16,2),
	PS decimal(16,2)
);
CREATE TABLE reports (
	idStock int NOT NULL REFERENCES stocks(id),
	EPS real NOT NULL,
	income decimal(16, 4) NOT NULL,
	incomeUnit varchar(4)  NOT NULL
);
CREATE TABLE userStock (
  	idUser int NOT NULL REFERENCES users(id),
  	idStock int NOT NULL REFERENCES stocks(id),
  	amount int NOT NULL
);
CREATE TABLE history (
  	idUser int NOT NULL REFERENCES users(id),
  	idStock int NOT NULL REFERENCES stocks(id),
	typeOper varchar(255) NOT NULL,
	dateOper date NOT NULL,
  	quantity int NOT NULL,
	amount decimal(16, 2) NOT NULL,
	commission decimal(16, 2) NOT NULL
)
