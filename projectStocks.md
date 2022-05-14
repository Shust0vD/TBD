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
	dateOper timestamp with time zone NOT NULL, --Дата операции
  	quantity int NOT NULL, --Количество акций
	amount decimal(16, 2) NOT NULL, --Сумма операции
	commission decimal(16, 2) NOT NULL --Комиссия
);
```

## Запросы
### 1. Регистрация
#### Добавление нового пользователя
```SQL
INSERT INTO users (name, email, password, account) VALUES ('Ivan', 'ivan27@gmail.ru', 'redlion1337', 0);
```
### 2. Добавление информации об акциях
#### Добавление нового тикера администратором
```SQL
INSERT INTO stocks (ticker , name, industry) VALUES ('YNDX', 'Яндекс', 'Информационные технологии');
```
#### Добавление дополнительной информации о тикере
```SQL
UPDATE stocks SET info = 'Российская транснациональная компания' WHERE ticker = 'YNDX';
```
#### Добавление некоторых показателей компании
```SQL
INSERT INTO indicators (idStock , marketCap, marketCapUnit, income, incomeUnit, PE, PS) 
VALUES ((SELECT id FROM stocks WHERE ticker='YNDX'), 7.98, 'B', 30, 'B', 13.19, 3.07);
```
#### Добавление некоторых показателей из отчетов компании
```SQL
INSERT INTO reports (idStock , EPS, income, incomeUnit) 
VALUES ((SELECT id FROM stocks WHERE ticker='YNDX'), -26.08, 106.01, 'B');
```
#### Добавление посекундных котировок по каждому тикеру (запрос выполняется в цикле каждую секунду n раз (n-количество акций) с разным значением тикера)
```SQL
INSERT INTO pricePerSecond (idStock , price, dateAndTime) 
VALUES ((SELECT id FROM stocks WHERE ticker='YNDX'), 1593.0, CURRENT_TIMESTAMP);
```
### 3. Совершение операций с акциями (покупка, продажа)
#### Покупка
```SQL
SELECT account FROM users WHERE id=1; --Проверка баланса перед покупкой

UPDATE users SET account = account - 7965 WHERE id = 1; --Снятие средств со счета пользователя

INSERT INTO userStock (idUser, idStock, amount) 
VALUES (1, (SELECT id FROM stocks WHERE ticker='YNDX'), 5); --Добавление информации в таблицу userStock, если такой записи не было ранее

UPDATE userStock SET amount = amount + 5 
WHERE idUser = 1 AND idStock = (SELECT id FROM stocks WHERE ticker = 'YNDX'); --Либо обновление, если такая запись уже была

INSERT INTO history (idUser, idStock, typeOper, dateOper, quantity, amount, commission)
VALUES (1, 1, 'purchase', current_timestamp, 5, 7965, 23.895); --Добавление информации о покупке в историю
```
#### Продажа
```SQL
SELECT amount FROM userStock WHERE idUser = 1 AND idStock = 1; --Проверка, хватает ли акций у пользователя

UPDATE userStock SET amount = amount - 5 WHERE idUser = 1 AND idStock = 1;  --Уменьшение количества акций в портфеле пользователя

UPDATE users SET account = account + 7965 WHERE id = 1; --Пополнение баланса пользователя

INSERT INTO history (idUser, idStock, typeOper, dateOper, quantity, amount, commission)
VALUES (1, 1, 'sale', current_timestamp, 5, 7965, 0); --Добавление информации о продаже в историю
```
### 4. Просмотр информации
#### Просмотр истории для японских свечей по тикеру
```SQL
SELECT * FROM pricePerSecond 
WHERE idStock = (SELECT id FROM stocks WHERE ticker = 'YNDX') AND
extract(minute FROM current_timestamp - dateAndTime) + extract(hour FROM current_timestamp - dateAndTime)*60 < 5; --5-минутные

SELECT * FROM pricePerSecond 
WHERE idStock = (SELECT id FROM stocks WHERE ticker = 'YNDX') AND
extract(day FROM current_timestamp - dateAndTime) < 1; --Дневные

SELECT * FROM pricePerSecond 
WHERE idStock = (SELECT id FROM stocks WHERE ticker = 'YNDX') AND
extract(day FROM current_timestamp - dateAndTime) < 7; --Недельные
```
#### Просмотр тикера и информации о компании, а также показатели и отчёты.
```SQL
SELECT st.name, st.ticker, st.industry, st.info, 
concat(ind.marketCap, ind.marketCapUnit) AS market_cap, concat(ind.income, ind.incomeUnit) AS income,
ind.PE, ind.PS, rep.EPS AS EPS_report, concat(rep.income, rep.incomeUnit) AS income_report
FROM stocks st
INNER JOIN indicators ind 
ON st.id = ind.idStock
INNER JOIN reports rep
ON st.id = rep.idStock
WHERE name = 'Яндекс';
```
#### Поиск компании по заданным показателям, цифрам из отчёта с пагинацией и сортировкой по атрибутам
```SQL
DECLARE search SCROLL CURSOR FOR
SELECT st.ticker, st.name, st.industry, st.info
FROM stocks st
INNER JOIN indicators ind 
ON st.id = ind.idStock
INNER JOIN reports rep
ON st.id = rep.idStock
WHERE ind.marketCap > 5 AND ind.marketCap < 8 AND ind.marketCapUnit = 'B'
	AND rep.income > 25 AND rep.incomeUnit = 'B'
ORDER BY ind.marketCapUnit, ind.marketCap, rep.incomeUnit, rep.income;
FETCH FORWARD 5 FROM search;
```
#### Просмотр портфеля пользователя
```SQL
SELECT st.ticker, uS.amount, pps.price*uS.amount AS cost
FROM stocks st
INNER JOIN userStock uS
ON st.id = uS.idStock
INNER JOIN users u
ON u.id = uS.idUser
INNER JOIN pricePerSecond pps
ON st.id = pps.idStock
WHERE u.id = 1 AND pps.dateAndTime = (SELECT MAX(dateAndTime) FROM pricePerSecond);
```
#### Просмотр своих сделок (поиск по конкретному тикеру, по дате)
```SQL
SELECT s.ticker, h.typeOper, h.dateOper, h.amount, h.quantity, h.commission
FROM history h
INNER JOIN users u
ON u.id = h.idUser
INNER JOIN stocks s
ON s.id = h.idStock
WHERE u.id = 1 AND s.ticker = 'YNDX'; --Поиск по тикеру

SELECT s.ticker, h.typeOper, h.dateOper, h.amount, h.quantity, h.commission
FROM history h
INNER JOIN users u
ON u.id = h.idUser
INNER JOIN stocks s
ON s.id = h.idStock
WHERE u.id = 1 AND dateOper >= '2022-05-01' AND dateOper <= '2022-05-31'; --Поиск по дате
```
