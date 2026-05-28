import os
import json
import boto3
from botocore.exceptions import ClientError

# Récupération sécurisée du nom de la table via la variable d'environnement
TABLE_NAME = os.environ.get("DYNAMODB_TABLE_NAME")
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME) if TABLE_NAME else None

def build_response(status_code, body):
    """Génère une réponse HTTP standardisée pour API Gateway."""
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"  # Utile pour le CORS si nécessaire
        },
        "body": json.dumps(body)
    }

def lambda_handler(event, context):
    # Vérification initiale de la configuration
    if not table:
        return build_response(500, {"error": "Configuration manquante : variable DYNAMODB_TABLE_NAME introuvable."})

    # Routage basé sur la méthode HTTP
    http_method = event.get("httpMethod")
    path_parameters = event.get("pathParameters") or {}
    
    try:
        # 1. GET - Lire un item (Ex: /items/{id}) ou lister si pas d'ID
        if http_method == "GET":
            item_id = path_parameters.get("id")
            if not item_id:
                # Optionnel : scan de la table si aucun ID n'est fourni
                response = table.scan()
                return build_response(200, response.get("Items", []))
            
            response = table.get_item(Key={"id": item_id})
            if "Item" in response:
                return build_response(200, response["Item"])
            return build_response(404, {"error": f"Item {item_id} introuvable."})

        # 2. POST - Créer ou mettre à jour un item (Ex: /items)
        elif http_method == "POST":
            if not event.get("body"):
                return build_response(400, {"error": "Le corps de la requête (body) est vide."})
            
            body = json.loads(event["body"])
            if "id" not in body:
                return build_response(400, {"error": "L'attribut 'id' est requis dans le body."})
            
            table.put_item(Item=body)
            return build_response(201, {"message": "Item créé ou mis à jour avec succès.", "item": body})

        # 3. DELETE - Supprimer un item (Ex: /items/{id})
        elif http_method == "DELETE":
            item_id = path_parameters.get("id")
            if not item_id:
                return build_response(400, {"error": "L'attribut 'id' est requis dans l'URL pour la suppression."})
            
            table.delete_item(Key={"id": item_id})
            return build_response(200, {"message": f"Item {item_id} supprimé avec succès."})

        # Méthode non supportée
        else:
            return build_response(405, {"error": f"Méthode {http_method} non autorisée."})

    except ClientError as e:
        print(f"Erreur AWS: {e.response['Error']['Message']}")
        return build_response(500, {"error": "Une erreur interne AWS est survenue."})
    except Exception as e:
        print(f"Erreur inattendue: {str(e)}")
        return build_response(500, {"error": "Une erreur interne du serveur est survenue."})
