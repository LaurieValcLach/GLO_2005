"""
Connection a la base de donnee
"""
import mysql.connector

connection = mysql.connector(
        host = "",
        user = "",
        password = ""
)
cursor = connection.cursor()
