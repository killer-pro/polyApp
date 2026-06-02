# TODO — PolyApp v1
> Tâches classées par priorité. Phase 1 = bloquant pour le déploiement Play Store.

---

## PHASE 1 — Sécurité & stabilité (bloquant)

- [x] **[SÉCU]** Créer une Cloud Function Firebase pour l'envoi FCM — clés supprimées du client, `notification_service.dart` migré vers `cloud_functions`, code serveur dans `functions/index.js`
- [x] **[SÉCU]** Ajouter une vérification de rôle (ADMIN) dans `deleteAnnonceById()` et `removeMatch()`
- [x] **[SÉCU]** Écrire les règles Firestore de production → fichier `firestore.rules` créé (à publier sur Firebase Console)
- [ ] **[SÉCU]** Retirer le token FCM du document `USER` dans Firestore
- [x] **[BUG]** Corriger `Xoss.fromJson` : date lue depuis `json['date']` (ISO string ou Timestamp)
- [x] **[BUG]** Corriger le bug `redCardB` dans `detail_match.dart`
- [ ] **[BUG]** Corriger `Football.fromJson` : variable non définie dans le constructeur
- [x] **[RGPD]** Ajouter `deleteUser()` dans `UserService` (suppression Auth + Firestore + SharedPreferences)
- [x] **[CRUD]** Ajouter `deleteLostObject()` dans `LostFoundService` (supprime image Storage + doc)
- [x] **[CRUD]** Ajouter `deleteJeu()` (niveau racine) dans `JeuService`
- [x] **[CRUD]** Ajouter `deleteXoss()` dans `XossService`

---

## PHASE 2 — Modèles de données

- [ ] Corriger `ObjetPerdu.date` : changer de `String` à `DateTime` (+ fix `toJson`/`fromJson`)
- [ ] Corriger `ObjetPerdu.estTrouve` : remplacer `int` par l'enum `Etat`
- [ ] Corriger `ObjetPerdu.toJson` : ajouter le champ `details` manquant
- [ ] Corriger `Joueur.position` : remplacer `String` par l'enum `PositionJoueur`
- [ ] Corriger `HotTopic.category` : remplacer `String` par un enum ou une référence `Categorie`
- [ ] Corriger `Membre.sport` : remplacer `String` par `SportType`
- [ ] Corriger `Xoss` : supprimer le champ `versement` (toujours à 0) ou l'implémenter vraiment
- [ ] Remplacer `Match.likers` et `Match.dislikers` : `List<Utilisateur>` → `List<String>` (IDs uniquement)
- [ ] Migrer `Annonce.comments` vers une sous-collection Firestore `ANNONCE/{id}/comments`
- [ ] Migrer `Match.comments` vers une sous-collection Firestore `MATCH/{id}/comments`
- [ ] Ajouter champ `userId` (auteur) dans `Annonce`
- [ ] Ajouter champ `userId` (auteur) dans `HotTopic`
- [ ] Ajouter champ `statut` dans `Commande` (pending / confirmé / livré / annulé)
- [ ] Ajouter champ `statut` dans `Match` (programmé / en cours / terminé)
- [ ] Ajouter `createdAt` / `updatedAt` dans les modèles principaux (Annonce, Match, Commande, ObjetPerdu, Xoss)
- [ ] Ajouter champ `createdAt` et `resolvedBy` dans `ObjetPerdu`
- [ ] Créer une classe modèle `Token` pour la collection `TOKEN`
- [ ] Créer une classe modèle `Parametre` pour la collection `PARAMETRE`
- [ ] Supprimer `role.dart` (doublon de `enums/role_type.dart`)
- [ ] Supprimer `commission.dart` (entièrement commenté)
- [ ] Ajouter `image` dans `pubspec.yaml` (utilisé dans `user_service.dart` mais non déclaré)

---

## PHASE 3 — UX & features

- [ ] **[Shop]** Implémenter un panier (CartModel + CartService)
- [ ] **[Shop]** Ajouter une page de récapitulatif/checkout avant validation de commande
- [ ] **[Shop]** Afficher le statut des commandes dans "Mes Commandes"
- [ ] **[Shop]** Ajouter indicateur de stock sur les articles
- [ ] **[Annonces]** Décommenter / implémenter le bouton "Voir communiqué" sur la card AG
- [ ] **[Annonces]** Créer une page de détail pour chaque annonce
- [ ] **[Annonces]** Ajouter une interface de gestion des Hot Topics (admin)
- [ ] **[Jeux]** Remplacer l'affichage du `creatorId` brut par le prénom/nom dans les sessions
- [ ] **[Jeux]** Ajouter un champ "nombre de joueurs max" par session
- [ ] **[Notifications]** Créer un écran d'historique des notifications reçues
- [ ] **[Formulaires]** Ajouter validation inline sur tous les formulaires (lost objects, create match, inscription…)
- [ ] **[UX]** Ajouter des dialogs de confirmation avant toute suppression (commandes, commentaires, objets perdus)
- [ ] **[UX]** Standardiser les états vides sur tous les écrans (composant réutilisable)
- [ ] **[UX]** Standardiser les états de chargement sur tous les écrans
- [ ] **[UX]** Standardiser les messages d'erreur avec retry sur tous les `FutureBuilder`
- [ ] **[Erreurs]** Refactoriser les services pour remonter les erreurs à l'UI (remplacer `return null` par des exceptions ou un type `Result`)

---

## PHASE 4 — Nettoyage & qualité

- [ ] Supprimer `api_service.dart` (fichier entièrement commenté)
- [ ] Supprimer le code de vérification de version commenté dans `main.dart`
- [ ] Supprimer le flow de permission notification commenté dans `NotificationService`
- [ ] Nettoyer tous les `//debugPrint()` (~200 occurrences)
- [ ] Supprimer les packages inutilisés de `pubspec.yaml` : `photo_view`, `flutter_localization`, `file_picker`, `app_version_update`
- [ ] Mettre en place la gestion d'état (Provider ou Riverpod) pour remplacer les `StatefulWidget` complexes
- [ ] Ajouter injection de dépendances (`get_it`) pour les services
- [ ] Écrire des tests unitaires pour les services critiques (UserService, ShopService, SportService)
- [ ] Configurer App Check (Play Integrity) pour la production
- [ ] Mettre à jour le `android/build.gradle` : AGP `8.1.1` → version plus récente compatible Gradle 8.11

---

## PHASE 5 — Déploiement Play Store

- [ ] Configurer la signature APK (keystore de production)
- [ ] Mettre à jour `pubspec.yaml` : `version: 1.0.0+1`
- [ ] Vérifier le package name `sn.ept.pic.app` dans tous les fichiers Android
- [ ] Créer les captures d'écran Play Store (téléphone + tablette)
- [ ] Rédiger la description Play Store (FR)
- [ ] Configurer la politique de confidentialité (obligatoire Play Store)
- [ ] Activer App Check en mode production (Play Integrity)
- [ ] Tester le build release : `flutter build appbundle --release`
- [ ] Soumettre sur Google Play Console
