#!/usr/bin/env bash
set -euo pipefail

read -rp "Titre de l'article : " title

if [ -z "$title" ]; then
  echo "Le titre ne peut pas être vide." >&2
  exit 1
fi

slug=$( (echo "$title" \
  | iconv -t ascii//TRANSLIT 2>/dev/null \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g') || true)

filepath="content/posts/${slug}.md"

if [ -e "$filepath" ]; then
  echo "Le fichier $filepath existe déjà." >&2
  exit 1
fi

date_now=$(date +"%Y-%m-%dT%H:%M:%S%z" | sed -E 's/([+-][0-9]{2})([0-9]{2})$/\1:\2/')

cat > "$filepath" <<EOF
---
title: "${title}"
date: ${date_now}
draft: false
tags: []        # ex: ["cybersécurité"], ["trail"], ["aéronautique"]
categories: []  # ex: ["Général"]
---

EOF

echo "Article créé : $filepath"

if command -v code >/dev/null 2>&1; then
  code "$filepath"
else
  echo "VS Code (commande 'code') introuvable dans le PATH, ouvre le fichier manuellement."
fi
