# Challenge #2 — VPC complet avec subnets publics et privés

## Objectif

Construire un réseau AWS isolé et réutilisable pour les prochains challenges :

- 1 VPC custom (pas le VPC par défaut),
- 2 subnets publics dans 2 AZ,
- 2 subnets privés dans les mêmes 2 AZ,
- 1 Internet Gateway,
- 1 route table publique + 1 route table privée,
- associations des subnets aux bonnes route tables.

## Ce qui a été fait

### 1) Provider et backend

- Provider AWS configuré dans `provider.tf` avec :
	- `required_version = ">= 1.6.0"`
	- provider `hashicorp/aws` en `~> 5.0`
	- région variabilisée via `var.aws_region`.
- Backend S3 configuré dans `backend.tf` avec verrouillage DynamoDB (`terraform-locks`).

### 2) Variables et paramétrage

Dans `variables.tf`, les éléments suivants sont variabilisés :

- `aws_region`
- `project`
- `environment`
- `vpc_cidr_block`
- `az_count`
- `subnet_newbits`

Ce paramétrage permet d’adapter rapidement le challenge à un autre environnement.

### 3) Création réseau (dans `main.tf`)

- AZ récupérées dynamiquement via `data "aws_availability_zones" "available"`.
- Sélection des AZ via `slice(...)` selon `az_count`.
- Calcul des CIDR des subnets avec `cidrsubnet()` (pas de hardcoding).
- VPC créé avec DNS activé (`enable_dns_hostnames` et `enable_dns_support`).
- Subnets publics créés avec `map_public_ip_on_launch = true`.
- Subnets privés créés avec `map_public_ip_on_launch = false`.
- Internet Gateway attachée au VPC.
- Route table publique avec route `0.0.0.0/0` vers l’IGW.
- Route table privée sans route Internet.
- Associations route tables ↔ subnets réalisées.

## État des livrables

### ✅ Implémenté

- VPC custom + 4 subnets (2 publics / 2 privés) pilotés dynamiquement.
- Routage public vers IGW et routage privé isolé.

### 🟡 À finaliser

- Ajouter les outputs demandés par le challenge :
	- `vpc_id`
	- `public_subnet_ids`
	- `private_subnet_ids`
- Corriger le format de la `key` backend (elle est bien ajoutée, mais la valeur actuelle provoque une erreur S3).
	Recommandation : utiliser une clé simple comme `challenge-02/terraform.tfstate` (sans `../` ni `#`).

## Pourquoi la route table privée n’a pas de route IGW ?

Un subnet privé ne doit pas être directement exposé à Internet.
Si des instances privées doivent sortir pour mises à jour, on ajoutera plus tard un **NAT Gateway** (dans un subnet public), puis une route `0.0.0.0/0` de la table privée vers ce NAT.

## Commandes utiles

```bash
terraform fmt -recursive
terraform validate
terraform plan
terraform apply -auto-approve
```
