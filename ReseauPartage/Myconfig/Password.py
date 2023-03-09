"""
Hachage du mot de passe de l'utilisateur
Class Hash_mdp
return : mot de passe hacher
"""
import bcrypt


class Password:
    def __init__(self, password):
        self.password = password.encode('utf-8')
        self.hashed_password = self.hash()

    def hash(self):
        return bcrypt.hashpw(self.password, bcrypt.gensalt()).decode('utf-8')

    def validate(self):
        if len(self.password) < 5:
            raise ValueError("Le mot de passe est trop court")
        return bcrypt.checkpw(self.password, self.hashed_password)

