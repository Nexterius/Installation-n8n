# n8n Automatic Installation Script (Debian 13 + Docker + Ollama + Qwen3:8B)

Script permettant d’installer automatiquement **n8n self-hosted** sur **Debian 13** avec **Docker**, ainsi que **Ollama** et le modèle **Qwen3:8B**.

Ce script automatise l’installation et une première configuration afin d’obtenir rapidement un environnement fonctionnel pour **n8n**, avec un **modèle LLM local accessible depuis le serveur et depuis le conteneur Docker**.

---

# 🚀 Installation

## Méthode classique

Installer les outils nécessaires en root :

apt update

apt install -y sudo git

usermod -aG sudo nom_utilisateur

Reconnectez-vous ensuite avec votre utilisateur normal, puis clonez le dépôt et lancez le script :

git clone https://github.com/Nexterius/Installation-n8n.git

cd Installation-n8n

chmod +x install_n8n.sh

sudo ./install_n8n.sh

---

## ⚡ Installation en une seule commande

Vous pouvez également lancer l’installation directement avec :

bash <(curl -s https://raw.githubusercontent.com/Nexterius/Installation-n8n/main/install_n8n.sh)

---

# 📋 Prérequis

- **Debian 13**
- **Connexion Internet**
- **Accès sudo**
- **Utilisateur normal obligatoire** pour exécuter le script avec `sudo`
- **Serveur propre recommandé**

> Le script refuse de s’exécuter s’il est lancé directement en root.
> Il doit être lancé avec `sudo` depuis un utilisateur classique.

---

# ⚙️ Ce que fait le script

Le script effectue automatiquement les actions suivantes :

## Système

- Passage en mode d’installation non interactif
- Mise à jour du système (`apt update && apt upgrade -y`)
- Installation des dépendances :
  - `ca-certificates`
  - `curl`
  - `gnupg`
  - `openssl`
  - `jq`

## Docker

- Ajout de la clé GPG officielle Docker
- Ajout du dépôt officiel Docker
- Installation de :
  - `docker-ce`
  - `docker-ce-cli`
  - `containerd.io`
  - `docker-buildx-plugin`
  - `docker-compose-plugin`
- Activation et démarrage du service Docker
- Ajout de l’utilisateur au groupe `docker`

> Une reconnexion de session est recommandée après l’installation pour utiliser Docker sans `sudo`.

## n8n

- Création de l’environnement dans `/srv/n8n`
- Création du dossier persistant `/srv/n8n/n8n_data`
- Attribution des permissions nécessaires
- Sauvegarde du fichier `.env` existant dans `.env.backup` s’il est déjà présent
- Génération automatique d’une **clé de chiffrement n8n**
- Création d’un fichier `.env`
- Création d’un fichier `docker-compose.yml`
- Lancement automatique du conteneur n8n avec Docker Compose

## Configuration n8n

Le script génère le fichier `.env` suivant :

N8N_ENCRYPTION_KEY=clé_générée_automatiquement
N8N_SECURE_COOKIE=false

N8N_HOST=localhost
N8N_PORT=5678
N8N_PROTOCOL=http
WEBHOOK_URL=http://localhost:8080/
N8N_DEFAULT_TIMEOUT=7200000

## Ollama

- Installation d’Ollama via le script officiel
- Activation du service au démarrage
- Démarrage du service
- Téléchargement du modèle :

qwen3:8b

- Test local de génération via l’API Ollama

## Intégration n8n ↔ Ollama

Le script configure l’accès entre le conteneur n8n et Ollama :

- Ajout de `host.docker.internal:host-gateway` dans le `docker-compose.yml`
- Redémarrage du conteneur n8n après modification
- Modification du service systemd d’Ollama pour écouter sur toutes les interfaces avec :

OLLAMA_HOST=0.0.0.0

- Rechargement de systemd
- Redémarrage d’Ollama

---

# ✅ Vérifications automatiques

Le script effectue plusieurs vérifications à la fin de l’installation :

- Test de génération local avec Ollama
- Vérification que le port `11434` est bien ouvert
- Vérification de l’accès à l’API Ollama depuis la passerelle Docker
- Vérification de l’accès à l’API Ollama depuis le conteneur n8n

---

# 📁 Arborescence créée

Le script crée l’environnement suivant :

/srv/n8n
├── .env
├── .env.backup (si un .env existait déjà)
├── docker-compose.yml
└── n8n_data/

---

# 🌐 Accès à n8n

## Port exposé sur le serveur

Le conteneur n8n expose le port suivant :

5678

Vous pouvez donc y accéder depuis le réseau local avec :

http://IP_DU_SERVEUR:5678

Exemple :

http://192.168.1.10:5678

## Accès conseillé via tunnel SSH

Le script rappelle également l’utilisation d’un tunnel SSH :

ssh -L 8080:localhost:5678 utilisateur@ip_du_serveur

Puis accéder à n8n depuis votre machine locale via :

http://localhost:8080

> Le message final du script indique `http://localhost:8080`, mais n8n écoute en réalité sur le port `5678` côté serveur.
> Le port `8080` correspond ici à l’usage du **tunnel SSH local**, pas à un port ouvert directement par Docker sur le serveur.

---

# 🤖 Ollama

## API locale

Ollama est accessible localement sur :

http://localhost:11434

## API exposée au réseau

Après modification du service systemd, Ollama écoute sur toutes les interfaces :

0.0.0.0:11434

Cela permet l’accès :

- depuis l’hôte
- depuis le réseau Docker
- depuis le conteneur n8n via `host.docker.internal`

## Modèle installé

qwen3:8b

---

# 🐳 Technologies utilisées

- **Debian 13**
- **Docker Engine**
- **Docker Compose**
- **n8n**
- **Ollama**
- **Qwen3:8B**
- **jq**

---

# 📦 Détails du conteneur n8n

Le script génère le `docker-compose.yml` suivant :

services:
  n8n:
    image: n8nio/n8n:latest
    restart: always
    extra_hosts:
      - "host.docker.internal:host-gateway"
    ports:
      - "5678:5678"
    env_file:
      - .env
    volumes:
      - ./n8n_data:/home/node/.n8n

---

# ⚠️ Points importants

- Script en **version de test**
- **Non validé en production**
- Utilise l’image `n8nio/n8n:latest`
- Définit `N8N_SECURE_COOKIE=false`
- Configure `N8N_HOST=localhost`
- Définit `WEBHOOK_URL=http://localhost:8080/`

> Cette configuration est pratique pour un usage local ou via tunnel SSH, mais elle n’est pas adaptée telle quelle à une mise en production derrière un nom de domaine ou un reverse proxy.

---

# ⚠️ Avertissement

Ce script modifie la configuration du système, notamment :

- les dépôts APT
- Docker
- les groupes utilisateur
- le service systemd d’Ollama
- l’exposition réseau d’Ollama

Il est recommandé de :

- l’exécuter sur un serveur neuf ou de test
- lire le script avant utilisation
- tester dans un environnement de développement avant toute mise en production

---

# 📜 Licence

Projet open-source.
Utilisation libre.

---

# 🔗 À propos de n8n

n8n est une plateforme d’automatisation open-source permettant de connecter différents services et de construire des workflows automatisés.

Site officiel :
https://n8n.io
