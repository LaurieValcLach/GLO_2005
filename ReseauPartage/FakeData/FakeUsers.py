import bcrypt
from faker import Faker

from ReseauPartage.Myconfig.database import database_connection

""" établir une connection avec la base de donnee """
connect = database_connection()

""" Ici on permet d'imposer une longueur de charactere maximale a la generation de donnees """


def fake_email(max_len):
    fake = Faker()
    while True:
        x = fake.email()
        if len(x) <= max_len:
            yield x


def fake_password(max_len):
    fake = Faker()
    while True:
        x = fake.password()
        if len(x) <= max_len:
            yield x


def fake_name(max_len):
    fake = Faker()
    while True:
        x = fake.name()
        if len(x) <= max_len:
            yield x


# creation d'une instance de curseur pour l'insertion des donnees
cursor = madb_connection.cursor()

"""
    generation de 100 donnees aleatoire utilisant la librairie faker
    
    Courriel : varchar(50)
    
    nom : varchar(20)
    
    motpasse : varchar(60), l'algorithme de hashage bcrypt creer generalement une chaine de 60 characteres.
    l'utilisateur devra toutefois entrer un mot de passe d'une longueur maximale de 12 characteres.
    Nous laissons la valeur par defaut de 12 rounds pour le hashage pour atteindre la meilleure balance performance/securite.
    
"""
for i in range(100):
    courriel = next(fake_email(50))
    nom = next(fake_name(20))
    password = next(fake_password(12)).encode('utf-8') # bcrypt prend en entree une sequence d'octets
    password_hash = bcrypt.hashpw(password, bcrypt.gensalt()) # gensalt ajoute une chaine au mot de passe

    insert_stmt = "INSERT INTO Utilisateurs (courriel, motpasse, nom) VALUES (%s, %s, %s)"
    data = (courriel, password_hash.decode('utf-8'), nom)
    cursor.execute(insert_stmt, data)

# Sauvegarde des changements apportes a la BD
madb_connection.commit()

# ferme la connection avec la BD
madb_connection.close()
