CREATE DATABASE IF NOT EXISTS blog_bd;
USE blog_bd;
DROP TABLE IF EXISTS commenter;
DROP TABLE IF EXISTS associer;
DROP TABLE IF EXISTS suivre;
DROP TABLE IF EXISTS aimer;
DROP TABLE IF EXISTS configurer;
DROP TABLE IF EXISTS publier;
DROP TABLE IF EXISTS commentaire;
DROP TABLE IF EXISTS publication;
DROP TABLE IF EXISTS categorie;
DROP TABLE IF EXISTS profil;
DROP TABLE IF EXISTS compte;
DROP TRIGGER IF EXISTS amour_propre_defendu;
DROP TRIGGER IF EXISTS narcicisme_defendu;
DROP TRIGGER IF EXISTS insert_nb_amis;
DROP TRIGGER IF EXISTS insert_nb_like;
DROP TRIGGER IF EXISTS delete_nb_amis;
DROP TRIGGER IF EXISTS delete_nb_like;
DROP FUNCTION IF EXISTS nouveau_nb_amis;
DROP FUNCTION IF EXISTS nouveau_nb_like;
DROP PROCEDURE IF EXISTS update_all_nb_amis;
DROP PROCEDURE IF EXISTS update_all_nb_like;
DROP PROCEDURE IF EXISTS publier_dans_categorie;
DROP PROCEDURE IF EXISTS supprimer_compte;

CREATE TABLE IF NOT EXISTS compte (
    courriel varchar(50),
    motpasse varchar(12),
    nb_amis  integer,
    PRIMARY KEY (courriel)
);

# format des données à insérer
INSERT INTO compte
VALUES ('alice@ulaval.ca', '12345', 0),
       ('bob@ulaval.ca', 'qwerty', 0),
       ('cedric@ulaval.ca', 'password', 0),
       ('denise@ulaval.ca', '88888888', 0);
/*
 on a les clées qui permettent d'éviter les doublons, soit la combinaison utilisateur
 et ami en plus de les update et de les supprimer si ils sont supprimés dans la table compte,etc.
 cela nous permet aussi de s'assurer que l'utilisateur est toujours associé à un ami (dans la table suivre) sans pour
 autant qu'il ait besoin de suivre qqun (être dans la table suivre). c'est le même principe pour les amis,
 ils doivent nécessairement être associés à un compte.
 */
/*
 ici on a une entitée faible qui est liée au compte et à la catégorie
 techniquement on devrait mettre aussi le courriel dans la publication, il est
 en double techniquement, mais jsp comment faire d'autre
 */
