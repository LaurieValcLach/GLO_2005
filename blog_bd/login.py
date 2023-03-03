import pymysql
import pymysql.cursors
from flask import Flask, render_template, request

app = Flask(__name__)
ProfileUtilisateur = {}


@app.route("/")
def main():
    return render_template('login.html')


@app.route("/login", methods=['POST'])
def login():
    courriel = '"' + request.form.get('courriel') + '"'
    passe = request.form.get('motpasse')
    global conn
    conn = pymysql.connect(host='localhost', user='root', password='', db='blog_bd')
    cur = conn.cursor()
    executerFichierSQl("configuration_bd.sql")
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

def executerFichierSQl(nomFichier):
    # lecture brute du fichier SQL
    try:
        fichierSQL = open(nomFichier, 'r').readlines()
    except IOError as e:
        print(e)
    commandesSQL = []
    estCommentaire = False
    estDelimiter = False
    delimitation = ""
    #on veut enlever les commentaires, les DELIMITER, les //
    #et les ; à la fin des DELIMITER (ce dernier optionnel)
    for i, line in enumerate(fichierSQL):
        line = line.strip()
        if ("*/") in line:
            estCommentaire = False
            continue
        if estCommentaire:
            continue
        if ("/*") in line:
            estCommentaire = True
            continue
        if ("#") in line:
            continue
        if ("DELIMITER") in line:
            delimitation += " " + line
            if estDelimiter:
                delimitation = delimitation.replace("//", "")
                delimitation = delimitation.replace("DELIMITER", "")
                delimitation = delimitation[:-1]
                commandesSQL.append(delimitation.strip())
                delimitation = ""
            estDelimiter = not estDelimiter
            continue
        if estDelimiter:
            delimitation += " " + line
            continue

        delimitation += " " + line
        if (";") in line:
            commandesSQL.append(delimitation.strip())
            delimitation = ""
        cur = conn.cursor()
        for i, commande in enumerate(commandesSQL):
            cur.execute(commande)
    print("liste des commandes SQL effectuées:")
    for i, line in enumerate(commandesSQL):
        print(i, line)




if __name__ == "__main__":
    app.run()

