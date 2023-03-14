"""
Hachage du mot de passe de l'utilisateur
Class Hash_mdp
return : mot de passe hacher
"""
import bcrypt
import re

from ReseauPartage.Myconfig.database import database_connection

class Password:
    def __init__(self, password):
        self.password = password.encode('utf-8')


    def hash(self):
        return bcrypt.hashpw(self.password, bcrypt.gensalt()).decode('utf-8')

    def validate(self):
        while True:
            password = raw_input("Enter a password: ")
            if len(password) < 8:
                return False
            elif re.search('[0-9]', password) is None:
                return False
            elif re.search('[A-Z]', password) is None:
                return False
            elif re.search('[a-z]', password) is None:
                return False
            else:
                return True
                break
        return bcrypt.checkpw(self.password, self.hashed_password)



