
USE sncf_frequentation_bdd;

CREATE TABLE gares (
  code_uic               INT          NOT NULL,
  nom_gare               VARCHAR(100) NOT NULL,
  code_postal            CHAR(5),
  direction_regionale    VARCHAR(50),
  segmentation_drg       VARCHAR(20),
  segmentation_marketing VARCHAR(30),
  latitude               DECIMAL(9,6) NULL,
  longitude              DECIMAL(9,6) NULL,
  PRIMARY KEY (code_uic)
);

CREATE TABLE frequentation (
  code_uic           INT      NOT NULL,
  annee              SMALLINT NOT NULL,
  nb_voyageurs       BIGINT,
  nb_voyageurs_total BIGINT,
  nb_non_voyageurs   BIGINT,
  PRIMARY KEY (code_uic, annee),
  CONSTRAINT fk_freq_gare FOREIGN KEY (code_uic) REFERENCES gares (code_uic)
);

-- Vérifier le nombre de gares

SELECT COUNT(*) AS nombre_gares
FROM gares;

-- Vérifier les codes UIC
SELECT COUNT(*) AS nombre_enregistrements
FROM frequentation;

-- cette requête permet de connaître les années présentes dans ton fichier et le nombre d'enregistrements pour chacune

SELECT
    annee,
    COUNT(*) AS nombre_enregistrements
FROM frequentation
GROUP BY annee
ORDER BY annee;

-- vérifier les doublons Nous allons vérifier qu'une même gare n'apparaît pas plusieurs fois pour une même année.

SELECT
    code_uic,
    annee,
    COUNT(*) AS nombre
FROM frequentation
GROUP BY code_uic, annee
HAVING COUNT(*) > 1;

-- 

SELECT COUNT(*) AS gares_sans_correspondance
FROM frequentation f
LEFT JOIN gares g
    ON f.code_uic = g.code_uic
WHERE g.code_uic IS NULL;

-- nous allons controler les données de fréquentation ( verifier les valeurs manquantes)

SELECT
    COUNT(*) AS total_lignes,
    SUM(code_uic IS NULL) AS uic_manquants,
    SUM(annee IS NULL) AS annees_manquantes,
    SUM(nb_voyageurs IS NULL) AS voyageurs_manquants,
    SUM(nb_voyageurs_total IS NULL) AS total_manquants,
    SUM(nb_non_voyageurs IS NULL) AS non_voyageurs_manquants
FROM frequentation;

-- 
SELECT *
FROM frequentation
WHERE code_uic IS NULL
   OR annee IS NULL
   OR nb_voyageurs IS NULL
   OR nb_voyageurs_total IS NULL
   OR nb_non_voyageurs IS NULL
LIMIT 20;

-- vérifier les valeurs de fréquentation Nous allons vérifier si certaines valeurs sont négatives ou incohérentes.
SELECT *
FROM frequentation
WHERE nb_voyageurs < 0
   OR nb_voyageurs_total < 0
   OR nb_non_voyageurs < 0;
   
   -- Elle permet de vérifier si le total correspond à la somme des voyageurs et des non-voyageurs.
   SELECT *
FROM frequentation
WHERE nb_voyageurs_total <> 
      (nb_voyageurs + nb_non_voyageurs);
      
      -- calculer la fréquentation totale par année
      SELECT
    annee,
    SUM(nb_voyageurs_total) AS frequentation_totale
FROM frequentation
GROUP BY annee
ORDER BY annee;

-- Top 10 des gares les plus fréquentées
SELECT
    g.code_uic,
    g.nom_gare,
    f.nb_voyageurs_total
FROM gares g
INNER JOIN frequentation f
    ON g.code_uic = f.code_uic
WHERE f.annee = 2024
ORDER BY f.nb_voyageurs_total DESC
LIMIT 10;

-- comparer 2023 et 2024

SELECT
    g.nom_gare,
    f23.nb_voyageurs_total AS frequentation_2023,
    f24.nb_voyageurs_total AS frequentation_2024,
    f24.nb_voyageurs_total - f23.nb_voyageurs_total AS evolution
FROM gares g
INNER JOIN frequentation f23
    ON g.code_uic = f23.code_uic
INNER JOIN frequentation f24
    ON g.code_uic = f24.code_uic
WHERE f23.annee = 2023
  AND f24.annee = 2024
ORDER BY evolution DESC
LIMIT 10;


-- les 10 gares ayant connu la plus forte progression en pourcentage entre 2023 et 2024.
SELECT
    g.nom_gare,
    f23.nb_voyageurs_total AS annee_2023,
    f24.nb_voyageurs_total AS annee_2024,
    ROUND(
        (f24.nb_voyageurs_total - f23.nb_voyageurs_total)
        / NULLIF(f23.nb_voyageurs_total, 0) * 100,
        2
    ) AS evolution_pourcentage
FROM gares g
JOIN frequentation f23
    ON g.code_uic = f23.code_uic
JOIN frequentation f24
    ON g.code_uic = f24.code_uic
WHERE f23.annee = 2023
  AND f24.annee = 2024
  AND f23.nb_voyageurs_total > 0
ORDER BY evolution_pourcentage DESC
LIMIT 10; 

-- identifier les gares les moins fréquentées
SELECT
    g.nom_gare,
    f.nb_voyageurs_total
FROM gares g
INNER JOIN frequentation f
    ON g.code_uic = f.code_uic
WHERE f.annee = 2024
ORDER BY f.nb_voyageurs_total ASC
LIMIT 10;

-- Nous allons regarder si ces gares avaient également zéro voyageur en 2023.

SELECT
    g.nom_gare,
    f23.nb_voyageurs_total AS frequentation_2023,
    f24.nb_voyageurs_total AS frequentation_2024
FROM gares g
JOIN frequentation f23
    ON g.code_uic = f23.code_uic
JOIN frequentation f24
    ON g.code_uic = f24.code_uic
WHERE f23.annee = 2023
  AND f24.annee = 2024
  AND f24.nb_voyageurs_total = 0
ORDER BY f23.nb_voyageurs_total ASC
LIMIT 10;

-- les gares qui progressent le plus sur 10 ans
SELECT
    g.nom_gare,
    f2015.nb_voyageurs_total AS frequentation_2015,
    f2024.nb_voyageurs_total AS frequentation_2024,
    f2024.nb_voyageurs_total -
    f2015.nb_voyageurs_total AS evolution
FROM gares g
JOIN frequentation f2015
    ON g.code_uic = f2015.code_uic
JOIN frequentation f2024
    ON g.code_uic = f2024.code_uic
WHERE f2015.annee = 2015
  AND f2024.annee = 2024
ORDER BY evolution DESC
LIMIT 10;

SELECT *
FROM gares
WHERE code_uic = 87462085;

SELECT
    code_uic,
    COUNT(*) AS nombre
FROM gares
GROUP BY code_uic
HAVING COUNT(*) > 1
ORDER BY nombre DESC;

SELECT COUNT(*) AS total_lignes,
       COUNT(DISTINCT code_uic) AS codes_uniques
FROM gares;