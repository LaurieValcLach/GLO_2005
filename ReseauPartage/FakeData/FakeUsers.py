from faker import Faker
from ReseauPartage.Myconfig.Password import Password
from ReseauPartage.Myconfig.database import database_connection
import random
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
cursor = connect.cursor()

"""
    generation de 100 donnees aleatoire utilisant la librairie faker
    
    Courriel : varchar(50)
    
    nom : varchar(20)
    
    motpasse : varchar(60), l'algorithme de hashage bcrypt creer generalement une chaine de 60 characteres.
    l'utilisateur devra toutefois entrer un mot de passe d'une longueur maximale de 12 characteres.
    Nous laissons la valeur par defaut de 12 rounds pour le hashage pour atteindre la meilleure balance performance/securite.
    
"""
random.seed(42)

for i in range(100):
    courriel = next(fake_email(50))
    nom = next(fake_name(20))
    password = next(fake_password(12))
    password_object = Password(password)
    password_hash = password_object.hash()
    insert_stmt = "INSERT INTO Utilisateurs (courriel, motpasse, nom) VALUES (%s, %s, %s)"
    data = (courriel, password_hash, nom)
    cursor.execute(insert_stmt, data)

# Sauvegarde des changements apportes a la BD
connect.commit()

# ferme la connection avec la BD
connect.close()
