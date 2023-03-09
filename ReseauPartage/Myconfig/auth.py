"""
Procédure d'authentification
Requests 
validations avec la BD
"""
from ReseauPartage.Myconfig.Password import Password
from ReseauPartage.Myconfig.database import database_connection


class Authentification:
    def __init__(self):
        self.connect = database_connection()

    def login(self, email, password):
        select_password = "SELECT motpasse FROM Utilisateurs WHERE courriel=%s"
        self.cursor.execute(select_password, email)
        row = self.cursor.fetchone()
        if row is None:
            raise ValueError("email not found")
        hashed_password = row[2]

        password_obj = Password(password)
        is_valid = password_obj.validate(hashed_password)

        if is_valid:
            print("Login successful")
        else:
            print("Invalid password")
    def logout(self):
        pass

    def register(self, email, password, name):
        select_users = "SELECT * FROM Utilisateurs WHERE courriel=%s"
        self.cursor.execute(select_users, email)
        user = self.cursor.fetchone()
        if user is not None:
            raise ValueError("L'utilisateur existe deja")
        password_object = Password(password)
        hashed_password = password_object.hashed_password

        insert_user = "INSERT INTO Utilisateurs (courriel, motpasse, nom) VALUES (%s, %s, %s)"
        data = (email, hashed_password, name)
        self.cursor.execute(insert_user, data)
        self.connect.commit()