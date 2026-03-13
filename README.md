# n8n Automatic Installation Script (Debian 13 + Docker + Ollama)

Script permettant d'installer automatiquement **n8n self-hosted** sur **Debian 13** avec **Docker**, ainsi que **Ollama** et un modèle **LLM local (Qwen3:8B)**.

Ce script automatise l'installation et la configuration complète afin d'obtenir rapidement un environnement fonctionnel pour **l'automatisation et l'IA locale avec n8n**.

---

# 🚀 Installation

## Méthode classique (recommandée)

Se connecter avec l'utilisateur root :

apt install -y sudo git
usermod -aG sudo nom_utilisateur

Se reconnecter ensuite avec l'utilisateur.

Cloner le repository puis lancer le script :

git clone https://github.com/Nexterius/Installation-n8n.git

cd Installation-n8n

sudo chmod +x install_n8n.sh

sudo ./install_n8n.sh

---

## ⚡ Installation en une seule commande

Vous pouvez également installer n8n directement avec une seule commande :

bash <(curl -s https://raw.githubusercontent.com/Nexterius/Installation-n8n/main/install_n8n.sh)

---

# 📋 Prérequis

- Debian 13
- Accès sudo
- Connexion internet
- Serveur propre recommandé

---

# ⚙️ Ce que fait le script

Le script effectue automatiquement :

### Système
- Mise à jour du système
- Installation des dépendances nécessaires

### Docker
- Installation de Docker Engine
- Installation de Docker Compose
- Activation du service Docker
- Ajout de l'utilisateur au groupe Docker

### n8n
- Création de l'environnement /srv/n8n
- Génération automatique de la clé de chiffrement n8n
- Création du fichier .env
- Création du docker-compose.yml
- Lancement automatique du conteneur n8n

### Ollama (IA locale)
- Installation d’Ollama
- Activation du service au démarrage
- Téléchargement du modèle Qwen3:8B

### Intégration n8n ↔ Ollama
- Configuration réseau pour permettre à n8n (Docker) d'accéder à Ollama (host)
- Modification automatique du service Ollama
- Ouverture de l'API Ollama sur le réseau local

### Vérifications automatiques

Le script vérifie :

- que l'API Ollama répond correctement
- que le port 11434 est ouvert
- que n8n peut accéder à Ollama depuis le conteneur Docker

---

# 🌐 Accès à n8n

Une fois l'installation terminée :

http://IP_DU_SERVEUR:5678

Exemple :

http://192.168.1.10:5678

---

# 🤖 Ollama

L'API Ollama est accessible sur :

http://localhost:11434

Modèle installé :

qwen3:8b

---

# 🐳 Technologies utilisées

- Docker
- Docker Compose
- n8n (self-hosted)
- Ollama
- Qwen3:8B

---

# 📦 n8n

n8n est une plateforme d'automatisation open-source permettant de connecter différentes applications et services.

Site officiel :
https://n8n.io

---

# ⚠️ Avertissement

Ce script modifie la configuration du système.

Il est recommandé de :

- l'exécuter sur un serveur neuf
- vérifier le script avant utilisation
- tester dans un environnement de développement

---

# 📜 Licence

Projet open-source.
Utilisation libre.
