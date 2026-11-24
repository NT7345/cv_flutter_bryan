<?php

namespace App\Controllers;

use App\Models\Account;
use App\Models\Profile;

class ProfileController extends Controller
{
    private const UPLOAD_DIR = 'uploads/profiles';
    private const MAX_IMAGE_SIZE = 2 * 1024 * 1024;
    private const IMAGE_EXTENSIONS = [
        IMAGETYPE_JPEG => 'jpg',
        IMAGETYPE_PNG => 'png',
        IMAGETYPE_GIF => 'gif',
        IMAGETYPE_WEBP => 'webp',
    ];

    private Account $accounts;
    private Profile $profiles;

    public function __construct()
    {
        $this->accounts = new Account();
        $this->profiles = new Profile();
    }

    public function show(int $accountId): void
    {
        if (!$this->accounts->findById($accountId)) {
            $this->json(['success' => false, 'message' => 'Compte introuvable'], 404);
            return;
        }

        $profile = $this->profiles->findByAccountId($accountId);
        $this->json([
            'success' => true,
            'data' => $this->present($profile, $accountId),
        ]);
    }

    public function update(int $accountId): void
    {
        if (!$this->accounts->findById($accountId)) {
            $this->json(['success' => false, 'message' => 'Compte introuvable'], 404);
            return;
        }

        $existing = $this->profiles->findByAccountId($accountId);
        $data = $_POST ?: $this->getJsonBody();
        $errors = $this->validate($data);
        $upload = $this->checkImage($errors);
        if ($errors) {
            $this->json([
                'success' => false,
                'message' => 'Données invalides',
                'errors' => $errors,
            ], 422);
            return;
        }

        $data['image'] = $existing['image'] ?? null;
        $newImage = null;
        if ($upload) {
            $newImage = $this->saveImage($upload);
            $data['image'] = $newImage;
        }

        try {
            $this->profiles->save($accountId, $data);
        } catch (\Throwable $error) {
            if ($newImage !== null) {
                $this->deleteImage($newImage);
            }
            throw $error;
        }

        if ($newImage !== null) {
            $this->deleteImage($existing['image'] ?? null);
        }

        $this->json([
            'success' => true,
            'message' => 'Profil mis à jour',
            'data' => $this->present(
                $this->profiles->findByAccountId($accountId),
                $accountId
            ),
        ]);
    }

    private function validate(array $data): array
    {
        $errors = [];
        $fields = [
            'nom' => 100,
            'titre' => 150,
            'lieu' => 150,
            'telephone' => 30,
            'email' => 100,
            'resume' => 3000,
            'informations' => 4000,
        ];

        foreach ($fields as $field => $maxLength) {
            $value = trim((string) ($data[$field] ?? ''));
            if (in_array($field, ['nom', 'titre', 'resume'], true) && $value === '') {
                $errors[$field] = "Le champ {$field} est obligatoire";
            } elseif (strlen($value) > $maxLength) {
                $errors[$field] = "Le champ {$field} ne doit pas dépasser {$maxLength} caractères";
            }
        }

        $email = trim((string) ($data['email'] ?? ''));
        if ($email !== '' && !filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $errors['email'] = "L'email n'est pas valide";
        }

        return $errors;
    }

    private function checkImage(array &$errors): ?array
    {
        $file = $_FILES['image'] ?? null;
        if (!$file || $file['error'] === UPLOAD_ERR_NO_FILE) {
            return null;
        }

        if ($file['error'] !== UPLOAD_ERR_OK) {
            $errors['image'] = "Échec de l'envoi de l'image";
            return null;
        }
        if ($file['size'] > self::MAX_IMAGE_SIZE) {
            $errors['image'] = "L'image ne doit pas dépasser 2 Mo";
            return null;
        }

        $info = @getimagesize($file['tmp_name']);
        if (!$info || !isset(self::IMAGE_EXTENSIONS[$info[2]])) {
            $errors['image'] = "L'image doit être au format jpg, png, gif ou webp";
            return null;
        }

        $file['extension'] = self::IMAGE_EXTENSIONS[$info[2]];
        return $file;
    }

    private function saveImage(array $file): string
    {
        $dir = __DIR__ . '/../../public/' . self::UPLOAD_DIR;
        if (!is_dir($dir) && !mkdir($dir, 0755, true) && !is_dir($dir)) {
            throw new \RuntimeException('Impossible de créer le dossier des photos.');
        }

        $name = bin2hex(random_bytes(16)) . '.' . $file['extension'];
        if (!move_uploaded_file($file['tmp_name'], $dir . '/' . $name)) {
            throw new \RuntimeException("Impossible d'enregistrer la photo.");
        }

        return self::UPLOAD_DIR . '/' . $name;
    }

    private function deleteImage(?string $path): void
    {
        if (!$path) {
            return;
        }
        $file = __DIR__ . '/../../public/' . $path;
        if (is_file($file) && !unlink($file)) {
            error_log("Impossible de supprimer la photo de profil {$file}");
        }
    }

    private function present(?array $profile, int $accountId): array
    {
        $image = $profile['image'] ?? null;
        $base = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'])), '/');
        $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
            ? 'https'
            : 'http';

        return [
            'account_id' => $accountId,
            'is_initialized' => $profile !== null,
            'nom' => $profile['nom'] ?? '',
            'titre' => $profile['titre'] ?? '',
            'lieu' => $profile['lieu'] ?? '',
            'telephone' => $profile['telephone'] ?? '',
            'email' => $profile['email'] ?? '',
            'resume' => $profile['resume'] ?? '',
            'informations' => $profile['informations'] ?? '',
            'image_url' => $image
                ? "{$scheme}://{$_SERVER['HTTP_HOST']}{$base}/{$image}"
                : null,
            'updated_at' => $profile['updated_at'] ?? null,
        ];
    }
}
