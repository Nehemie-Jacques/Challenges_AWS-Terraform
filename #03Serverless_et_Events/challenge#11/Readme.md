# Challenge #11 — API REST Serverless (API Gateway REST + Lambda + DynamoDB)

**Niveau :** Intermédiaire | **Services :** API Gateway (REST), Lambda, DynamoDB, IAM, CloudWatch Logs  

## 🎯 Objectif

Mettre en place un microservice serverless classique **API Gateway → Lambda → DynamoDB** avec :
- CRUD basique (GET/POST/DELETE)
- une table DynamoDB en **PAY\_PER\_REQUEST**
- un **rôle IAM minimal**
- un déploiement API Gateway **reproductible** (redeploy auto via `triggers`)
- une **API Key** + Usage Plan pour protéger l’accès

---

## 🏗️ Architecture & implémentation

### 1) DynamoDB (Free tier friendly)
- Table `crud_table`
- Clé de partition `id` (type `S`)
- `billing_mode = "PAY_PER_REQUEST"`

### 2) Lambda (router via `event["httpMethod"]`)
Le code est dans `lambda/handler.py` et :
- lit le nom de la table via la variable d’environnement `DYNAMODB_TABLE_NAME`
- route les requêtes via `event["httpMethod"]`
- gère :
  - `GET /items` : liste (Scan)
  - `GET /items/{id}` : lecture (GetItem)
  - `POST /items` : création/mise à jour (PutItem)
  - `DELETE /items/{id}` : suppression (DeleteItem)

### 3) Packaging ZIP automatisé (Terraform `archive_file`)
La Lambda est packagée automatiquement au plan/apply :
- `data "archive_file" "lambda_zip"` zippe le dossier `lambda/`
- le ZIP est écrit dans `tmp/lambda_function.zip` (ignoré via `.gitignore`)

### 4) IAM minimal (least privilege)
Le rôle Lambda a :
- une trust policy `lambda.amazonaws.com`
- une policy inline limitée à :
  - `dynamodb:GetItem`, `dynamodb:PutItem`, `dynamodb:DeleteItem`, `dynamodb:Scan`
  - **uniquement sur l’ARN de la table**
- l’attachment AWS managé `AWSLambdaBasicExecutionRole` (logs CloudWatch)

### 5) Logs CloudWatch gérés par Terraform
Un `aws_cloudwatch_log_group` est créé avec **7 jours** de rétention.

### 6) API Gateway REST (Lambda Proxy)
Endpoints exposés :
- `GET  /items`
- `POST /items`
- `GET  /items/{id}`
- `DELETE /items/{id}`

Chaque méthode :
- utilise une intégration `AWS_PROXY` vers la Lambda
- impose `api_key_required = true`

### 7) Déploiement + stage `dev`
API Gateway ne redéploie pas automatiquement à chaque changement de méthodes/intégrations.  
On force le redeploy avec un `triggers.redeployment` (hash) sur :
- ressources
- méthodes
- intégrations

### 8) Sécurisation via API Key
- `aws_api_gateway_api_key`
- `aws_api_gateway_usage_plan` (attaché au stage `dev`)
- `aws_api_gateway_usage_plan_key`

---

## ✅ Validation (curl)

```bash
terraform init
terraform apply -auto-approve

API_URL="$(terraform output -raw api_url)"
API_KEY="$(terraform output -raw api_key_value)"

# 1) Créer un item
curl -sS -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $API_KEY" \
  -d '{"id":"1","name":"hello","status":"new"}' | jq

# 2) Lister les items
curl -sS -X GET "$API_URL" \
  -H "x-api-key: $API_KEY" | jq

# 3) Lire un item
curl -sS -X GET "$API_URL/1" \
  -H "x-api-key: $API_KEY" | jq

# 4) Supprimer un item
curl -sS -X DELETE "$API_URL/1" \
  -H "x-api-key: $API_KEY" | jq
```

Si tout est OK :
- tu vois les logs dans CloudWatch Logs (`/aws/lambda/items-crud-lambda`)
- l’API retourne des réponses JSON

---

## 🧠 Questions de réflexion (réponses courtes)

### Pourquoi `AWS_PROXY` plutôt que `AWS` ?
Avec **Lambda Proxy (`AWS_PROXY`)**, API Gateway envoie à la Lambda **l’événement brut** (méthode HTTP, headers, query string, body, path parameters).  
Implication : c’est **ton handler** qui fait le routage et construit une réponse au format attendu (`statusCode`, `headers`, `body`).

### Pourquoi `source_code_hash` est indispensable ?
Terraform ne “devine” pas que ton ZIP a changé.  
`source_code_hash` (basé sur le contenu) permet à Terraform de **détecter une modification du code** et de forcer le redéploiement de la Lambda.

