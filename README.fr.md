# cursor-rp

> **⚠️ Projet archivé | Project Archived**
>
> Ce projet n'est plus maintenu. La version finale est v0.3.4 (2025-11-08). Merci pour votre attention et votre soutien.
>
> This project is no longer maintained. The final version is v0.3.4 (2025-11-08). Thank you for your attention and support.

[简体中文](README.md) | [English](README.en.md) | [Русский](README.ru.md) | [Español](README.es.md) | [العربية](README.ar.md)

## Introduction
Proxy inverse local. L'introduction est concise, intentionnellement.

## Installation
1. Visitez https://github.com/wisdgod/cursor-rp/releases pour télécharger dbwriter, modifier et ccursor
2. Renommez-les aux noms standards et placez-les dans le même répertoire

## Configuration et utilisation

### 1. Gestion des comptes (dbwriter)

dbwriter est un outil de gestion de comptes pour changer rapidement les informations de compte Cursor. Il prend en charge l'application directe, la gestion d'un pool de comptes, l'importation du compte actuel et d'autres modes.

#### Utilisation basique

```bash
# Application directe (sans sauvegarde)
dbwriter apply -a <TOKEN> -m pro -s google
dbwriter apply -a <ACCESS_TOKEN> -r <REFRESH_TOKEN> -e user@example.com -m pro_plus -s auth0

# Sauvegarder un compte dans le pool
dbwriter save -a <TOKEN> -e user@example.com -m pro -s google
dbwriter save -a <TOKEN> -e user@example.com -m free_trial -s github --apply

# Changer de compte depuis le pool
dbwriter use -e user@example.com
dbwriter use -m pro
dbwriter use -m pro --interactive
dbwriter use --interactive

# Consulter le compte Cursor actuel
dbwriter cursor show
dbwriter cursor import

# Consulter le pool de comptes
dbwriter list
dbwriter list -m pro
dbwriter list --verbose

# Gérer le pool de comptes
dbwriter manage remove user@example.com
dbwriter manage disable user@example.com
dbwriter manage stats

# Mode silencieux global
dbwriter -q list
dbwriter --quiet cursor import
```

#### Description des paramètres de commande

**Paramètres globaux**

| Paramètre | Abréviation | Description | Par défaut |
|-----------|-------------|-------------|------------|
| `--pool-db` | | Chemin de la base de données du pool de comptes | `./accounts.db` |
| `--quiet` | `-q` | Mode silencieux (réduire la sortie) | - |

**Sous-commande : apply** (application directe sans sauvegarde)

| Paramètre | Abréviation | Description | Requis |
|-----------|-------------|-------------|--------|
| `--access-token` | `-a` | Jeton d'accès | ✅ |
| `--refresh-token` | `-r` | Jeton de rafraîchissement | ❌ |
| `--email` | `-e` | Email du compte | ❌ |
| `--membership` | `-m` | Type d'abonnement | ✅ |
| `--signup-type` | `-s` | Méthode d'inscription | ✅ |

**Sous-commande : save** (sauvegarde dans le pool de comptes)

| Paramètre | Abréviation | Description | Requis |
|-----------|-------------|-------------|--------|
| `--access-token` | `-a` | Jeton d'accès | ✅ |
| `--refresh-token` | `-r` | Jeton de rafraîchissement | ❌ |
| `--email` | `-e` | Email du compte | ❌ |
| `--membership` | `-m` | Type d'abonnement | ✅ |
| `--signup-type` | `-s` | Méthode d'inscription | ✅ |
| `--apply` | | Appliquer immédiatement après la sauvegarde | ❌ |

**Sous-commande : use** (sélection et application depuis le pool de comptes)

| Paramètre | Abréviation | Description | Remarques |
|-----------|-------------|-------------|-----------|
| `--email` | `-e` | Sélection par email | Mutuellement exclusif avec `-m` |
| `--membership` | `-m` | Sélection par type d'abonnement | Mutuellement exclusif avec `-e` |
| `--interactive` | `-i` | Sélection interactive | - |

