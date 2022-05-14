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
### 2. Таблица тикеров акций
```SQL
CREATE TABLE stocks (
	id serial PRIMARY KEY,
	ticker varchar(255) NOT NULL,
	name varchar(255) NOT NULL, --Полное название компании
	industry varchar(255) NOT NULL, --Отрасль компании
	info text --Доп. информация о компании
);
```
### 3. Таблица хранения посекундных котировок по каждому тикеру
```SQL
CREATE TABLE pricePerSecond (
	idStock int NOT NULL REFERENCES stocks(id), --id тикера
	price decimal(16, 2) NOT NULL, -- Цена
	dateAndTime timestamp with time zone NOT NULL --Дата и время
);
```
### 4. Таблица хранения некоторых показателей компании
```SQL
CREATE TABLE indicators (
	idStock int NOT NULL REFERENCES stocks(id),
	marketCap decimal(16, 4) NOT NULL,
	marketCapUnit varchar(4) NOT NULL,
	income decimal(16, 4) NOT NULL,
	incomeUnit varchar(4)  NOT NULL,
	PE decimal(16,2),
	PS decimal(16,2)
);
```
### 5. Таблица хранения некоторых показателей из отчетов компании
```SQL
CREATE TABLE reports (
	idStock int NOT NULL REFERENCES stocks(id),
	EPS real NOT NULL,
	income decimal(16, 4) NOT NULL,
	incomeUnit varchar(4)  NOT NULL
);
```
### 6. Таблица "пользователь-акция-количество акций у пользователя"
```SQL
CREATE TABLE userStock (
  	idUser int NOT NULL REFERENCES users(id),
  	idStock int NOT NULL REFERENCES stocks(id),
  	amount int NOT NULL
);
```
### 7. Таблица с историей операций
```SQL
CREATE TABLE history (
  	idUser int NOT NULL REFERENCES users(id),
  	idStock int NOT NULL REFERENCES stocks(id),
	typeOper varchar(255) NOT NULL, --Тип операции (покупка, продажа)
	dateOper date NOT NULL, --Дата операции
  	quantity int NOT NULL, --Количество акций
	amount decimal(16, 2) NOT NULL, --Сумма операции
	commission decimal(16, 2) NOT NULL --Комиссия
)
```

## Запросы
