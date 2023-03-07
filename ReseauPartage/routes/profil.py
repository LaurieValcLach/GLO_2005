from flask import render_template

def profil():
    return render_template('bienvenu.html', name="profil personnel")