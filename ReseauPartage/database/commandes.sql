CREATE DATABASE testdb;
USE testdb;
CREATE TABLE Utilisateurs
(
    courriel varchar(50),
    motpasse varchar(100),
    nom      varchar(20),
);

SELECT * FROM Utilisateurs;