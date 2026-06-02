# Remarques — Audit PolyApp
> Analyse complète effectuée en mars 2026 avant reprise du projet et redéploiement Play Store.

---

## 1. Sécurité

### 1.1 Clés service account dans le client (CRITIQUE)
Le service `NotificationService` charge un fichier JSON de compte de service Google (clés privées) depuis `.env` pour envoyer des notifications FCM directement depuis l'app. N'importe qui peut extraire l'APK et récupérer ces clés. L'envoi FCM doit passer par une **Cloud Function Firebase**, jamais depuis le client.

### 1.2 Aucune vérification de rôle dans les opérations sensibles (CRITIQUE)
Les méthodes `deleteAnnonceById()`, `removeMatch()` et autres suppressions dans `SportService` et `AnnonceService` ne vérifient pas si l'utilisateur est ADMIN avant d'exécuter. Tout utilisateur authentifié peut supprimer du contenu.

### 1.3 Règles Firestore trop permissives
Les règles actuelles autorisent toute lecture/écriture pour tout utilisateur connecté. En production, chaque collection doit avoir des règles précises (ex: seul l'admin peut écrire dans MATCH, un user ne peut lire que son propre USER document).

### 1.4 Token FCM stocké dans le document USER
Le token de notification push est stocké dans le profil Firestore de l'utilisateur, accessible à d'autres. Il devrait être dans la collection `TOKEN` uniquement.

### 1.5 Project ID Firebase hardcodé dans le code
`'https://fcm.googleapis.com/v1/projects/ept-app-46930/messages:send'` est écrit en dur dans `NotificationService`. Doit passer par une variable d'environnement ou une Cloud Function.

---

## 2. Bugs de données

### 2.1 Date Xoss toujours écrasée (CRITIQUE)
Dans `xoss.dart`, le `fromJson` contient `date: DateTime.now()` au lieu de lire `json['date']`. Résultat : toutes les dates de transactions sont perdues et remplacées par la date de chargement.

### 2.2 Bug redCard dans le détail de match
Dans `detail_match.dart` (ligne ~334), le compteur de cartons rouges affiche `redCardA` deux fois au lieu de `redCardA` / `redCardB`.

### 2.3 `ObjetPerdu.date` stocké en String
Le champ `date` de `ObjetPerdu` est un `String` au lieu d'un `DateTime`, rendant les tris et comparaisons impossibles. De plus, `toJson()` omet le champ `details`.

### 2.4 `versement` dans Xoss toujours à 0
Le champ `versement` est hardcodé à `0` dans `fromJson`. Champ inutile dans l'état actuel.

### 2.5 Variable indéfinie dans `Football.fromJson`
`Football.fromJson(super.json)` référence une variable non définie, ce qui peut causer des crashs à la désérialisation.

---

## 3. Modèles de données & schéma Firestore

### 3.1 Sur-embedding massif (risque limite 1MB Firestore)
Plusieurs documents embarquent des listes d'objets complets au lieu de références :
- `Match` embarque les deux `Equipe` (avec tous leurs `Joueur`)
- `Match` embarque `List<Utilisateur>` pour les likers/dislikers
- `Annonce` et `Match` embarquent les commentaires avec `Utilisateur` complet
- `Xoss` embarque un `Utilisateur` complet
- `Jeu` embarque toutes ses sessions

Pour un match avec beaucoup d'activité, le document peut dépasser 1MB et crasher silencieusement.

### 3.2 Champs manquants critiques
- `Annonce` : pas de champ auteur (`userId`)
- `HotTopic` : pas de champ auteur
- `Commande` : pas de statut (en attente / confirmé / livré / annulé)
- `Match` : pas de statut (programmé / en cours / terminé)
- `ObjetPerdu` : pas de `createdAt`, pas d'info de résolution
- Presque tous les modèles : pas de `updatedAt`

### 3.3 Mauvais types sur certains champs
- `ObjetPerdu.estTrouve` : `int` → devrait utiliser l'enum `Etat`
- `Joueur.position` : `String` → devrait utiliser l'enum `PositionJoueur`
- `HotTopic.category` : `String` → devrait utiliser un enum ou référencer `Categorie`
- `Membre.sport` : `String` → devrait utiliser `SportType`

### 3.4 Stratégie de clé incohérente
- `USER` utilise l'email comme clé de document — si un utilisateur change d'email, tous les liens sont cassés
- `LOSTOBJECTS` utilise `.add()` (ID auto-généré) alors que tous les autres utilisent `.doc(id)`
- Les références entre collections utilisent tantôt l'email, tantôt un UUID — pas de convention claire

### 3.5 Doublons et dead code dans les modèles
- `role.dart` duplique `RoleType` déjà défini dans `enums/role_type.dart`
- `commission.dart` est entièrement commenté — à supprimer
- `TOKEN` et `PARAMETRE` sont utilisés dans les services mais n'ont pas de classe modèle

---

## 4. Services — CRUD incomplets

Quatre services n'ont **aucune méthode de suppression** :
- `LostFoundService` : pas de `deleteLostObject()`
- `UserService` : pas de `deleteUser()` (problème RGPD)
- `JeuService` : pas de `deleteJeu()` au niveau racine
- `XossService` : pas de `deleteXoss()`

---

## 5. Gestion des erreurs

La quasi-totalité des erreurs dans les services sont **silencieuses** : capturées par un `catch (e)` qui retourne `null` ou une liste vide sans aucun feedback à l'UI. L'utilisateur ne sait jamais si une opération a échoué.

Quelques cas notables :
- `signInWithEmailAndPassword` : bloque silencieusement les emails non vérifiés sans expliquer pourquoi à l'UI
- `NotificationService` : l'échec d'envoi FCM est loggé en commentaire (`//debugPrint`)
- `LostFoundService` : cast `e as String?` qui échouera silencieusement si `e` n'est pas une String

---

## 6. UX — Workflows incomplets

### 6.1 Shop sans checkout
Le shop permet de passer commande mais il n'y a pas de panier, pas de récapitulatif avant validation, pas de sélection de mode de paiement, pas de suivi de commande après achat. Le bouton de commande est une action immédiate et irréversible.

### 6.2 Annonces — bouton commenté
Le bouton "Voir communiqué" sur la card AG (Assemblée Générale) est commenté dans le code (lignes 200-215 de l'écran annonces). Les utilisateurs voient une card sans action possible.

### 6.3 Hot Topics sans interface
`HotTopicsService` existe et fonctionne, mais l'interface de gestion (création/édition) n'est pas intégrée dans les pages admin.

### 6.4 Notifications sans UI
`firebase_messaging` est intégré et `NotificationService` envoie des notifications, mais aucun écran ne permet de voir l'historique des notifications reçues.

### 6.5 `creatorId` affiché brut dans les sessions de jeux
La liste des participants dans `game_screen.dart` affiche l'email brut du créateur au lieu de son prénom/nom.

### 6.6 Pas de page de détail pour les annonces
Les annonces s'affichent sous forme de cards mais il n'y a pas de page de détail dédiée avec le contenu complet.

---

## 7. UX — Patterns incohérents

| Aspect | Problème |
|---|---|
| États de chargement | Présents dans certains écrans, absents dans d'autres |
| États vides | Certains écrans sont blancs, d'autres affichent un message |
| Validation de formulaires | Quasi inexistante — uniquement des snackbars après soumission |
| Confirmations avant suppression | Absentes sur commandes, comments (long-press non signalé) |
| Messages d'erreur | Non standardisés — certains en français, d'autres absents |

---

## 8. Architecture & qualité du code

### 8.1 Pas de gestion d'état centralisée
L'app utilise uniquement `StatefulWidget` + `setState` et `FutureBuilder`/`StreamBuilder`. Cela fonctionne pour une petite app mais devient difficile à maintenir quand plusieurs écrans doivent partager le même état.

### 8.2 Instances Firebase dupliquées
Chaque service instancie sa propre `LocalNotificationService` et ses propres références Firebase. Pas d'injection de dépendances, impossible à tester unitairement.

### 8.3 Dead code
- `api_service.dart` : fichier entièrement commenté (50 lignes)
- `main.dart` : vérification de version commentée (26 lignes + wrapper FutureBuilder)
- `NotificationService` : flow de permission commenté (46 lignes)
- `commission.dart` : modèle entièrement commenté
- ~200 occurrences de `//debugPrint()` dans tous les services

### 8.4 Packages inutilisés dans pubspec.yaml
`photo_view`, `flutter_localization`, `file_picker`, `app_version_update` sont déclarés mais non utilisés.

### 8.5 Package `image` manquant dans pubspec.yaml
`user_service.dart` importe `package:image/image.dart` mais le package n'est pas déclaré dans `pubspec.yaml`. Fonctionne probablement en tant que dépendance transitive mais fragile.
