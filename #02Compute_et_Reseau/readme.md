# Section #02 — Compute et Réseau (AWS)

## Overview

Cette deuxième section se concentre sur les services de calcul (Compute) et la mise en réseau (Networking) avancée sur AWS avec Terraform. Elle fait suite aux fondations établies dans la première partie et aborde des architectures robustes et hautement disponibles, telles que l'on retrouve dans des environnements de production d'entreprise. 

Les compétences clés incluent la gestion des Auto Scaling Groups, la sécurisation des accès sans bastion public (SSM), la haute disponibilité réseau et la distribution globale de contenu.

## Challenges Summary

### [Challenge #6 : 3-Tier Architecture: ALB + Auto Scaling Group + RDS](./challenge%236/Readme.md)
**Focus :** Architecture Haute Disponibilité & Résilience
Création d'une infrastructure "3 tiers" classique : une couche de présentation avec un Application Load Balancer (ALB), une couche logique avec des instances EC2 dans un Auto Scaling Group (ASG) réparties sur plusieurs zones de disponibilité, et une couche de données avec Amazon RDS sécurisée dans des sous-réseaux privés.

### [Challenge #7 : Secure Bastion Host with SSM Session Manager (No SSH)](./challenge%237/Readme.md)
**Focus :** Sécurité opérationnelle.
Remplacement des points d'accès SSH vulnérables (Bastion sur IP publique) par AWS Systems Manager (SSM). Mise en place d'accès complets et sécurisés aux instances privées via des terminaux sans avoir à ouvrir le port 22 ni exposer les ressources à internet internet, supporté par des endpoints VPC.

### [Challenge #8 : Highly Available NAT Gateway (Multi-AZ)](./challenge%238/Readme.md)
**Focus :** Connectivité sortante et tolérance aux pannes réseau.
Déploiement de passerelles NAT pour permettre aux sous-réseaux privés d'accéder à internet pour les mises à jour, de manière hautement disponible (une par Availability Zone), complétant l'architecture avec un routage précis évitant un Single Point of Failure (SPOF).

### [Challenge #9 : CloudFront CDN with S3 Static Website & OAC](./challenge%239/Readme.md)
**Focus :** Sécurité du stockage et Content Delivery Network.
Optimisation et sécurisation d'un hébergement S3 existant en le plaçant derrière AWS CloudFront pour de meilleures performances globales (CDN). Implémentation de Origin Access Control (OAC) afin de s'assurer que le bucket S3 refuse tout trafic direct non acheminé via CloudFront.

### [Challenge #10 : AWS VPC Peering & Connectivité Inter-Réseaux](./challenge%2310/Readme.md)
**Focus :** Hybridation réseau et isolation d'environnements.
Création de deux VPC distincts (App et Tools) afin de simuler l'isolation d'environnements, joints par une connexion de VPC Peering. Mise en place d'un routage de bout en bout et de Security Groups stricts permettant le flux ICMP exclusif entre ces deux réseaux fermés.
