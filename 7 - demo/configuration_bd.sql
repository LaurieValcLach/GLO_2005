CREATE DATABASE IF NOT EXISTS blog_bd;
USE blog_bd;

CREATE TABLE IF NOT EXISTS compte (
    courriel varchar(50),
    motpasse varchar(12),
    nom      varchar(20),
    avatar   varchar(40),
    nb_amis  integer,
    PRIMARY KEY (courriel)
);
# format des données à insérer
/*INSERT INTO compte
VALUES ('alice@ulaval.ca', '12345', 'Alice', 'MonChat.jpg', 0),
       ('bob@ulaval.ca', 'qwerty', 'Bob', 'Grimlock.jpg', 0),
       ('cedric@ulaval.ca', 'password', 'Cédric', 'smiley.gif', 0),
       ('denise@ulaval.ca', '88888888', 'Denise', 'reine.jpg', 0);*/
/*
 on a les clées qui permettent d'éviter les doublons, soit la combinaison utilisateur
 et ami en plus de les update et de les supprimer si ils sont supprimés dans la table compte,etc.
 cela nous permet aussi de s'assurer que l'utilisateur est toujours associé à un ami (dans la table suivre) sans pour
 autant qu'il ait besoin de suivre qqun (être dans la table suivre). c'est le même principe pour les amis,
 ils doivent nécessairement être associés à un compte.
 */
CREATE TABLE IF NOT EXISTS suivre
    (utilisateur varchar(50),
     ami         varchar(50),
    PRIMARY KEY (utilisateur, ami),
    FOREIGN KEY (utilisateur)
        REFERENCES compte(courriel)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (ami)
        REFERENCES compte(courriel)
        ON DELETE CASCADE
        ON UPDATE CASCADE
    );
/*
 un compte utilisateur ne peut pas se suivre soi-même, on lance une erreur le cas échéant
 */
DELIMITER //
CREATE TRIGGER IF NOT EXISTS amour_propre_defendu
    BEFORE INSERT ON suivre
    FOR EACH ROW
    BEGIN
        IF NEW.ami = NEW.utilisateur THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Son amour à ses limites! On ne peut pas se suivre soit-même';
        END IF;
    END//
DELIMITER ;
/*
 lorsqu'on ajoute un ami dans la liste suivre, on modifie le nombre d'amis
 */
DELIMITER //
CREATE TRIGGER IF NOT EXISTS insert_nb_amis
    AFTER INSERT ON suivre
    FOR EACH ROW
    BEGIN
        #UPDATE compte C SET C.nb_amis = (SELECT count(*) utilisateur FROM suivre GROUP BY NEW.utilisateur)
            #WHERE (C.courriel = NEW.utilisateur);
        UPDATE compte C SET C.nb_amis = (SELECT nouveau_nb_amis(NEW.utilisateur)) WHERE (C.courriel = NEW.utilisateur);
    END //
DELIMITER ;
drop trigger insert_nb_amis;

SELECT nouveau_nb_amis('alice@ulaval.ca') from compte where courriel = 'alice@ulaval.ca';
/*
 lorsqu'on retire un ami ou un utilisateur dans la liste suivre, on modifie le nombre d'amis de l'utilisateur
 */
DELIMITER //
CREATE TRIGGER IF NOT EXISTS delete_nb_amis
    AFTER DELETE ON suivre
    FOR EACH ROW
    BEGIN
        #UPDATE compte C SET C.nb_amis = (SELECT count(*) utilisateur FROM suivre GROUP BY utilisateur)
            #WHERE (C.courriel = OLD.utilisateur);
        #UPDATE compte C SET C.nb_amis = 0 WHERE nb_amis IS NULL;
        UPDATE compte C SET C.nb_amis = (SELECT nouveau_nb_amis(OLD.utilisateur)) WHERE (C.courriel = OLD.utilisateur);
        #UPDATE compte C SET C.nb_amis = (SELECT nb_amis
                   #FROM (SELECT utilisateur, COUNT(*) AS nb_amis
                         #FROM suivre S, compte C
                         #WHERE C.courriel = S.utilisateur GROUP BY utilisateur) N);
    END //
DELIMITER ;
drop trigger delete_nb_amis;
/*
 lorsque l'on supprime un compte, il faut retirer l'utilisateur de la relation suivre avant
 */

/*DELIMITER //
CREATE TRIGGER IF NOT EXISTS before_delete_compte
    BEFORE DELETE ON compte
    FOR EACH ROW
    BEGIN
        DELETE FROM suivre WHERE suivre.utilisateur = OLD.courriel;
    END//
DELIMITER ;
drop trigger before_delete_compte;*/
/*
 après avoir supprimé un compte, il faut modifier le nombre d'amis des autres qui avaient des comptes qui suivaient ce compte...le problème, on a pas accès
 aux utilisateurs qui ont été affectés avec un trigger à cause qu'on a seulement OLD et NEW
 */
