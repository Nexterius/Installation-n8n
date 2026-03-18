#!/bin/bash

# Définit le mode d'installation des paquets Debian en "non interactif".
export DEBIAN_FRONTEND=noninteractive

# Vérifie que le script est exécuté avec sudo depuis un utilisateur normal.
# La variable $SUDO_USER est définie uniquement lorsqu'un utilisateur lance une
# commande avec sudo. Si elle est vide, cela signifie que le script est lancé
# directement en root ou sans sudo.
# Dans ce cas, le script s'arrête pour éviter des comportements imprévus.
if [ -z "$SUDO_USER" ]; then
  echo "Veuillez lancer le script avec sudo depuis un utilisateur normal."
  exit 1
fi

# Active le mode strict bash
set -euo pipefail

# Script complet d'installation N8N sur Debian 13

# Version test - Production-not ready - non Testé et pas validé

echo "🔄 Mise à jour et installation des prérequis "
echo "======================================================================="

# Maj systeme
apt update && apt upgrade -y

# Installation des prérequis
apt install ca-certificates curl gnupg openssl -y

# Ajout de la clé officielle Docker
install -m 0755 -d /etc/apt/keyrings
ls -ld /etc/apt/keyrings

# Téléchargement et enregistrement la clé GPG officielle Docker
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null || true
ls -l /etc/apt/keyrings/docker.gpg

# Ajout du dépôt officiel Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null

cat /etc/apt/sources.list.d/docker.list

# Mise à jour de la liste des paquets
apt update

echo "📦 Installation de Docker Engine + Compose "

# Installation de Docker Engine + Compose
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo docker --version
systemctl is-active docker

# Démarrage de Docker
systemctl enable docker
systemctl start docker

echo "✅ Docker installé avec succès"

# Autoriser l’utilisateur à utiliser Docker sans sudo (ajout au groupe docker)
usermod -aG docker $SUDO_USER
echo "⚠️ Déconnectez-vous puis reconnectez-vous pour utiliser Docker sans sudo."

echo "📁 Création de l'environnement N8N"
echo "======================================================================="

# Création du dossier du service
mkdir -p /srv/n8n
ls -ld /srv/n8n

# Don des droits d’accès du dossier à l’utilisateur
chown -R $SUDO_USER:$SUDO_USER /srv/n8n
ls -ld /srv/n8n

# Création du dossier de données persistantes
mkdir -p /srv/n8n/n8n_data
chown -R 1000:1000 /srv/n8n/n8n_data

# Sauvegarde du .env existant
if [ -f /srv/n8n/.env ]; then
  cp /srv/n8n/.env /srv/n8n/.env.backup
fi

echo "🔑 Génération de la clé de chiffrement N8N"

# Génération de la clé
KEY=$(openssl rand -hex 32)

# Création du nouveau .env
cat <<EOF > /srv/n8n/.env
N8N_ENCRYPTION_KEY=$KEY
N8N_SECURE_COOKIE=false

N8N_HOST=localhost
N8N_PORT=5678
N8N_PROTOCOL=http
WEBHOOK_URL=http://localhost:8080/
EOF

# Création du docker-compose.yml
cat <<EOF > /srv/n8n/docker-compose.yml

services:
  n8n:
    image: n8nio/n8n:latest
    restart: always
    ports:
      - "5678:5678"
    env_file:
      - .env
    volumes:
      - ./n8n_data:/home/node/.n8n
EOF

# Lancement de N8N
echo "🚀 Lancement de N8N"
cd /srv/n8n
docker compose up -d
sleep 5

IP=$(hostname -I | awk '{print $1}')

echo "======================================================================="
echo "Installation terminée"
echo "N8N accessible sur : http://localhost:8080"
echo "======================================================================="

# Outil terminal pour lire,filtrer et transformer des données JSON
apt install jq -y

# Installation d’Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Activation & démarrage d'Ollama
systemctl enable ollama
systemctl start ollama
sleep 3

# Téléchargement de l'IA Qwen 3:8B
ollama pull qwen3:8b

# Envoie une requête à l’API Ollama pour générer une réponse avec le modèle qwen3:8b,
# puis extrait et affiche uniquement le texte de la réponse grâce à jq.
curl -s http://localhost:11434/api/generate \
-H "Content-Type: application/json" \
-d '{
  "model": "qwen3:8b",
  "prompt": "explique ce qu est docker en une phrase",
  "stream": false
}' | jq -r '.response'


# Modification du fichier docker-compose.yml
grep -q host.docker.internal /srv/n8n/docker-compose.yml || \
sed -i '/restart: always/a\    extra_hosts:\n      - "host.docker.internal:host-gateway"' /srv/n8n/docker-compose.yml

# Redémarrage du conteneur Docker
cd /srv/n8n
docker compose down
docker compose up -d

# Modifier le service Ollama
FILE="/etc/systemd/system/ollama.service"
grep -q OLLAMA_HOST $FILE || \
sed -i '/ExecStart=\/usr\/local\/bin\/ollama serve/i Environment="OLLAMA_HOST=0.0.0.0"' $FILE

# Recharger systemd
systemctl daemon-reload

# Redémarrer Ollama
systemctl restart ollama

# Vérification de l'ouverture du port 11434
ss -tulpen | grep 11434

# Vérifie que l’API Ollama est accessible depuis le réseau Docker via la passerelle.
curl http://$(ip -4 addr show docker0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'):11434/api/tags

# Vérifie que l’API Ollama est accessible depuis le conteneur n8n via l’hôte Docker.
docker exec n8n-n8n-1 wget -qO- http://host.docker.internal:11434/api/tags



echo "======================================================================="
echo "RAPPEL"
echo "Utiliser un tunnel SSH : Tunnel SSH"
echo "ssh -L 8080:localhost:5678 utilisateur@ip_du_serveur"
echo "N8N accessible sur : http://localhost:8080"
echo "======================================================================="



