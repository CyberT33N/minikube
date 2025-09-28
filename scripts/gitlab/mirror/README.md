# Mirror GitHub to GitLab

```shell
export GITHUB_TOKEN=ghp_xxx
# https://gitlab.local.com/-/user_settings/personal_access_tokens?page=1&state=active&sort=expires_asc
export GITLAB_TOKEN=glpat_xxx
# https://gitlab.local.com
export GITLAB_BASE_URL=http://<gitlab-host-oder-ingress>
export GITLAB_NAMESPACE_PATH=my-root-group   # optional
export INCLUDE_FORKS=false                   # optional
export VISIBILITY=private                    # optional: private|internal|public
export DRY_RUN=true                          # zuerst testen
export CONCURRENCY=4                         # optional

node --experimental-strip-types /home/t33n/Projects/environments/minikube/scripts/gitlab/mirror/github-to-gitlab.ts
```

## Umgebungsvariablen

- **GITHUB_TOKEN** (erforderlich): GitHub Personal Access Token. Benötigte Scopes: **repo** (priv. Repos) und **read:org** (Org-Listing). Wird für die GitHub API genutzt und für den Import per HTTPS Basic Auth (`x-access-token` als Benutzername, Token als Passwort).
- **GITLAB_TOKEN** (erforderlich): GitLab Personal Access Token mit Scope **api**. Wird verwendet, um Gruppen/Projekte anzulegen und Importe zu starten.
- **GITLAB_BASE_URL** (erforderlich): Basis-URL deiner GitLab-Instanz, z. B. `http://gitlab.minikube.local`. Ohne nachfolgenden Slash.
- **GITLAB_NAMESPACE_PATH** (optional): Ziel-Gruppe in GitLab (z. B. `company` oder `company/dev`). Wenn gesetzt, werden Projekte darunter angelegt; Org-Repos erhalten automatisch passende Untergruppen. Wenn nicht gesetzt, wird dein Benutzer-Namespace verwendet.
- **INCLUDE_FORKS** (optional, Standard: `false`): Wenn `true`, werden Forks mit migriert. Standardmäßig werden Forks übersprungen.
- **VISIBILITY** (optional, Standard: `private`): Sichtbarkeit der neu erstellten Projekte in GitLab. Erlaubt: `private` | `internal` | `public`.
- **DRY_RUN** (optional, Standard: `false`): Wenn `true`, werden keine Projekte erstellt. Stattdessen werden die geplanten Aktionen detailliert geloggt.
- **CONCURRENCY** (optional, Standard: `4`, Bereich: `1`–`20`): Anzahl paralleler Worker für die Migration.

### Weitere optionale Variable
- **GITHUB_USER** (optional): Überschreibt den GitHub-Login, dessen Repositories verarbeitet werden sollen. Standard ist der Benutzer, der durch `GITHUB_TOKEN` authentifiziert ist.

### Hinweise
- Tokens werden nicht in Logs ausgegeben. Die Import-URL setzt den GitHub-Token nur intern für den Import ein.
- Bei GitHub- oder GitLab-Rate-Limits werden automatische **Retry/Backoff**-Strategien genutzt; der Fortschritt wird mit **UTF‑8-Icons** klar geloggt.