/*DELIMITER //
CREATE TRIGGER IF NOT EXISTS after_delete_compte
    AFTER DELETE ON compte
    FOR EACH ROW
    BEGIN
        UPDATE compte C SET C.nb_amis = (SELECT nb_amis
                   FROM (SELECT utilisateur, COUNT(*) AS nb_amis
                         FROM suivre S, compte C
                         WHERE C.courriel = S.utilisateur GROUP BY utilisateur) N);
    END //
DELIMITER ;
drop trigger after_delete_compte;*/


DELIMITER //
CREATE FUNCTION nouveau_nb_amis (courriel varchar(100))
RETURNS INTEGER
BEGIN
    DECLARE decompte INTEGER;
    SELECT nb_amis INTO decompte
                   FROM (SELECT utilisateur, COUNT(*) AS nb_amis
                         FROM suivre S, compte C
                         WHERE C.courriel = S.utilisateur GROUP BY utilisateur) N
                   WHERE N.utilisateur = courriel;
    IF decompte IS NULL THEN
        RETURN 0;
    ELSE
        RETURN decompte;
    END IF;
END //
DELIMITER ;
/*drop function nouveau_nb_amis;
SELECT nb_amis from (SELECT utilisateur, COUNT(*) AS nb_amis FROM suivre, compte WHERE courriel = suivre.utilisateur GROUP BY utilisateur) N WHERE N.utilisateur = 'alice@ulaval.ca';
CREATE TEMPORARY TABLE IF NOT EXISTS nb_amis_compte (SELECT utilisateur, COUNT(*) AS nb_amis FROM suivre, compte WHERE courriel = suivre.utilisateur GROUP BY utilisateur);
SELECT nouveau_nb_amis('bob@ulaval.ca');
SELECT nouveau_nb_amis('alice@ulaval.ca');
SELECT nouveau_nb_amis('cedric@ulaval.ca');
DROP TABLE test;*/

#DROP trigger before_delete_compte;
#show triggers ;

SELECT * FROM compte;
INSERT INTO compte VALUES ('denise@ulaval.ca', '88888888', 'Denise', 'reine.jpg', 0);
INSERT INTO compte VALUES ('bob@ulaval.ca', 'qwerty', 'Bob', 'Grimlock.jpg', 0);
INSERT INTO compte VALUES ('alice@ulaval.ca', '12345', 'Alice', 'MonChat.jpg', 0);
INSERT INTO suivre VALUES ('alice@ulaval.ca', 'bob@ulaval.ca');
INSERT INTO suivre VALUES ('bob@ulaval.ca', 'alice@ulaval.ca');
INSERT INTO suivre VALUES ('alice@ulaval.ca', 'cedric@ulaval.ca');
SELECT * FROM suivre;
DELETE FROM compte WHERE courriel = 'bob@ulaval.ca';
DELETE FROM compte WHERE courriel = 'alice@ulaval.ca';
DELETE FROM suivre WHERE ami = 'bob@ulaval.ca';
DELETE FROM suivre WHERE ami = 'alice@ulaval.ca';
DELETE FROM suivre WHERE ami = 'cedric@ulaval.ca';
DELETE FROM suivre WHERE utilisateur = 'alice@ulaval.ca';


SELECT nouveau_nb_amis('alice@ulaval.ca');
SELECT nouveau_nb_amis('bob@ulaval.ca');

/*
 ici je crois qu'il faut créer une procédure avec un curseur pour traiter le problème plus haut.
 on veut créer une nouvelle table qui contient tous les votes mis à jour. Je n'arrive pas à faire la modif automatiquement,
 car la procédure pour delete fait une modif en même temps (du moins je pense)
 */
DELIMITER //
CREATE PROCEDURE update_all_nb_amis ()
BEGIN
    DECLARE var_courriel varchar(50);
    DECLARE var_nbamis varchar(50);
    DECLARE lecture_termine integer DEFAULT FALSE;
    DECLARE curseur CURSOR FOR SELECT utilisateur, count(*) AS nb_amis FROM suivre GROUP BY utilisateur;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET lecture_termine = TRUE;
    OPEN curseur;
    lecteur: LOOP
        #CREATE TABLE IF NOT EXISTS liste (utilisateur varchar(100), nb_amis integer);
        FETCH curseur INTO var_courriel, var_nbamis;
        IF lecture_termine THEN
            LEAVE lecteur;
        END IF ;
        UPDATE compte C SET C.nb_amis = var_nbamis WHERE C.courriel = var_courriel;
        #INSERT INTO liste VALUES (var_courriel, var_nbamis);
    END LOOP lecteur;
    CLOSE curseur;
END //
DELIMITER ;
drop procedure after_delete_update_nb_amis;


CALL after_delete_update_nb_amis();


SELECT utilisateur, count(*) AS nb_amis FROM suivre GROUP BY utilisateur;
show triggers ;