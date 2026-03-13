# n8n Automatic Installation Script (Debian 13 + Docker)

Script permettant d'installer automatiquement **n8n self-hosted** sur **Debian 13** avec **Docker**.

Ce script automatise l'installation et la configuration de n8n afin d'obtenir rapidement un environnement fonctionnel.

---

# 🚀 Installation

## Méthode classique (recommandée)

Se connecter avec l'utilisateur root

apt install sudo

apt install git

usermod -aG sudo ##utilisateur

Se reconnecter avec l'utilisateur

Cloner le repository puis lancer le script.

sudo git clone https://github.com/Nexterius/Installation-n8n.git

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
- Accès **sudo**
- Connexion internet
- Serveur propre recommandé

---

# ⚙️ Ce que fait le script

Le script effectue automatiquement :

- Mise à jour du système
- Installation de Docker
- Installation de Docker Compose
- Installation de n8n via Docker
- Configuration de base du service
- Démarrage automatique du conteneur

---

# 🐳 Technologies utilisées

- Docker
- Docker Compose
- n8n (self-hosted)

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
