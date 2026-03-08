# TODO


## Activate git-lfs

## Ergebnis

In deinem Projekt ist **Git LFS serverseitig bereits aktiv**. Das Problem ist in deinem Setup **nicht LFS an sich**, sondern die **TLS-Vertrauenskette** für den HTTPS-LFS-Endpunkt.

```11:19:~/Projects/environments/minikube/gitlab/custom-values.yaml
global:
  minio:
    enabled: true

  ingress:
    configureCertmanager: false
    class: "nginx"
    tls:
      external: true
```

```372:377:~/Projects/environments/minikube/gitlab/Chart/values.yaml
    lfs:
      enabled: true
      proxy_download: true
      bucket: git-lfs
      connection: {}
```

```1382:1397:~/Projects/environments/minikube/gitlab/Chart/values.yaml
shared-secrets:
  enabled: true
  rbac:
    create: true
  selfsign:
    image:
      repository: registry.gitlab.com/gitlab-org/build/cng/cfssl-self-sign
    keyAlgorithm: "rsa"
    keySize: "4096"
    expiry: "3650d"
    caSubject: "GitLab Helm Chart"
  env: production
```

Der String `GitLab Helm Chart` aus dem Chart passt exakt zu deinem Fehler mit `unknown authority`. Das heißt: Dein GitLab liefert aktuell ein **vom Chart selbst signiertes Zertifikat** aus, und **dein lokaler Git-/Git-LFS-Client vertraut dieser CA nicht**.

Zusätzlich ist im Repo schon sichtbar, dass der **Runner** dafür eigens eine Zertifikatskette bekommt, dein **Host-System** aber nicht:

```45:48:~/Projects/environments/minikube/gitlab/custom-values.yaml
gitlab-runner:
  install: true
  certsSecretName: gitlab-dev-wildcard-tls-chain
```

## Empfohlene Lösung

Die empfohlene Lösung für **dein** Projekt ist:

**Nicht** bei den automatisch erzeugten Helm-Self-Signed-Zertifikaten für externe Clients bleiben, sondern für `gitlab.local.com` ein **lokal vertrauenswürdiges Zertifikat** verwenden, idealerweise mit `mkcert`, und dieses als festes Ingress-TLS-Secret in GitLab einzuhängen.

Warum das die beste Lösung ist:
- Git bleibt weiter per SSH erreichbar, das musst du nicht umbauen.
- Git LFS nutzt trotzdem HTTPS und braucht dort eine gültige Vertrauenskette.
- Du löst damit nicht nur LFS, sondern auch Browser, API-Clients und andere lokale Tools sauber.
- Du musst nicht auf jedem neuen Client die zufällig erzeugte Helm-CA manuell nachpflegen.

## So musst du es einstellen

### 1. Ein lokal vertrauenswürdiges Zertifikat für `gitlab.local.com` erzeugen
Empfohlen mit `mkcert`:

```bash
mkcert -install
mkcert gitlab.local.com
```

Dadurch hast du:
- ein Zertifikat für `gitlab.local.com`
- eine lokale CA, der dein Host bereits vertraut

### 2. Das Zertifikat als Kubernetes-TLS-Secret anlegen
Beispiel:

```bash
kubectl create secret tls gitlab-local-tls \
  --namespace dev \
  --cert=./gitlab.local.com.pem \
  --key=./gitlab.local.com-key.pem
```

### 3. Für den Runner zusätzlich die CA als Secret bereitstellen
Weil dein Projekt bereits `gitlab-runner.certsSecretName` nutzt, solltest du das beibehalten, aber auf **deine** CA umstellen.

Beispiel:

```bash
kubectl create secret generic gitlab-local-ca \
  --namespace dev \
  --from-file=gitlab.local.com.crt="$(mkcert -CAROOT)/rootCA.pem"
```

### 4. `gitlab/custom-values.yaml` entsprechend setzen
So sollte die Zielkonfiguration aussehen:

```yaml
global:
  ingress:
    configureCertmanager: false
    class: "nginx"
    tls:
      external: true
      secretName: gitlab-local-tls

gitlab-runner:
  install: true
  certsSecretName: gitlab-local-ca
```

Wichtig:
- `secretName` ist das **Ingress-Zertifikat**
- `certsSecretName` ist die **CA-Kette**, der der Runner vertrauen soll

### 5. Das GitLab-Release mit diesen Werten neu ausrollen
Danach muss die Release-Konfiguration per Helm übernommen werden.

Typisch in deinem Projekt wäre das anschließend ein `helm upgrade` gegen `./gitlab/Chart` mit `./gitlab/custom-values.yaml`.

### 6. Falls Git auf deinem Host die CA trotzdem nicht nutzt: Git explizit auf die CA zeigen
Mit `mkcert` ist das oft nicht nötig, aber falls Git/LFS weiter meckert, dann lokal oder global:

```bash
git config --global http."https://gitlab.local.com".sslCAInfo "$(mkcert -CAROOT)/rootCA.pem"
```

### 7. Die Locking-Warnung separat abschalten
Das ist nicht der eigentliche TLS-Fehler, aber sinnvoll für Ruhe im Setup:

```bash
git config --local lfs.https://gitlab.local.com/root/prompts-cheat-sheet.git/info/lfs.locksverify false
```

## Was du nicht tun solltest

Nicht empfehlenswert ist:

```bash
git config --global http."https://gitlab.local.com".sslVerify false
```

oder

```bash
GIT_SSL_NO_VERIFY=1
```

Das wäre nur ein unsauberer Bypass und nicht die richtige Lösung.

## Kurzfassung

Für dein aktuelles Projekt gilt:

- **Git LFS ist schon aktiviert**
- der Blocker ist die **nicht vertrauenswürdige Helm-Self-Signed-CA**
- die beste Lösung ist ein **eigenes, lokal vertrauenswürdiges TLS-Zertifikat** für `gitlab.local.com`
- dieses Zertifikat muss als **Ingress-Secret** in GitLab rein
- die zugehörige **CA** muss an den **Runner** und bei Bedarf an **Git/Git LFS auf dem Host**
- die **Locking-API-Warnung** kannst du zusätzlich clientseitig deaktivieren

Wenn du willst, kann ich dir als Nächstes ein **konkretes Umsetzungs-Runbook nur für dein Projekt** schreiben, mit den exakten Befehlen in der richtigen Reihenfolge für `mkcert`, `kubectl create secret`, die YAML-Anpassung und das anschließende `helm upgrade`.