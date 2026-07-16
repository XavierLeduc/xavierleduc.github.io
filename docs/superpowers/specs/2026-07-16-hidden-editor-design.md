# Éditeur d'articles caché — design

Date : 2026-07-16

## Contexte

Le site est un blog Hugo statique déployé sur GitHub Pages via GitHub Actions
(`.github/workflows/hugo.yml`, déclenché par push sur `main`). Il n'y a pas de
backend. Créer un article aujourd'hui passe par le script local
`new-article.sh`, qui génère un fichier `content/posts/<slug>.md` avec un
front matter minimal (title, date, draft, tags, categories), puis nécessite
un commit/push manuel.

Le besoin : pouvoir rédiger et publier un article facilement, depuis un
navigateur, sans repasser par le terminal — via une page « cachée » du site,
non liée dans la navigation.

## Objectif

Une page HTML/CSS/JS autonome permettant de :
1. Rédiger un nouvel article (titre, tags, catégories, contenu markdown,
   statut brouillon) avec un aperçu markdown en direct.
2. Le publier en un clic, ce qui committe directement le fichier `.md` sur
   la branche `main` du repo via l'API GitHub Contents — déclenchant
   automatiquement le workflow de build/déploiement existant.

Hors périmètre (volontairement, YAGNI) : édition ou liste des articles
existants, gestion de médias/images, prévisualisation Hugo complète,
authentification robuste.

## Architecture

- Fichier unique : `static/xl-write/index.html` (HTML + CSS + JS inline,
  pas de build step). Hugo copie `static/` tel quel dans `public/`, donc la
  page est servie à `https://xavierleduc.github.io/xl-write/`.
- Pas de lien depuis le menu, la sidebar, ou tout autre contenu du site.
  N'étant pas une page de `content/`, elle n'apparaît pas dans le sitemap
  généré par Hugo. C'est de l'obscurité, pas une vraie sécurité : l'URL
  peut fuiter (logs, historique navigateur partagé, etc.) — accepté comme
  tel par l'utilisateur.
- Publication via l'API GitHub Contents
  (`PUT /repos/xavierleduc/xavierleduc.github.io/contents/content/posts/<slug>.md`),
  commit direct sur `main`. Aucune infra serveur additionnelle.
- Rendu de la preview markdown via **marked.js chargé depuis un CDN**
  (jsdelivr, version pinée). Accepté : une dépendance réseau externe pour la
  preview, sur une page qui a de toute façon besoin du réseau pour appeler
  l'API GitHub.

## Authentification / token

- Un champ texte sur la page pour coller un GitHub Personal Access Token
  (scope `repo`, ou fine-grained avec `contents:write` sur ce repo).
- Le token vit uniquement en mémoire JS (variable, ou `sessionStorage` au
  maximum) le temps de l'onglet ouvert. **Jamais** persisté en
  `localStorage`, jamais envoyé à un autre domaine que `api.github.com`,
  jamais commité.
- Recollé à chaque session d'utilisation — friction acceptée en échange de
  ne rien stocker durablement dans le navigateur.

## UX / formulaire

Champs :
- Titre (texte, requis)
- Tags (texte libre, séparés par virgules)
- Catégories (texte libre, séparées par virgules)
- Draft (case à cocher, décoché par défaut — cohérent avec `new-article.sh`)
- Contenu markdown (textarea large)
- Panneau de preview à droite du textarea, mis à jour en direct (rendu HTML
  via marked.js) à chaque frappe (debounce léger, ex. 150 ms)

Bouton unique « Publier ».

## Flux de publication

Au clic sur « Publier » :

1. Valider que titre + token sont renseignés (sinon message d'erreur
   inline, pas d'appel réseau).
2. Générer le slug à partir du titre avec la même logique que
   `new-article.sh` : translittération ASCII, minuscules, tout caractère
   non alphanumérique remplacé par `-`, `-` de tête/fin supprimés.
3. Construire le front matter YAML, format identique à celui produit par
   `new-article.sh` :
   ```
   ---
   title: "<titre>"
   date: <ISO 8601 avec offset, ex. 2026-07-16T14:32:00+02:00>
   draft: <true|false>
   tags: [<tags>]
   categories: [<catégories>]
   ---

   <contenu markdown>
   ```
4. `GET` `contents/content/posts/<slug>.md` sur la branche `main` pour
   vérifier qu'il n'existe pas déjà (même garde-fou que le script local).
   S'il existe → erreur affichée, publication annulée.
5. `PUT` le fichier (contenu encodé en base64), message de commit
   `"Nouvel article: <titre>"`, branche `main`.
6. Afficher le résultat : succès avec lien vers le commit GitHub créé, ou
   message d'erreur brut renvoyé par l'API (401/403 = token invalide ou
   permissions insuffisantes, 422 = conflit, etc.).

## Gestion d'erreurs

Toutes les erreurs (réseau, validation, API GitHub) s'affichent dans un
bandeau inline sur la page, avec le message renvoyé par l'API GitHub quand
disponible. Pas de retry automatique : l'utilisateur corrige et reclique
sur « Publier ». Aucun état n'est perdu (le formulaire reste rempli après
une erreur).

## Test

Pas de suite de tests automatisés pour ce point d'entrée (page HTML/JS
statique, hors périmètre du build Hugo). Vérification manuelle après
implémentation :
- Créer un article de test via la page, vérifier que le commit apparaît
  sur GitHub avec le bon contenu/front matter.
- Vérifier que le workflow `hugo.yml` se déclenche et que l'article est
  visible sur le site après déploiement.
- Vérifier le cas d'erreur (slug déjà existant, token invalide).
- Supprimer l'article de test après vérification.
