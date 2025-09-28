** NOT VERIFIED YET **


### 🎯 Ziel
- https://docs.gitlab.com/charts/installation/upgrade/

Upgrade des vendorten GitLab Helm Charts auf die jeweils aktuellste stabile Version („latest stable“) mit validierten, wiederholbaren Schritten. Gilt für `minikube`/Namespace `dev` und die vendorte Struktur unter `gitlab/Chart`.

### 📌 Kontext (Ist-Stand)
- Vendortes Chart liegt unter `gitlab/Chart`.
- Aktueller Stand (Beispiel): Version und App-Version stehen in `gitlab/Chart/Chart.yaml` und `gitlab/Chart/values.yaml`.
- Custom Overrides in `gitlab/custom-values.yaml`.
- Deployment/Upgrade erfolgt lokal mit `helm install|upgrade gitlab-dev ./gitlab/Chart -n dev -f ./gitlab/custom-values.yaml`.

### ✅ Voraussetzungen
- Kubernetes-Kontext ist `minikube`.
- Helm ist installiert; Plugin `helm-diff` optional, aber empfohlen.
- Git-Arbeitsbaum ist sauber (Änderungen committed), damit das Vendoring als Pull Request nachvollziehbar ist.

```shell
kubectl config use-context minikube
helm repo add gitlab https://charts.gitlab.io || true
helm repo update
```



<br><br>


### 🧭 Schritt 1: Neueste stabile Chart-Version ermitteln
- Ohne Pre-Release-Versionen (default):
```shell
helm search repo gitlab/gitlab --versions | awk 'NR==2{print $2}'
```
- Alternativ JSON + jq:
```shell
LATEST=$(helm search repo gitlab/gitlab -o json | jq -r '.[0].version')
echo "$LATEST"
```





<br><br>


### 🧳 Schritt 2: Chart vendoren (sauber, idempotent)
- Charts werden bewusst im Repo „vendored“. Ersetze den Ordner `gitlab/Chart` vollständig durch die neueste Version.
- Wichtig: Nutze rsync mit `--delete`, damit alte Dateien entfernt werden.
```shell
set -euo pipefail
REPO_ROOT=/home/t33n/environments/minikube
CHART_DIR="$REPO_ROOT/gitlab/Chart"
TMP_DIR=$(mktemp -d)

# LATEST ermitteln (falls noch nicht geschehen)
LATEST=${LATEST:-$(helm search repo gitlab/gitlab -o json | jq -r '.[0].version')}

# Download & Entpacken ins TMP
helm pull gitlab/gitlab --version "$LATEST" --untar --untardir "$TMP_DIR"

# Vendor (hart ersetzend)
rsync -a --delete "$TMP_DIR/gitlab/" "$CHART_DIR/"
rm -rf "$TMP_DIR"

# Versionen prüfen
grep -E '^(version:|appVersion:)' "$CHART_DIR/Chart.yaml" || true
grep -E '^\s*gitlabVersion:' "$CHART_DIR/values.yaml" || true
```





<br><br>

### 🔍 Schritt 3: Änderungen validieren (Preflight)
- Lint der vendorten Charts:
```shell
helm lint "$CHART_DIR" -f "$REPO_ROOT/gitlab/custom-values.yaml"

# E.g. 
helm lint /home/t33n/environments/minikube/gitlab/Chart -f /home/t33n/environments/minikube/gitlab/custom-values.yaml
```

- Helm Diff Plugin installieren und Diff prüfen:
```shell
helm plugin list | grep diff || helm plugin install https://github.com/databus23/helm-diff
helm diff upgrade gitlab-dev "$CHART_DIR" -n dev -f "$REPO_ROOT/gitlab/custom-values.yaml" || true

# E.g.
helm plugin list | grep diff || helm plugin install https://github.com/databus23/helm-diff
helm diff upgrade gitlab-dev "/home/t33n/environments/minikube/gitlab/Chart " -n dev -f "/home/t33n/environments/minikube/gitlab/custom-values.yaml" || true
```

