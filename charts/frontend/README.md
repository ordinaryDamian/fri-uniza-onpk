# Frontend Helm chart

Helm chart nasadí frontend aplikácie TaskList a nastaví proxy komunikáciu s backendom.

## Predpoklady

Backend musí byť dostupný na adrese nastavenej v `backendUrl`.
Predvolená adresa je `http://tasklist-backend:8080`.

## Inštalácia

```bash
helm upgrade --install tasklist-frontend ./charts/frontend \
  --namespace tasklist
```

## Parametre

| Parameter | Predvolená hodnota | Popis |
|---|---:|---|
| `replicaCount` | `2` | Počet frontend replík |
| `image.repository` | `nadzady1/tasklist-frontend` | Repozitár Docker obrazu |
| `image.tag` | `"1.0.0"` | Verzia Docker obrazu |
| `image.pullPolicy` | `IfNotPresent` | Politika sťahovania obrazu |
| `service.type` | `NodePort` | Typ Kubernetes Service |
| `service.port` | `3000` | Interný port frontendu |
| `service.nodePort` | `30080` | Externý NodePort pri type `NodePort` |
| `backendUrl` | `http://tasklist-backend:8080` | Interná adresa backend služby |
| `appVersion` | `"1.0.0"` | Hodnota pre premennú `APP_VERSION` |
| `resources.requests.cpu` | `25m` | Požadované CPU |
| `resources.requests.memory` | `32Mi` | Požadovaná pamäť |
| `resources.limits.cpu` | `100m` | Maximálne CPU |
| `resources.limits.memory` | `128Mi` | Maximálna pamäť |

## Prístup k aplikácii

Pri predvolenom type `NodePort` je aplikácia dostupná na:

```text
http://<IP-servera>:30080
```

V použitom Minikube prostredí:

```text
http://192.168.0.123:30080
```

Backend a MongoDB používajú služby typu `ClusterIP` a nie sú priamo
sprístupnené mimo Kubernetes klastra.
