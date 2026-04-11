Write-Host "Iniciando setup do projeto ETL..."

$venvName = ".venv"

# Criar ambiente virtual
if (!(Test-Path $venvName)) {
    Write-Host "Criando ambiente virtual..."
    py -m venv $venvName
} else {
    Write-Host "Ambiente virtual ja existe."
}

# Ativar ambiente virtual
Write-Host "Ativando ambiente virtual..."
& "$venvName\Scripts\Activate.ps1"

# Criar requirements.txt
if (!(Test-Path "requirements.txt")) {
    Write-Host "Criando requirements.txt..."

@"
pandas
numpy
sqlalchemy
psycopg2-binary
python-dotenv
requests
google-cloud-bigquery
pandas-gbq
pyarrow
"@ | Out-File -Encoding utf8 requirements.txt
} else {
    Write-Host "requirements.txt ja existe."
}

# Instalar dependencias
Write-Host "Instalando dependencias..."
py -m pip install --upgrade pip
py -m pip install -r requirements.txt

# Criar .env
if (!(Test-Path ".env")) {
    Write-Host "Criando .env..."

@"
DB_HOST=localhost
DB_PORT=5432
DB_NAME=meubanco
DB_USER=usuario
DB_PASSWORD=senha

GOOGLE_APPLICATION_CREDENTIALS=./credentials/key.json
GCP_PROJECT_ID=seu-projeto
BQ_DATASET=seu_dataset
"@ | Out-File -Encoding utf8 .env
} else {
    Write-Host ".env ja existe."
}

# Criar .gitignore
if (!(Test-Path ".gitignore")) {
    Write-Host "Criando .gitignore..."

@"
.venv/
__pycache__/
*.pyc
.env
*.log
.vscode/
.idea/
.DS_Store
Thumbs.db
credentials/
"@ | Out-File -Encoding utf8 .gitignore
} else {
    Write-Host ".gitignore ja existe."
}

Write-Host "Setup concluido com sucesso!"