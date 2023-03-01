from faker import Faker
import bcrypt

fake = Faker()

data = []
for i in range(100):
    courriel = fake.email()
    nom = fake.name()
    password = fake.password().encode('utf-8') # ne sera pas stock dans la base de donnee
# on l'encode avec utf-8 byte
    password_hash = bcrypt.hashpw(password, bcrypt.gensalt())

## reste a matcher avec mysql