**Sous-commande : cursor** (opérations sur le compte actuel)

| Sous-commande | Description |
|---------------|-------------|
| `show` | Afficher les informations du compte Cursor actuel |
| `import` | Importer le compte actuel dans le pool de comptes |

**Sous-commande : list** (consulter le pool de comptes)

| Paramètre | Abréviation | Description |
|-----------|-------------|-------------|
| `--membership` | `-m` | Filtrer par type d'abonnement |
| `--verbose` | `-v` | Afficher des informations détaillées |

**Sous-commande : manage** (gestion du pool de comptes)

| Sous-commande | Description |
|---------------|-------------|
| `remove <EMAIL>` | Supprimer un compte |
| `disable <EMAIL>` | Désactiver un compte |
| `stats` | Afficher les statistiques |

**Types de valeurs supportés**

- **Types d'abonnement** : `free`, `pro`, `pro_plus`, `enterprise`, `free_trial`, `ultra`
- **Méthodes d'inscription** : `unknown`, `auth0`, `google`, `github`

#### Scénarios d'utilisation

**Scénario 1 : Première utilisation - Importer un compte existant**

```bash
# 1. Connectez-vous normalement dans Cursor
# 2. Importez le compte actuel dans le pool de comptes
dbwriter cursor import

# 3. Consultez le pool de comptes
dbwriter list
```

**Scénario 2 : Ajouter plusieurs comptes**

```bash
# Méthode 1 : Ajout manuel
dbwriter save -a <TOKEN1> -e work@company.com -m enterprise -s auth0
dbwriter save -a <TOKEN2> -e personal@gmail.com -m pro -s google

# Méthode 2 : Changer de connexion dans Cursor, puis importer
dbwriter cursor import  # Exécuter après connexion au compte 1
# Passer au compte 2 dans Cursor
dbwriter cursor import  # Exécuter après connexion au compte 2
```

**Scénario 3 : Changement rapide de compte**

```bash
# Changer par email
dbwriter use -e work@company.com

# Changer par type d'abonnement
dbwriter use -m pro

# Sélection interactive
dbwriter use --interactive
```

**Scénario 4 : Consulter le compte actuel**

```bash
dbwriter cursor show
```

**Scénario 5 : Utilisation temporaire d'un compte (sans sauvegarde)**

```bash
dbwriter apply -a <TOKEN> -m pro -s google
```

**Scénario 6 : Utilisation dans des scripts**

```bash
# Mode silencieux, réduire la sortie
dbwriter -q use -e user@example.com
```

#### Remarques

- **Fermez Cursor** avant de modifier les comptes
- Il est recommandé de définir un email pour chaque compte pour faciliter la gestion
- Les jetons peuvent être identiques (fournir uniquement `-a`) ou différents (fournir à la fois `-a` et `-r`)
- Les comptes sans email sont affichés comme `<Sans Email>` dans la liste
- Impossible d'utiliser `--quiet` avec `--interactive`
- Les comptes avec le même email sont automatiquement mis à jour (pas de doublons)

#### Référence rapide

```bash
# Référence rapide des commandes courantes
dbwriter cursor import             # Importer le compte actuel
dbwriter use -e <EMAIL>            # Changer de compte
dbwriter list                      # Consulter tous les comptes
dbwriter cursor show               # Consulter le compte actuel

# Gestion du pool de comptes
dbwriter manage stats              # Consulter les statistiques
dbwriter manage remove <EMAIL>     # Supprimer un compte
```

### 2. Patcher Cursor (modifier)
Fermez Cursor, appliquez le patch (à réexécuter après chaque mise à jour) :
```bash
# Utilisation basique (détection automatique du chemin Cursor)
/path/to/modifier --port 3000 --suffix .local

# Spécifier le chemin Cursor
/path/to/modifier --cursor-path /path/to/cursor --port 3000 --suffix .local

# Configuration HTTPS
/path/to/modifier --scheme https --port 443 --suffix .example.com

# Ignorer la détection des hosts (gestion manuelle des hosts)
/path/to/modifier --port 3000 --suffix .local --skip-hosts

# Sauvegarder la commande pour réutilisation
/path/to/modifier --port 3000 --suffix .local --save-command modifier.cmd

# Exemple complet
/path/to/modifier -C /path/to/cursor --scheme https -p 3000 --suffix .local --skip-hosts -s modifier.cmd --confirm --pass-token
```

