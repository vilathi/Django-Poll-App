import os
import django
from django.contrib.auth import get_user_model

# Configuración de Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'pollme.settings')
django.setup()

User = get_user_model()

# Verificación de la existencia del superusuario
username = os.getenv('DJANGO_SUPERUSER_USERNAME')
email = os.getenv('DJANGO_SUPERUSER_EMAIL')
password = os.getenv('DJANGO_SUPERUSER_PASSWORD')

if not User.objects.filter(username=username).exists():
    print(f"Creating superuser: {username}")
    User.objects.create_superuser(username=username, email=email, password=password)
else:
    print(f"Superuser {username} already exists")