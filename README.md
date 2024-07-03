# StatEduc MINJEC

## Contexte
L'application StatEduc est en cours de développement continu, nécessitant que nos cadres de la cellule statistique l'utilisent régulièrement. Cela implique une installation et une configuration préalables de leur environnement de travail. Chaque fois que des modifications sont apportées par l'équipe de développement, les cadres doivent mettre à jour leur environnement de travail. Cette procédure inclut la configuration des connexions à la base de données ainsi que la restauration de la base de données. Nous sommes conscients que ces tâches techniques peuvent représenter des défis pour certains cadres, ce qui peut rendre la prise en main de l'application StatEduc difficile.

## Problèmes Identifiés
- **Difficulté d'installation** : Les cadres non techniques éprouvent des difficultés à installer et configurer leur environnement de travail.
- **Maintenance et mise à jour** : Chaque utilisateur doit manuellement mettre à jour son environnement, entraînant des incohérences et des erreurs.
- **Automatisation des tâches** : Manque d'automatisation pour des tâches récurrentes comme les sauvegardes, restaurations de la base de données et l’ouverture de l’application StatEduc.

## Solution Proposée
L'utilisation de Docker et Docker Compose, ainsi que des scripts batch pour l'automatisation des tâches, a été proposée pour résoudre ces problèmes.

## Explication des Technologies Utilisées

### Docker
Docker est une plateforme permettant de créer, déployer et exécuter des applications dans des conteneurs. Un conteneur est une unité standardisée de logiciel qui contient tout le code, les bibliothèques et les dépendances nécessaires pour que l'application fonctionne, garantissant qu'elle fonctionnera de la même manière sur toutes les machines.
- **Avantages** : Isolation des applications, portabilité entre les environnements, simplification du déploiement et amélioration de la gestion des dépendances.

### Docker Compose
Docker Compose est un outil qui permet de définir et de gérer des applications multi-conteneurs. Avec un fichier de configuration YAML, il est possible de spécifier les services, réseaux et volumes utilisés par l'application, facilitant le démarrage et l'arrêt des conteneurs en une seule commande.
- **Avantages** : Simplification de la gestion des applications complexes, orchestration facile des conteneurs et amélioration de la reproductibilité des environnements.

### Scripts Batch
Un script batch est un fichier texte contenant une série de commandes qui sont exécutées séquentiellement par l'interpréteur de commandes de Windows (cmd.exe). Ces scripts sont utilisés pour automatiser des tâches répétitives ou complexes.
- **Avantages** : Automatisation des processus, réduction des erreurs humaines et gain de temps pour les utilisateurs.

### GitHub
GitHub est une plateforme de développement collaboratif qui utilise le système de contrôle de version Git. Elle permet aux développeurs de travailler ensemble sur des projets, de suivre les modifications de code, de gérer les versions et de collaborer plus efficacement.
- **Avantages** : Collaboration facilitée, gestion des versions, accès centralisé au code source et possibilité de partager des projets avec la communauté ou des équipes spécifiques.

## Mise en Œuvre de la Solution
### Prérequis
- Installer Docker Desktop pour Windows ou macOS en suivant les instructions sur le site officiel.

### Configuration Docker
- Docker permet de créer des conteneurs isolés avec tous les composants nécessaires (serveur XAMPP, application web, SQL Server).
- Docker Compose facilite la gestion et l'orchestration des conteneurs, simplifiant le démarrage et l'arrêt de l'application.

### Scripts Batch
- **Start.bat** : Script pour démarrer l'application web.
- **Make_backups.bat** : Script pour automatiser la sauvegarde de la base de données.
- **Restore_and_Start.bat** : Script pour restaurer la base de données à partir d'une sauvegarde et démarrer l'application.
  - **Note** : Toutes les sauvegardes (backups) sont situées dans l'arborescence suivante : `mssql/backups/`. Pour tout besoin de restauration, veuillez vérifier que les fichiers de restauration se trouvent bien dans ce répertoire.

### Création du Dépôt GitHub
Ce dépôt GitHub a été créé pour permettre un accès facile et centralisé à la solution. Le dépôt contient la configuration Docker, les scripts batch, et un fichier README détaillant les étapes à suivre pour installer et utiliser l'application.

## Structure du Dépôt
- **Docker-files** : Contient les fichiers Docker nécessaires pour configurer l'environnement.
- **Scripts** : Contient les scripts batch pour l'automatisation des tâches.
- **mssql** : Contient les fichiers de backups ainsi que les fichiers des différentes bases de données en cours d’exécution sur le serveur.
- **README.md** : Fournit des instructions détaillées sur la configuration et l'utilisation de l'environnement.

## Utilisation

1. **Télécharger le zip du dépôt Git**.
2. **Ajouter le dossier de l'application StatEduc** :
   - Avant de démarrer l'application, assurez-vous d'ajouter le dossier de l'application StatEduc dans le répertoire courant s’il n’est pas déjà présent. Le nom du dossier doit être `StatEduc_MINJEC`.
3. **Démarrer l'application** :
   - Exécuter `Start.bat` pour lancer l'application StatEduc.
4. **Sauvegarder la base de données** :
   - Exécuter `Make_backups.bat` contenu dans le dossier Scripts.
   - **Note** : Toutes les sauvegardes sont enregistrées dans l’arborescence `mssql/backups/`.
5. **Restaurer la base de données** :
   - Pour restaurer la base de données à partir des sauvegardes les plus récentes et démarrer l'application, exécutez le script `Restore_and_Start.bat` contenu dans le dossier Scripts.
   - **Note** : Toutes les sauvegardes sont enregistrées dans l'arborescence `mssql/backups/`. Il est également possible de coller d'autres sauvegardes dans cette arborescence. La restauration s'effectuera à partir des sauvegardes les plus récentes.

Pour ajouter d’autres sauvegardes dans le dossier backups, veuillez respecter le format suivant :
- `BASE_SIGE_MINJEC_date.bak`
- `DICO_DB_MINJEC_date.bak`

Les dates doivent être au format jour/mois/année. Exemples :
- `BASE_SIGE_MINJEC_12062024.bak` : où `12062024` représente la date à laquelle la sauvegarde a été effectuée, soit le 12/06/2024.
- `DICO_DB_MINJEC_15052024.bak` : où `15052024` représente la date à laquelle la sauvegarde a été effectuée, soit le 15/05/2024.

Par défaut, ces dates sont ajoutées automatiquement lorsque vous effectuez les sauvegardes à travers le script `Make_backups.bat`.

## Conclusion
L’adoption de l’approche basée sur Docker, combinée à l’automatisation par scripts batch, a considérablement simplifié le processus de développement et de test. Cette méthode rend désormais l’environnement accessible même aux utilisateurs non techniques. Le dépôt GitHub joue un rôle central dans la solution en centralisant les ressources, ce qui facilite l’accès et la collaboration.