### Paramètres de commande
| Paramètre | Abréviation | Description | Exemple |
|-----------|-------------|-------------|---------|
| `--cursor-path` | `-C` | Chemin d'installation de Cursor (optionnel, auto-détection) | `/Applications/Cursor.app` |
| `--scheme` | | Type de protocole (http/https) | `https` |
| `--port` | `-p` | Port de service | `3000` |
| `--suffix` | | Suffixe de domaine | `.local` |
| `--skip-hosts` | | Ignorer la modification du fichier hosts | - |
| `--save-command` | `-s` | Sauvegarder la commande dans un fichier | `modifier.cmd` |
| `--confirm` | | Confirmer les modifications (ne pas restaurer si état identique) | - |
| `--pass-token` | | Passer la validation du jeton (recommandé) | - |
| `--debug` | | Mode débogage | - |

### Notes spécifiques aux plateformes
- **Windows** : Exécution directe
- **macOS** : Signature manuelle requise en raison du SIP (comme l'exécution directe si SIP est désactivé)
  - Script de référence : [macos.sh](macos.sh)
- **Linux** : Nécessite de gérer le format AppImage
  - Script de référence : [linux.sh](linux.sh)

Les contributions PR pour améliorer les scripts d'adaptation aux plateformes sont les bienvenues !

### 3. Configurer les Hosts
Si vous utilisez le paramètre `--skip-hosts`, ajoutez manuellement ces enregistrements hosts :
```
127.0.0.1 api2.cursor.sh.local api3.cursor.sh.local repo42.cursor.sh.local api4.cursor.sh.local us-asia.gcpp.cursor.sh.local us-eu.gcpp.cursor.sh.local us-only.gcpp.cursor.sh.local
```

### 4. Démarrer le service
```bash
/path/to/ccursor
```

Pour les développeurs d'extensions ou de plugins d'IDE, ajoutez le paramètre `--debug` après le démarrage de ccursor pour voir les journaux détaillés.

## Détails de configuration
Dans `config.toml`, commentez ou supprimez les paramètres inconnus, **NE les laissez PAS vides**.

### Configuration de base
| Élément | Description | Type | Requis | Par défaut | Version supportée |
|---------|-------------|------|---------|------------|------------------|
| `check-updates` | Vérifier les mises à jour au démarrage | bool | ❌ | false | 0.2.0+ |
| `github-token` | Jeton d'accès GitHub | string | ❌ | "" | 0.2.0+ |
| ~~`usage-statistics`~~ | ~~Statistiques d'utilisation du modèle~~ | ~~bool~~ | ❌ | true | 0.2.1-0.2.x, déprécié, implémentation future dans la base de données |

### Configuration du service (`service-config`)
| Élément | Description | Type | Requis | Par défaut | Version supportée |
|---------|-------------|------|---------|------------|------------------|
| `tls` | Configuration du certificat TLS | object | ✅ | {cert_path="", key_path=""} | 0.3.0+ |
| `ip-addr` | Adresse IP d'écoute du service | object | ✅ | {ipv4="", ipv6=""} | 0.3.1+ |
| `port` | Port d'écoute du service | u16 | ✅ | - | Toutes versions |
| `dns-resolver` | Résolveur DNS (gai/hickory) | string | ❌ | "gai" | 0.2.0+ |
| `lock-updates` | Verrouiller les mises à jour | bool | ✅ | false | Toutes versions |
| `passthrough-unmatched` | Passer les requêtes non correspondantes | bool | ✅ | false | 0.3.3+ |
| `fake-email` | Configuration d'e-mail fictif | object | ❌ | {email="", sign-up-type="unknown", enable=false} | 0.2.0+ |
| `service-addr` | Configuration d'adresse de service | object | ❌ | {scheme="http", suffix="", port=0} | 0.2.0+ |
| ~~`proxy`~~ | ~~Configuration du serveur proxy~~ | ~~string~~ | ❌ | - | 0.2.0-0.2.x, déprécié, migré vers `proxies._` |

### Configuration du pool de proxys (`proxies`) - Nouveau en 0.3.0
| Élément | Description | Type | Requis | Par défaut |
|---------|-------------|------|---------|------------|
| `nom_clé` | Identifiant de configuration, correspond à `overrides.nom_clé` | string | ❌ | - |
| `_` | Configuration proxy par défaut | string | ❌ | "" |

### Configuration de mappage (`override-mapping`) - Nouveau en 0.3.0
| Élément | Description | Type | Requis | Par défaut |
|---------|-------------|------|---------|------------|
| `Préfixe du jeton Bearer` | Correspondance avec le nom de configuration | string | ❌ | - |
| `_` | Mappage par défaut | string | ❌ | - |

### Configuration des substitutions (`overrides.nom_config`)
| Élément | Description | Type | Requis | Par défaut | Version supportée |
|---------|-------------|------|---------|------------|------------------|
| `token` | Jeton d'authentification JWT | string | ❌ | - | Toutes versions |
| `traceparent` | Préserver l'identifiant de trace | bool | ❌ | false | 0.2.0+ |
| `client-key` | Hash de la clé client | string | ❌ | - | 0.2.0+ |
| `checksum` | Somme de contrôle combinée | object | ❌ | - | 0.2.0+ |
| `client-version` | Numéro de version client | string | ❌ | - | 0.2.0+ |
| `config-version` | Version de configuration (UUID) | string | ❌ | - | 0.3.0+ |
| `timezone` | Identifiant de fuseau horaire IANA | string | ❌ | - | Toutes versions |
| `privacy-mode` | Paramètres du mode de confidentialité | bool | ❌ | true | 0.3.0+ |
| `session-id` | Identifiant unique de session (UUID) | string | ❌ | - | 0.2.0+ |

### Notes de migration de version
#### 0.2.x → 0.3.0
- **Changements majeurs** :
  - Suppression de `current-override`, remplacé par le mappage dynamique des jetons Bearer
  - Migration de `service-config.proxy` vers `proxies._`
  - Ajout des nouvelles sections de configuration `proxies` et `override-mapping`
  - `ghost-mode` renommé en `privacy-mode`, avec des fonctionnalités améliorées
  - Ajout du nouveau champ `config-version`
  - Ajout de la configuration `tls` pour le support HTTPS

- **Relations de configuration** :
  1. Le client envoie un jeton Bearer (par exemple, `sk-test123`)
  2. `override-mapping` recherche le nom de configuration (par exemple, `sk-test` → `example`)
  3. Utilise les paramètres de proxy de `proxies.example`
  4. Utilise les configurations de substitution de `overrides.example`

**Notes spéciales** :
- Une chaîne vide `""` signifie pas de proxy
- La clé `_` est utilisée comme configuration par défaut/de repli
- Il est recommandé de commenter les éléments de configuration optionnels pour éviter les problèmes potentiels
- Le fichier de configuration sera toujours mis à jour lors de la fermeture de ccursor. Si vous devez modifier le fichier de configuration, choisissez GET /internal/ConfigUpdate ou fermez puis mettez à jour

## Interfaces internes

**Limitation** : Ne peut pas être déclenché via l'accès par domaine, nécessite un accès externe avec un proxy inverse personnalisé

### ConfigUpdate
**Fonction** : Déclencher le rechargement du service après la mise à jour du fichier de configuration, certaines configurations nécessitent un redémarrage du serveur

### CppCount
**Fonction** : Compteur simple pour les requêtes StreamCpp réussies et les réponses réussies

---

*Clause de non-responsabilité incluse dans l'EULA. Le projet peut cesser la maintenance à tout moment.*

Feel free!