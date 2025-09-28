Das Einfachste ist natürlich, wenn man einfach nur das Helmchart upgradet und dann komplett alles löscht. Da **MUSS** man sich nicht spezifisch darum kümmern, welche GitLab Deployments und PVS und so weiter man löscht. Hier **MUSS** aber dementsprechend auch beachtet werden, dass dann natürlich auch alle Sachen aus GitLab entfernt werden. Das heißt, die erstellten Gruppen alles drum und dran, was natürlich nicht gut ist.



<br><br>
<br><br>


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


<br><br>


### 🧼 Schritt 4: Bestehende GitLab-Installation sauber entfernen (Clean Teardown)
- Empfohlen (Dev/Minikube): Namespace neu erstellen
```shell
kubectl config use-context minikube

# Option A: Namespace komplett neu (schnell & sauber)
kubectl delete namespace dev --wait=false || true
kubectl wait --for=delete ns/dev --timeout=120s || true
kubectl create namespace dev || true

# Option B: Zielgerichtetes Aufräumen im bestehenden Namespace
helm uninstall gitlab-dev -n dev --no-hooks || true
helm uninstall gitlab-dev-gitlab-runner -n dev --no-hooks || true

# Alte Helm-Release-Secrets entfernen (falls vorhanden)
kubectl -n dev delete secret -l "owner=helm,name=gitlab-dev" --ignore-not-found=true

# Chart-Ressourcen aus alten Schemas entfernen (beide gängigen Label-Schemata)
kubectl -n dev delete all,cm,secret,ingress,svc,deploy,sts,job,cronjob,networkpolicy,role,rolebinding,sa \
  -l app.kubernetes.io/instance=gitlab-dev --ignore-not-found=true
kubectl -n dev delete all,cm,secret,ingress,svc,deploy,sts,job,cronjob,networkpolicy,role,rolebinding,sa \
  -l release=gitlab-dev --ignore-not-found=true

# Persistente Volumes Claims entfernen (vermeidet Immutable-Fehler beim Neuaufsetzen)
kubectl -n dev delete pvc -l app.kubernetes.io/instance=gitlab-dev --ignore-not-found=true
kubectl -n dev delete pvc -l release=gitlab-dev --ignore-not-found=true

# Optional: Falls der StorageClass-Reclaimer PVs nicht automatisch löscht
# kubectl get pv | awk '/gitlab-dev/ {print $1}' | xargs -r kubectl delete pv
```

Hinweis: Falls der Release auf `pending-*` steht, hilft oft ein `helm uninstall --no-hooks` bzw. das Löschen der Jobs/CMs per Label wie oben.


<br><br>


### 🚀 Schritt 5: Frische Installation (Latest Chart)
- Nutze das vendorte Chart-Verzeichnis und deine Custom Values. Wichtig bei neueren Charts: `installCertmanager` statt `certmanager.install` verwenden bzw. beim Befehl setzen.
```shell
CHART_DIR="/home/t33n/Projects/environments/minikube/gitlab/Chart"
VALUES_FILE="/home/t33n/Projects/environments/minikube/gitlab/custom-values.yaml"

helm install gitlab-dev "$CHART_DIR" \
  -n dev \
  -f "$VALUES_FILE" \
  --set installCertmanager=false \
  --set gitlab.migrations.enabled=true \
  --atomic \
  --timeout 30m \
  --create-namespace
```

- Optional (separat installierter Runner): danach Runner erneut deployen
```shell
cd /home/t33n/Projects/environments/minikube/gitlab
./setup-runner._sh
```

- Warten bis UI bereit ist
```shell
kubectl -n dev get pods | grep gitlab-dev-webservice-default
until kubectl get pods -n dev | grep gitlab-dev-webservice-default | grep Running | grep 2/2; do
  echo "Waiting for healthy gitlab-dev-webservice-default Pods..."; sleep 10; done
```
