CREATE TABLE IF NOT EXISTS account_profile (
    account_id INT NOT NULL,
    nom VARCHAR(100) NOT NULL,
    titre VARCHAR(150) NOT NULL,
    lieu VARCHAR(150) NOT NULL DEFAULT '',
    telephone VARCHAR(30) NOT NULL DEFAULT '',
    email VARCHAR(100) NOT NULL DEFAULT '',
    resume TEXT NOT NULL,
    informations TEXT NOT NULL,
    image VARCHAR(255) DEFAULT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (account_id),
    CONSTRAINT account_profile_account_fk
        FOREIGN KEY (account_id) REFERENCES account (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
