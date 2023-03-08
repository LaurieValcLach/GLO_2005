function onButtonPublier() {
    var inputElement = document.getElementById("zone-texte")
    var newPublicationText = inputElement.value
    var publicationContainer = document.getElementById("publication")
    var newPublicationElement = document.createElement("div")

    newPublicationElement.innerText = newPublicationText
    publicationContainer.appendChild(newPublicationElement)
}
