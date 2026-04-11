Write-Host "Iniciando deploy do ETL na GCP..."

# =========================
# CONFIG
# =========================
$PROJECT_ID = "seu-projeto"
$REGION = "us-central1"
$REPO = "etl-repo"
$IMAGE_NAME = "etl-job"
$JOB_NAME = "etl-job"

# =========================
# VALIDACOES
# =========================
Write-Host "Verificando gcloud..."
if (!(Get-Command gcloud -ErrorAction SilentlyContinue)) {
    Write-Error "gcloud nao instalado."
    exit 1
}

Write-Host "Verificando docker..."
if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "docker nao instalado."
    exit 1
}

Write-Host "Verificando autenticacao..."
$auth = gcloud auth list --format="value(account)"
if (-not $auth) {
    Write-Error "Voce nao esta autenticado no gcloud."
    exit 1
}

Write-Host "Definindo projeto..."
gcloud config set project $PROJECT_ID

# =========================
# CRIAR REPOSITORIO (se nao existir)
# =========================
Write-Host "Verificando Artifact Registry..."

$repoExists = gcloud artifacts repositories list `
    --filter="name:$REPO" `
    --format="value(name)"

if (-not $repoExists) {
    Write-Host "Criando repositorio..."
    gcloud artifacts repositories create $REPO `
        --repository-format=docker `
        --location=$REGION
}

# =========================
# BUILD DA IMAGEM
# =========================
$IMAGE_URI = "$REGION-docker.pkg.dev/$PROJECT_ID/$REPO/$IMAGE_NAME:latest"

Write-Host "Buildando imagem Docker..."
docker build -t $IMAGE_URI .

# =========================
# PUSH
# =========================
Write-Host "Configurando docker auth..."
gcloud auth configure-docker "$REGION-docker.pkg.dev" -q

Write-Host "Enviando imagem..."
docker push $IMAGE_URI

# =========================
# DEPLOY DO JOB
# =========================
Write-Host "Criando/Atualizando Cloud Run Job..."

gcloud run jobs deploy $JOB_NAME `
    --image $IMAGE_URI `
    --region $REGION `
    --set-env-vars "GCP_PROJECT_ID=$PROJECT_ID" `
    --max-retries 1 `
    --memory 512Mi `
    --cpu 1 `
    --quiet


Write-Host "Deploy concluido com sucesso!"