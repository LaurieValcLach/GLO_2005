def executerFichierSQl(nomFichier, conn):
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
