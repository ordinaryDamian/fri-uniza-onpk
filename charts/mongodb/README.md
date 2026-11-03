# MongoDB Helm chart

Helm chart nasadí jednu MongoDB 7 inštanciu pre aplikáciu TaskList.

## Inštalácia

```bash
helm upgrade --install tasklist-mongodb ./charts/mongodb \
  --namespace tasklist \
  --create-namespace
```

## Parametre

| Parameter | Predvolená hodnota | Popis |
|---|---:|---|
| `image.repository` | `mongo` | Repozitár Docker obrazu MongoDB |
| `image.tag` | `"7"` | Verzia Docker obrazu |
| `image.pullPolicy` | `IfNotPresent` | Politika sťahovania obrazu |
| `service.port` | `27017` | Interný port služby MongoDB |
| `resources.requests.cpu` | `100m` | Požadované CPU |
| `resources.requests.memory` | `256Mi` | Požadovaná pamäť |
| `resources.limits.cpu` | `500m` | Maximálne CPU |
| `resources.limits.memory` | `512Mi` | Maximálna pamäť |

## Prihlasovacie údaje

Chart vytvorí Secret `<release>-auth` s kľúčmi:

- `username`
- `password`
- `mongo-url`

Pri aktualizácii existujúcej Helm release sa prihlasovacie údaje zachovajú.

## Úložisko

MongoDB používa `emptyDir`. Dáta prežijú reštart kontajnera v rovnakom Pode,
ale po odstránení alebo nahradení Podu sa stratia.
