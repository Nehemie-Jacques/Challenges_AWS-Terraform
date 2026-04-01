# Challenge #1 — Bootstrap du State Terraform (S3 + DynamoDB)

## Objectif

Mettre en place un backend Terraform distant, sécurisé et partageable pour stocker le `terraform.tfstate` dans AWS.

Ce challenge pose les bases d’un projet IaC propre :

- stockage du state dans **S3**,
- verrouillage du state avec **DynamoDB**,
- préparation à un travail en équipe (state centralisé et lock).

## Ce qui a été fait

### 1) Initialisation du projet Terraform

- Provider AWS défini avec contrainte de version.
- Région AWS externalisée via variable (`aws_region`).

### 2) Création du bucket S3 pour le state

- Bucket dédié au state Terraform (`aws_s3_bucket`).
- Versioning activé (`aws_s3_bucket_versioning`).
- Chiffrement serveur AES-256 activé (`aws_s3_bucket_server_side_encryption_configuration`).
- Accès public entièrement bloqué (`aws_s3_bucket_public_access_block`).

### 3) Création de la table DynamoDB de lock

- Table DynamoDB créée (`aws_dynamodb_table`).
- Mode `PAY_PER_REQUEST` pour rester simple et compatible Free Tier.
- Clé de partition : `LockID` (type `S`) pour le verrouillage Terraform.

### 4) Préparation du backend distant

- Fichier `backend.tf` préparé avec un backend `s3`.
- Paramètres attendus : `bucket`, `key`, `region`, `dynamodb_table`, `encrypt = true`.

### 5) Processus de bootstrap

Ordre d’exécution recommandé :

1. `terraform init -backend=false`
2. `terraform apply` (création du bucket + table)
3. ajout/configuration de `backend.tf`
4. `terraform init -reconfigure -migrate-state`

## Livrables attendus

- `terraform state list` fonctionne sans erreur.
- Le state est stocké dans S3 (remote backend actif).
- Le lock de state est assuré par DynamoDB.

## Remarques

- Le nom du bucket S3 doit être **globalement unique** et en minuscules.
- Les valeurs sensibles (identifiants AWS, variables privées) ne doivent jamais être commitées.
