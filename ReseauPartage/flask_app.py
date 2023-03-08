from flask import Flask, render_template
from routes import login, home, profil

app = Flask(__name__)
ProfileUtilisateur = {}


@app.route("/")
def main():
    return render_template('login.html')


@app.route("/login", methods=['POST'])
def login_route():
    return login.login()

@app.route("/home")
def home_route():
    return home.home()

@app.route("/profil")
def profil_route():
    return profil.profil()


if __name__ == "__main__":
    app.run(port=8080)
