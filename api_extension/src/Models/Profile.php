<?php

namespace App\Models;

use App\Database;
use PDO;

class Profile
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    public function findByAccountId(int $accountId): ?array
    {
        $stmt = $this->db->prepare(
            'SELECT * FROM account_profile WHERE account_id = :account_id'
        );
        $stmt->execute(['account_id' => $accountId]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function save(int $accountId, array $data): void
    {
        $stmt = $this->db->prepare(
            'INSERT INTO account_profile
                (account_id, nom, titre, lieu, telephone, email, resume, informations, image)
             VALUES
                (:account_id, :nom, :titre, :lieu, :telephone, :email, :resume, :informations, :image)
             ON DUPLICATE KEY UPDATE
                nom = VALUES(nom),
                titre = VALUES(titre),
                lieu = VALUES(lieu),
                telephone = VALUES(telephone),
                email = VALUES(email),
                resume = VALUES(resume),
                informations = VALUES(informations),
                image = VALUES(image)'
        );
        $stmt->execute([
            'account_id' => $accountId,
            'nom' => $data['nom'],
            'titre' => $data['titre'],
            'lieu' => $data['lieu'],
            'telephone' => $data['telephone'],
            'email' => $data['email'],
            'resume' => $data['resume'],
            'informations' => $data['informations'],
            'image' => $data['image'],
        ]);
    }
}
