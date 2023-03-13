function onButtonPublier() {
    var inputElement = document.getElementById("input")
    var newPostText = inputElement.value
    var postContainer = document.getElementById("publication")
    var newPostElement = document.createElement("div")

    newPostElement.innerText = newPostText
    postContainer.appendChild(newPostElement)

    var url = "addPost"
    fetch(url, {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            text: newPostText
        })
    })

}

function fetchPosts() {
    var getUrl = "posts/"

    fetch(getUrl).then(function (response) {
        return response.json()
    }).then(function (data) {

        let posts = data.posts

        for (let post of posts) {
            var postContainer = document.getElementById("publication")
            var newPostElement = document.createElement("div")
            newPostElement.innerText = post
            postContainer.appendChild(newPostElement)
        }

    })
}
