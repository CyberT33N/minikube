# Mirror GitHub to GitLab

Make sure to enable `GitHub` and `Repository by URL`:
- https://gitlab.local.com/admin/application_settings/general#js-import-export-settings

Test if access is granted:

Get the CA chain:
```shell
openssl s_client -showcerts -connect gitlab.local.com:443 -servername gitlab.local.com </dev/null \
| awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/{print}' > /tmp/gitlab-ca-chain.pem
```

```shell
curl -sS --cacert /tmp/gitlab-ca-chain.pem -H "PRIVATE-TOKEN: $GITLAB_TOKEN" https://gitlab.local.com/api/v4/application/settings | jq '{import_sources, allow_local_requests_from_web_hooks_and_services, allow_local_requests_from_system_hooks}' | cat
```
- Should be `"import_sources": ["github", "git"]`

Test if you can create a repository:
```shell
 TS=$(date +%s); curl -sS -i --cacert /tmp/gitlab-ca-chain.pem -H "PRIVATE-TOKEN: $GITLAB_TOKEN" -H "Content-Type: application/json" --data "{\"name\":\"import-db-test-$TS\",\"path\":\"import-db-test-$TS\",\"visibility\":\"private\",\"default_branch\":\"main\",\"import_url\":\"https://github.com/git/git.git\"}" https://gitlab.local.com/api/v4/projects | head -n 20 | cat
HTTP/2 201 
```


Then run the script:
```shell
# Because gitlab is locally running with a self-signed certificate
export NODE_TLS_REJECT_UNAUTHORIZED=0

# https://github.com/settings/tokens
# Class Token > repo
export GITHUB_TOKEN='ghp_xxx'
# https://gitlab.local.com/-/user_settings/personal_access_tokens?page=1&state=active&sort=expires_asc
export GITLAB_TOKEN='glpat_xxx'
# https://gitlab.local.com
export GITLAB_BASE_URL='http://<gitlab-host-oder-ingress>'

export GITLAB_NAMESPACE_PATH='my-root-group'   # optional
export INCLUDE_FORKS=false                   # optional
export VISIBILITY=private                    # optional: private|internal|public
export DRY_RUN=true                          # zuerst testen
export CONCURRENCY=1                        # optional

npx -y tsx /home/t33n/Projects/environments/minikube/scripts/gitlab/mirror/github-to-gitlab.ts
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


<br><br>

# Test Connection

I just fetched the TLS chain and hit `/api/v4/version`: GitLab is reachable; TLS works. The 401 without token is expected. Here are the exact curl checks to verify access and permissions.

### 0) Zertifikatskette holen (einmalig)
```bash
openssl s_client -showcerts -connect gitlab.local.com:443 -servername gitlab.local.com </dev/null \
| awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/{print}' > /tmp/gitlab-ca-chain.pem
```

### 1) Reachability/Health
```bash
GITLAB_URL=https://gitlab.local.com
CACERT=/tmp/gitlab-ca-chain.pem

curl -sS -i --cacert "$CACERT" "$GITLAB_URL/-/health" | head -n 20
```
Erwartung: 200 OK.

### 2) API erreichbar
```bash
curl -sS -i --cacert "$CACERT" "$GITLAB_URL/api/v4/version"
```
Ohne Token kann 401 kommen; mit Token siehe unten.

### 3) Auth prüfen (Token/Scopes)
```bash
# setze dein PAT:
GITLAB_TOKEN='<DEIN_GITLAB_PAT_MIT_api_SCOPE>'

curl -sS --cacert "$CACERT" -H "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_URL/api/v4/user"
```
Erwartung: 200 + JSON mit deinem Benutzer.

### 4) Berechtigung „Projekt anlegen“ testen (optional)
Erzeugt ein Testprojekt. Wenn 201 → OK; wenn 403 → dir fehlt die Berechtigung.
```bash
TMP=can-i-create-$RANDOM
curl -sS -i --cacert "$CACERT" -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  -X POST "$GITLAB_URL/api/v4/projects" \
  -d "name=$TMP" -d "visibility=private"
```

Wenn 403:
- Prüfe, dass das PAT den Scope **api** hat (nicht nur read_api).
- Adminbereich: `Settings → Visibility and access controls → Project creation level` darf nicht „No one“ sein.
- `projects_limit` des Users darf nicht 0 sein.
- Falls in eine Gruppe: User muss dort mindestens Owner sein.

Kurzfazit
- GitLab Local ist erreichbar, Zertifikate funktionieren mit `--cacert`.
- 401 ohne Token ist normal; die 403 aus deinem Script deuten auf fehlende „Projekt anlegen“-Berechtigung oder falsche Token-Scopes hin.