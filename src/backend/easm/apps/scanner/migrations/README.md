Django expects every app to have a migrations directory
Without it, Django will complain when running makemigrations or migrate
The empty migration prevents Django from trying to create tables for this app
