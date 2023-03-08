import pymysql
import pymysql.cursors


from flask import Flask, render_template, request

from GLO_2005.blog_bd.lecture_fichier import executerFichierSQl

app = Flask(__name__)
ProfileUtilisateur = {}


@app.route("/")
def main():
    return render_template('login.html')


@app.route("/login", methods=['POST'])
def login():
    courriel = '"' + request.form.get('courriel') + '"'
    passe = request.form.get('motpasse')
    conn = pymysql.connect(host='localhost', user='root', password='', db='blog_bd')
    cur = conn.cursor()
    executerFichierSQl("configuration_bd.sql", conn)
    cmd = 'SELECT motpasse FROM compte WHERE courriel=' + courriel + ';'
    cur.execute(cmd)
    passeVrai = cur.fetchone()

    if (passeVrai != None) and (passe == passeVrai[0]):
        cmd = 'SELECT * FROM compte WHERE courriel=' + courriel + ';'
        cur = conn.cursor()
        cur.execute(cmd)
        info = cur.fetchone()

        global ProfileUtilisateur
        ProfileUtilisateur["courriel"] = courriel
        ProfileUtilisateur["nom"] = info[2]
        ProfileUtilisateur["avatar"] = info[3]
        return render_template('bienvenu.html', profile=ProfileUtilisateur)

    return render_template('login.html', message="Informations invalides!")






if __name__ == "__main__":
    app.run()

