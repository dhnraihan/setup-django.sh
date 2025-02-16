#!/bin/bash

# Exit immediately if any command fails
set -e  

# Check if both project name and app name are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo ""
    echo "❌ Usage: ./setup_django.sh project_name app_name"
    echo ""
    exit 1
fi

# Set project and app names
PROJECT_NAME=$1
APP_NAME=$2

echo ""
echo "🔹 Checking Python version..."
echo ""

python3 --version

echo ""
echo "🔹 Creating Virtual Environment..."
echo ""
mkdir $PROJECT_NAME
cd $PROJECT_NAME
python3 -m venv env
pwd

echo ""
echo "🔹 Activating Virtual Environment..."
echo ""
source env/bin/activate
which python

echo ""
echo "🔹 Installing Django..."
echo ""
pip install django

echo ""
echo "🔹 Creating Django project: $PROJECT_NAME"
echo ""
django-admin startproject $PROJECT_NAME .

echo ""
echo "🔹 Running database migrations..."
echo ""
python manage.py migrate

echo ""
echo "🔹 Creating Django app: $APP_NAME"
echo ""
python manage.py startapp $APP_NAME

# Add the app to INSTALLED_APPS in settings.py
SETTINGS_FILE="$PROJECT_NAME/settings.py"
echo ""
echo "🔹 Adding $APP_NAME to INSTALLED_APPS..."
echo ""
sed -i "/INSTALLED_APPS = \[/a \ \ \ \ '$APP_NAME'," $SETTINGS_FILE

echo ""
echo "🔹 Setting up templates and static files..."
echo ""

# Create templates directory inside the app
mkdir -p $APP_NAME/templates/$APP_NAME

# Create static directory inside the app
mkdir -p $APP_NAME/static/$APP_NAME/css
mkdir -p $APP_NAME/static/$APP_NAME/js
mkdir -p $APP_NAME/static/$APP_NAME/images

# Create base.html in the app's templates
echo "{% block content %}{% endblock %}" > $APP_NAME/templates/$APP_NAME/base.html

# Add import os to settings.py after 'from pathlib import Path'
echo ""
echo "🔹 Adding import os to settings.py..."
echo ""
sed -i "/from pathlib import Path/a import os" $SETTINGS_FILE

# Correcting TEMPLATES 'DIRS' setting to use project-wide templates directory
echo ""
echo "🔹 Configuring templates directory in settings.py..."
echo ""
sed -i "s/'DIRS': \[\],/'DIRS': [os.path.join(BASE_DIR, 'templates')],/" $SETTINGS_FILE

# Create project-wide templates directory
mkdir -p templates

echo ""
echo "🔹 Creating superuser..."
echo ""
python manage.py createsuperuser

echo ""
echo "✅ Django project setup completed successfully!"
echo ""
echo "🚀 Start the development server with:"
echo "cd $PROJECT_NAME && source ../env/bin/activate && python manage.py runserver"
echo ""
python manage.py runserver
