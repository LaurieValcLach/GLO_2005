USE blog_bd;

#commande pour publier
CALL publier_dans_categorie(
    'alice@ulaval.ca',
    'animaux',
    'allo',
    'arial',
    '2023-03-09'
);
# commande pour supprimer un compte
CALL supprimer_compte('cedric@ulaval.ca');

# pour le reste des commandes c'est assez simple, mais les faire de manière exhaustive
# c'est un peu long. cependant, il faut utiliser les fonctions plus haut pour publier et supprimer