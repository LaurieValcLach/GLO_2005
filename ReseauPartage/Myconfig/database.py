"""
Connection a la base de donnee
"""
import mysql.connector


def database_connection():
    connection = mysql.connector.connect(
        host="localhost",
        user="root",
        password="password",
        database="mydatabase"
    )
    return connection


