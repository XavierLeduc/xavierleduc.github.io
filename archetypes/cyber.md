---
title: "{{ replace .File.ContentBaseName "-" " " | title }}"
date: {{ .Date }}
draft: true
tags: []           # ex: ["vice", "recon", "black-box"]
categories: ["Cybersécurité"]
tool: ""           # ex: "VICE"
test_mode: ""      # black-box | white-box | grey-box
target_type: ""    # lab | ctf | autorisation-ecrite
scope: ""          # cible testée (IP/domaine du lab, dates, périmètre in/out)
---

## Objectif

Ce que je veux vérifier avec cet outil/cette technique (précision, faux positifs, couverture, etc.).

## Contexte & scope

- Cible : (lab / CTF / nom du projet)
- Mode testé : black-box / white-box
- Autorisation : (référence au mandat ou lab volontairement vulnérable)
- Période : {{ .Date }}

## Méthodologie

Étapes suivies, configuration de l'outil, version, options utilisées.

1. 
2. 
3. 

## Résultats bruts

Sorties, captures d'écran, logs (anonymisés si besoin).

## Analyse

Ce qui a été trouvé vs réalité connue du lab, faux positifs/négatifs.

## Comparaison

*(si plusieurs outils/modes testés)*

| Critère | Black-box | White-box |
|---|---|---|
|  |  |  |

## Limites & conclusion

Ce que l'outil fait bien/mal, dans quel contexte l'utiliser.
