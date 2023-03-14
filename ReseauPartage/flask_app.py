from flask import Flask, render_template
from Controllers import Comment, Post, Utilisateurs

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


@app.route("/addPost/", methods=["POST"])
def addPost():
    data = request.json
    postText = data["text"]
    insertPost(postText)
    response = {
        "status": 200
    }
    return jsonify(response)


@app.route("/posts/", methods=["GET"])
def getPosts():
    posts = selectPost()
    response = {
        "status": 200,
        "posts": posts
    }

    return jsonify(response)


if __name__ == "__main__":
    app.run(port=8080)
