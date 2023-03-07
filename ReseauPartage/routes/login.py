import bcrypt
from flask import render_template

def login():
    courriel = '"' + request.form.get('courriel') + '"'
    passe = request.form.get('motpasse')

    # validation du mot de passe pas au point
    password = passe.encode('utf-8')  # bcrypt prend en entree une sequence d'octets
    password_hash = bcrypt.hashpw(password, bcrypt.gensalt())

    conn = pymysql.connect(host='localhost', user='', password='', db='Projet_GLO2005')
    cmd = 'SELECT motpasse FROM utilisateurs WHERE courriel=' + courriel + ';'
    cur = conn.cursor()
    cur.execute(cmd)
    passeVrai = cur.fetchone()

    if (passeVrai != None) and (password_hash == passeVrai[0]):
        cmd = 'SELECT * FROM utilisateurs WHERE courriel=' + courriel + ';'
        cur = conn.cursor()
        cur.execute(cmd)
        info = cur.fetchone()

        global ProfileUtilisateur
        ProfileUtilisateur["courriel"] = courriel
        ProfileUtilisateur["nom"] = info[2]
        ProfileUtilisateur["avatar"] = info[3]
        return render_template('bienvenu.html', profile=ProfileUtilisateur)
    return render_template('login.html', message="Informations invalides!")
