# Backend Helm chart

Helm chart nasadí backend aplikácie TaskList a pripojí ho k MongoDB.

## Predpoklady

V rovnakom Kubernetes namespace musí existovať Secret vytvorený MongoDB chartom.
Predvolený názov Secretu je `tasklist-mongodb-auth`.

## Inštalácia

```bash
helm upgrade --install tasklist-backend ./charts/backend \
  --namespace tasklist
```

## Parametre

| Parameter | Predvolená hodnota | Popis |
|---|---:|---|
| `replicaCount` | `2` | Počet backend replík |
| `image.repository` | `nadzady1/tasklist-backend` | Repozitár Docker obrazu |
| `image.tag` | `"1.0.0"` | Verzia Docker obrazu |
| `image.pullPolicy` | `IfNotPresent` | Politika sťahovania obrazu |
| `service.port` | `8080` | Interný port backend služby |
| `mongodb.secretName` | `tasklist-mongodb-auth` | Secret obsahujúci kľúč `mongo-url` |
| `mongodb.database` | `todos` | Názov MongoDB databázy |
| `appVersion` | `"1.0.0"` | Hodnota pre premennú `APP_VERSION` |
| `resources.requests.cpu` | `50m` | Požadované CPU |
| `resources.requests.memory` | `64Mi` | Požadovaná pamäť |
| `resources.limits.cpu` | `250m` | Maximálne CPU |
| `resources.limits.memory` | `256Mi` | Maximálna pamäť |

## Konfigurácia aplikácie

Chart nastavuje premenné prostredia:

- `MONGO_URL` zo Secretu,
- `MONGO_DB` z `mongodb.database`,
- `APP_VERSION` z `appVersion`,
- `PORT` zo `service.port`,
- `INSTANCE_NAME` z názvu aktuálneho Podu pomocou downward API.

Backend Service je typu `ClusterIP` a nie je priamo dostupná mimo klastra.