CREATE TABLE IF NOT EXISTS publication(
    id int AUTO_INCREMENT,
    nb_like int,
    date DATE,
    courriel varchar(50),
    PRIMARY KEY (id, courriel),
    FOREIGN KEY (courriel)
    REFERENCES compte(courriel)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS categorie(
    nom_categorie varchar(50),
    date DATE,
    PRIMARY KEY (nom_categorie)
);
#modifier
CREATE TABLE IF NOT EXISTS commentaire(
    id int AUTO_INCREMENT,
    date DATE,
    id_publication integer,
    PRIMARY KEY (id, id_publication),
    FOREIGN KEY (id_publication)
    REFERENCES publication(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);
#je crois que le profil devrait exister seulement si le compte existe également
CREATE TABLE IF NOT EXISTS profil(
    surnom varchar(20),
    date DATE,
    courriel varchar(50),
    PRIMARY KEY (surnom, courriel),
    FOREIGN KEY (courriel)
    REFERENCES compte(courriel)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS commenter
(
    id_commentaire int,
    id_publication int,
    couleur_texte enum('noir', 'gris', 'bleu', 'vert', 'rouge'),
    contenu varchar(500),
    police enum('calibri', 'times', 'arial'),
    PRIMARY KEY (id_commentaire,id_publication),
    FOREIGN KEY (id_commentaire)
    REFERENCES commentaire(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (id_publication)
    REFERENCES publication(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS associer
(
    courriel varchar(50),
    id int,
        PRIMARY KEY (courriel, id),
    FOREIGN KEY (courriel)
        REFERENCES compte(courriel)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (id)
        REFERENCES commentaire(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

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

CREATE TABLE IF NOT EXISTS aimer
(
    courriel varchar(50),
    id int,
    PRIMARY KEY (courriel, id),
    FOREIGN KEY (courriel)
        REFERENCES compte(courriel)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (id)
        REFERENCES publication(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS configurer
(
    courriel varchar(50),
    surnom varchar(20),
    avatar varchar(25),
    couleur varchar(15),
    animal varchar(15),
    PRIMARY KEY (courriel, surnom),
    FOREIGN KEY (courriel)
        REFERENCES compte(courriel)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (surnom)
        REFERENCES profil(surnom)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS publier
(
    courriel      varchar(50),
    nom_categorie varchar(50),
    id            int,
    contenu varchar(500),
    police enum('calibri', 'times', 'arial'),
    PRIMARY KEY (courriel, nom_categorie, id),
    FOREIGN KEY (courriel)
        REFERENCES compte(courriel)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (nom_categorie)
        REFERENCES categorie(nom_categorie)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (id)
        REFERENCES publication(id)
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
    END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER IF NOT EXISTS narcicisme_defendu
    BEFORE INSERT ON aimer
    FOR EACH ROW
    BEGIN
        DECLARE _courriel varchar(50);
        SELECT courriel INTO _courriel FROM publier P WHERE NEW.id = P.id GROUP BY courriel;
        IF _courriel = NEW.courriel THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'On ne peut pas aimer sa propre publication malheureusement.';
        END IF;
    END //
DELIMITER ;

/*CALL publier_dans_categorie('alice@ulaval.ca', 'animaux', 'allo', 'arial', '2023-03-09');
INSERT INTO aimer VALUES ('alice@ulaval.ca', 1);
SELECT courriel FROM aimer A WHERE
    (SELECT id FROM publication P WHERE A.id = P.id) = 'alice@ulaval.ca';
SELECT * FROM publication;
SELECT * FROM publier;
SELECT * FROM aimer;*/
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

DELIMITER //
CREATE TRIGGER IF NOT EXISTS insert_nb_like
    AFTER INSERT ON aimer
    FOR EACH ROW
    BEGIN
        UPDATE publication P SET P.nb_like = (SELECT nouveau_nb_like(NEW.id)) WHERE (P.id = NEW.id);
    END //
DELIMITER ;
#SELECT nouveau_nb_amis('alice@ulaval.ca') from compte where courriel = 'alice@ulaval.ca';
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

DELIMITER //
CREATE TRIGGER IF NOT EXISTS delete_nb_like
    AFTER DELETE ON aimer
    FOR EACH ROW
    BEGIN

        UPDATE publication P SET P.nb_like = (SELECT nouveau_nb_like(OLD.id)) WHERE (P.id = OLD.id);
    END //
DELIMITER ;

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

/*
 permet de renvoyer le nombre d'amis pour un utilisateur donné
 */
DELIMITER //
CREATE FUNCTION IF NOT EXISTS nouveau_nb_amis  (courriel varchar(100))
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

DELIMITER //
CREATE FUNCTION IF NOT EXISTS nouveau_nb_like (id_publication integer)
RETURNS integer
BEGIN
    DECLARE decompte INTEGER;
    SELECT nb_like INTO decompte
                   FROM (SELECT P.id, COUNT(*) AS nb_like
                         FROM aimer A, publication P
                         WHERE A.id = P.id GROUP BY P.id) N
                   WHERE N.id = id_publication;
    IF decompte IS NULL THEN
        RETURN 0;
    ELSE
        RETURN decompte;
    END IF;
END//
DELIMITER ;



/*
SELECT nb_amis from (SELECT utilisateur, COUNT(*) AS nb_amis FROM suivre, compte WHERE courriel = suivre.utilisateur GROUP BY utilisateur) N WHERE N.utilisateur = 'alice@ulaval.ca';
CREATE TEMPORARY TABLE IF NOT EXISTS nb_amis_compte (SELECT utilisateur, COUNT(*) AS nb_amis FROM suivre, compte WHERE courriel = suivre.utilisateur GROUP BY utilisateur);
SELECT nouveau_nb_amis('bob@ulaval.ca');
SELECT nouveau_nb_amis('alice@ulaval.ca');
SELECT nouveau_nb_amis('cedric@ulaval.ca');
DROP TABLE test;*/

#DROP trigger before_delete_compte;
#show triggers ;

/*SELECT * FROM compte;
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
DELETE FROM suivre WHERE utilisateur = 'alice@ulaval.ca';*/


/*SELECT nouveau_nb_amis('alice@ulaval.ca');
SELECT nouveau_nb_amis('bob@ulaval.ca');*/

/*
 ici je crois qu'il faut créer une procédure avec un curseur pour traiter le problème plus haut.
 on veut créer une nouvelle table qui contient tous les votes mis à jour. Je n'arrive pas à faire la modif automatiquement,
 car la procédure pour delete fait une modif en même temps (du moins je pense)

 bref, à faire seulement après dans une commande apart l'on supprime un compte
 */

DELIMITER //
CREATE PROCEDURE update_all_nb_amis ()
BEGIN
    DECLARE var_courriel varchar(50);
    DECLARE var_nbamis varchar(50);
    DECLARE tab_vide int(1);
    DECLARE lecture_termine integer DEFAULT FALSE;
    DECLARE curseur CURSOR FOR SELECT utilisateur, count(*) AS nb_amis FROM suivre GROUP BY utilisateur;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET lecture_termine = TRUE;
    OPEN curseur;
    SET tab_vide = 1;
    lecteur: LOOP
        #CREATE TABLE IF NOT EXISTS liste (utilisateur varchar(100), nb_amis integer);
        FETCH curseur INTO var_courriel, var_nbamis;
        IF lecture_termine THEN
            # si le compte n'existe plus et qu'il n'y a rien dans suivre, donc il n'y a rien dans curseur (tab_vide = 1)
            IF tab_vide = 1 THEN
                UPDATE compte C SET C.nb_amis = 0 WHERE C.nb_amis <> 0;
            END IF ;
            LEAVE lecteur;
        END IF ;
        UPDATE compte C SET C.nb_amis = var_nbamis WHERE C.courriel = var_courriel;
        SET tab_vide = 0;
        #INSERT INTO liste VALUES (var_courriel, var_nbamis);
    END LOOP lecteur;
    CLOSE curseur;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE update_all_nb_like()
BEGIN

    DECLARE _nb_like integer;
    DECLARE _id varchar(50);
    DECLARE tab_vide int(1);
    DECLARE lecture_termine integer DEFAULT FALSE;
    DECLARE curseur CURSOR FOR SELECT id, count(*) AS nb_like FROM aimer GROUP BY id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET lecture_termine = TRUE;
    OPEN curseur;
    SET tab_vide = 1;
    lecteur: LOOP
        FETCH curseur INTO _id, _nb_like;
        IF lecture_termine THEN
            # si le compte n'existe plus, la table aimer est vide, donc il n'y a rien dans curseur (tab_vide = 1)
            IF tab_vide = 1 THEN
                UPDATE publication P SET P.nb_like = 0 WHERE P.nb_like <> 0;
            END IF;
            LEAVE lecteur;
        END IF ;
        UPDATE publication P SET P.nb_like =_nb_like WHERE P.id = _id;
        SET tab_vide = 0;
    END LOOP lecteur;
    CLOSE curseur;
END //
DELIMITER ;



#CALL after_delete_update_nb_amis();


/*SELECT utilisateur, count(*) AS nb_amis FROM suivre GROUP BY utilisateur;
show triggers ;*/

/*
 on voudrait ajouter une relation publier dans une catégorie, on voudrait afficher les catégories,
 on voudrait voir les utilisateurs pour pouvoir les suivre, on voudrait voir les publications d'un utilisateur
 pourquoi danc ce cas on suit des utilisateurs si on a des catégories? j'imagine que c'est pour avoir
 plus d'affaires à coder, mais ça peut être vu comme l'équivalent d'un hashtag, faique c'est correct aussi

 ok, ben dans ce cas,  se serait intéressant de mettre des layers par-dessus ça:
 il faut publier dans une catégorie. on a pas de page personnelle. Mais, on peut suivre des gens et donc voir
 ce qu'ils ont publié dans leur catégorie...il nous faut donc une relation suivre entre compte: rôle utilisateur,
 rôle ami (déjà fait). Il nous faut une relation publier pour publier: (entre compte et publication).
 Est-ce mieux d'avoir une relation trinaire pour définir la relation compte-publication-catégorie où peut-on
 simplement des catégories comme attribut? le premier problème de l'attribut c'est qu'on ne stocke pas la liste
 des catégories qui sont en soient des entitées qu'on affiche sur le site. La relation trinaire, je crois
 que c'est plus intuitif, car on peut définir des catégories sans pour autant qu'il y ait des publications en relation
 comment est-ce qu'on code une relation trinaire?? la question qu'on doit se poser, c'est quels sont les attributs
 de chacuns...si ils ont des attributs différents, il conviendrait peut-être mieux d'utiliser une agrégation,
 sinon une relation trinaire est plus adéquate pour représenter.

 le compte a: courriel comme primary key, la publication aussi (on doit savoir qui l'a fait), mais pas la catégorie
 donc il vaudrait mieux ici de faire une agrégation, mais encore, tu ne peux pas publier sans que se soit dans une
 catégorie, donc ils partagent tous un ID, un courriel et un ID_catégorie (comme l'exemple dans l'exam avec la date)

 par contre, on peut faire une relation entre courriel et publication et faire une agrégation pour catégorie, mais ça
 n'a plus ou moins de sens de faire une agrégation avec publier, quand

 finalement c'est une relation trinaire qu'on fait, c'est plus simple comme ça
 */
/*SHOW TABLES ;

INSERT INTO categorie(nom_categorie) VALUES ('animaux');
INSERT INTO publication(contenu) VALUES ( 'allo');
INSERT INTO publier(courriel, nom_categorie, id) VALUES ( 'alice@ulaval.ca', 'animaux', 1);

SELECT * FROM publier;
SELECT * FROM categorie;
SELECT * FROM publication;
SELECT * FROM compte;

DELETE FROM publication WHERE id=2;*/

/*
 mais, l'affaire, il faut voir l'accès si il est valide, on ne peut pas publier une publication au nom de qqun d'autre, j'imagine
 ici qu'on va avoir besoin de le définir dans publier: si je publie, ca veut dire que je prends le courriel du compte,
 le nom de la catégorie dans laquelle elle est publiée et je prend le ID de la publication:
 1) écrire le message qu'on veut publier, l'ajouter dans publication
 2) choisir un nom de catégorie dans laquelle on publie (dans la table catégorie)
 3) ajouter le lien vers le message (le ID) avec la relation publier pour pouvoir retracer qui l'a écrite et dans quelle
    catégorie
 4) il faudrait vérifier aussi que lorsque j'ajoute une publication, que nous devons passer par la procédure (contrôle d'accès)
 */
DELIMITER //
CREATE PROCEDURE publier_dans_categorie (IN _courriel varchar(50), IN _nom_categorie varchar(50), IN _contenu varchar(500),
IN _police enum('calibri', 'times', 'arial'), IN _date DATE)
BEGIN
/*    DECLARE var_courriel varchar(50);
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
    CLOSE curseur;*/
    DECLARE _id INTEGER;
    DECLARE categorie_valide int(1);
    DECLARE CONTINUE HANDLER FOR SQLSTATE '45000'
        SET categorie_valide = 0;
    SET categorie_valide = 1;
    # on veut publier dans une catégorie qui existe sinon on l'envoie dans la catégorie qu'on veut la mettre
    IF (SELECT(nom_categorie) FROM categorie C WHERE _nom_categorie = C.nom_categorie) IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'catégorie inexistante';
    END IF;
    # on ajoute dans une nouvelle catégorie (celle spécifiée) pour éviter de faire planter le programme
    IF categorie_valide = 0 THEN
        #IF (SELECT(nom_categorie) FROM categorie C WHERE 'autre' = C.nom_categorie) IS NULL THEN
        INSERT INTO categorie VALUES (_nom_categorie, _date);
        #END IF;
        #SET _nom_categorie = 'autre';
    END IF;
    # on ajoute d'abord la publication et on retrace l'id pour la mettre dans la relation suivre
    INSERT INTO publication(nb_like, date, courriel) VALUES (0,_date, _courriel);
    SELECT MAX(P.id) INTO _id FROM publication P;
    INSERT INTO publier(courriel, nom_categorie, id, contenu, police) VALUES (_courriel, _nom_categorie, _id, _contenu, _police);
END //
DELIMITER ;


# quand on supprime un compte, on doit mettre à jour tous les nb_amis et nb_like (s'assurant que tout est correct)
DELIMITER //
CREATE PROCEDURE supprimer_compte (IN _courriel varchar(50))
    BEGIN
        DELETE FROM compte WHERE courriel = _courriel;
        CALL update_all_nb_amis();
        CALL update_all_nb_like();
    END //
DELIMITER ;


/*#SELECT MAX(P.id) FROM publication P;

CALL publier_dans_categorie('alice@ulaval.ca', 'animaux', 'allo', 'arial', '2023-03-09');
CALL publier_dans_categorie('cedric@ulaval.ca', 'animaux', 'allo', 'arial', '2023-03-10');


#INSERT INTO aimer value ('alice@ulaval.ca', 1);

INSERT INTO aimer value ('bob@ulaval.ca', 1);
INSERT INTO aimer value ('denise@ulaval.ca', 1);
INSERT INTO aimer value ('bob@ulaval.ca', 2);
INSERT INTO suivre value ('alice@ulaval.ca', 'bob@ulaval.ca');
INSERT INTO suivre value ('cedric@ulaval.ca', 'bob@ulaval.ca');
#CALL supprimer_compte('bob@ulaval.ca');
CALL supprimer_compte('cedric@ulaval.ca');
#CALL update_all_nb_amis();
SELECT * FROM suivre;
SELECT * FROM compte;
SELECT * FROM publier;
SELECT * FROM categorie;
SELECT * FROM publication;
SELECT * FROM aimer;
#SELECT utilisateur, count(*) AS nb_amis FROM suivre GROUP BY utilisateur;
SELECT nouveau_nb_like(1);

DELETE FROM aimer WHERE courriel = 'bob@ulaval.ca';
SELECT * FROM aimer;
SELECT * FROM publication;*/
