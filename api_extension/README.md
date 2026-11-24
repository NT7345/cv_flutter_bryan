# Extension API du profil

L’API `espoirbaraka/api-test` ne possède pas de profil étudiant avec photo.
Cette extension ajoute `GET /accounts/{id}/profile`, `PUT` pour modifier les
champs texte et `POST` multipart pour les modifier avec une photo. Les champs
de compte et les routes existantes restent inchangés.

## Installation locale

1. Copiez `src/Models/Profile.php` et `src/Controllers/ProfileController.php`
   dans les mêmes dossiers de `C:\xampp\htdocs\api-test`.
2. Dans `public/index.php`, ajoutez les deux `require_once` correspondants,
   puis insérez le contenu de `public/profile_routes.php` après les routes
   `/accounts/login` et avant la réponse 404.
3. Dans phpMyAdmin, sélectionnez `api` puis importez
   `migrations/20261124_create_account_profile.sql`. Cette migration ajoute
   uniquement `account_profile`, sans modifier ou vider les autres tables.
4. Réessayez la connexion dans l’application.

Les images de profil sont stockées dans `public/uploads/profiles`; le serveur
doit pouvoir créer ce dossier et y écrire. Les images JPEG, PNG, GIF et WebP
sont limitées à 2 Mo, comme les photos de famille.

Comme les routes de l’API de base, ces routes ne vérifient pas de jeton ou de
session. Elles ne doivent être exposées qu’à un serveur de TP local ou protégées
par une authentification côté serveur avant tout déploiement public.