- Trockenlauf mit ausführlichem Debug:
```shell
helm upgrade --dry-run --debug \
  gitlab-dev "$CHART_DIR" \
  -n dev \
  -f "$REPO_ROOT/gitlab/custom-values.yaml"

# E.g.
helm upgrade --dry-run --debug \
  gitlab-dev "/home/t33n/Projects/environments/minikube/gitlab/Chart " \
  -n dev \
  -f "/home/t33n/Projects/environments/minikube/gitlab/custom-values.yaml" \
  --atomic \
  --timeout 30m
```

Hinweise für Breaking Changes:
- Prüfe die Upstream-Release-Notes und Version-Mappings:
  - Charts: [docs.gitlab.com/charts] (Release Notes, Changelog)
  - Version mapping zwischen Chart und GitLab-App: [Version mappings]
- Prüfe, ob Schlüssel in `custom-values.yaml` deprecated/verschoben sind (Diff/Templating-Ausgabe beachten). Falls nötig, `custom-values.yaml` anpassen.

### 🚀 Schritt 4: Upgrade ausführen (mit automatischem Rollback)
```shell
helm upgrade gitlab-dev "$CHART_DIR" \
  -n dev \
  -f "$REPO_ROOT/gitlab/custom-values.yaml" \
  --set gitlab.migrations.enabled=true \
  --atomic \
  --timeout 30m

# E.g.
helm upgrade gitlab-dev "/home/t33n/Projects/environments/minikube/gitlab/Chart " \
  -n dev \
  -f "/home/t33n/Projects/environments/minikube/gitlab/custom-values.yaml" \
  --set gitlab.migrations.enabled=true \
  --atomic \
  --timeout 30m
```

### 🧪 Schritt 5: Health-Checks nach dem Upgrade
```shell
# Webservice Pods müssen bereit sein
kubectl get pods -n dev | grep gitlab-dev-webservice-default

# Optional: auf vollständige Readiness warten
until kubectl get pods -n dev | grep gitlab-dev-webservice-default | grep Running | grep 2/2; do
  echo "Waiting for healthy gitlab-dev-webservice-default Pods..."
  sleep 10
done

# Status-Überblick
kubectl get pods,svc,ingress -n dev
```
- UI öffnen (abhängig von `global.hosts.domain`/`externalIP`), z. B. `https://gitlab.local.com`.

### 🔁 Rollback bei Problemen
```shell
# letzte Revision ermitteln
helm history gitlab-dev -n dev
# z. B. auf Revision 1 zurück
helm rollback gitlab-dev 1 -n dev
```

### 🏗️ (Optional) Runner neu anwenden/prüfen
Falls der Runner separat deployt wird (z. B. via `gitlab/setup-runner._sh`):
```shell
cd "$REPO_ROOT/gitlab"
./setup-runner._sh
```
Oder wenn Runner als Subchart verwaltet wird, verifiziere die Runner-Pods:
```shell
kubectl get pods -n dev | grep runner
```

### 🔐 (Optional) Backup/Recovery (Prod-Empfehlung)
- Vor größeren Upgrades: Datenbank- und Artefakt-Backups erstellen.
- Toolbox/Backups siehe GitLab-Charts-Dokumentation (Backup/Restore).

### 🧭 Entscheidungsleitfaden „Latest vs. Pinning“
- In Dev/Test: „latest stable“ ist ok, solange Rollback vorbereitet ist.
- In Prod: immer pinnen (Chart-Version), Release Notes lesen, Migrationsfenster planen, DR-Plan testen.

### 📓 Änderungsnachweis
- Committe alle Änderungen unter `gitlab/Chart/**` und referenziere die neue Chart-Version im Commit-Text.
- Dokumentiere besondere Migrationsschritte/Breaking Changes knapp in `docs/deployments/gitlab/upgrade.md`.

### 🔗 Referenzen
- GitLab Helm Chart Doku: `[docs.gitlab.com/charts]`
- Version mappings: `[Charts → Version mappings]`
- Changelog/Release Notes: `[GitLab Helm Chart Changelog]`

<!--
Bitte die Platzhalter-Links oben im PR mit echten Deep-Links hinterlegen, z. B.:
- https://docs.gitlab.com/charts/
- https://docs.gitlab.com/charts/installation/version_mappings/
- https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/CHANGELOG.md
-->
