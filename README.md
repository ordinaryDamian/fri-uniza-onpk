# TaskList

A three tier task list. Add a task, tick it off, delete it. That is the whole
application.

Your job is not to change it. Your job is to package it, deploy it, and ship it.

## The three tiers

```
  browser  ->  frontend :3000  ->  backend :8080  ->  mongodb :27017
               Node + Express      Node + Express     stock image
               serves the UI       REST API           stores the todos
               proxies /api
```

| Folder | What it is |
|---|---|
| `frontend/` | The web UI and its server |
| `backend/` | The REST API |
| none | MongoDB, use the official `mongo` image as it is |

MongoDB needs nothing built. It creates its collection on the first write.

Each folder has a `README.md` listing its port and its environment variables.
That is all you need.

## Environment variables you will need

| Tier | Variable | Example |
|---|---|---|
| frontend | `BACKEND_URL` | `http://backend:8080` |
| frontend | `APP_VERSION` | `1.0.0` |
| backend | `MONGO_URL` | `mongodb://root:secret@mongodb:27017/?authSource=admin` |
| backend | `APP_VERSION` | `1.0.0` |
| mongodb | `MONGO_INITDB_ROOT_USERNAME` | `root` |
| mongodb | `MONGO_INITDB_ROOT_PASSWORD` | `secret` |

`MONGO_URL` contains a password. It is not the same kind of thing as
`APP_VERSION`, and it should not be handled the same way.

## Rules

1. Nothing from the tables above may be baked into an image. The same image must
   run anywhere with different values.
2. One image per tier. Two Dockerfiles, since MongoDB is used as published.
3. `latest` is not a version.

## You can check each tier on its own

Neither tier crashes when the thing below it is missing, so you can verify your
images one at a time.

| Tier | Your image is correct when |
|---|---|
| backend | `curl localhost:8080/api/info` returns your `APP_VERSION`, with `databaseConnected: false` |
| frontend | the page loads and the status line says the backend is unreachable |

Both of those are a pass.

## Useful to know

- `APP_VERSION` appears in the page footer. Once you are deploying through a
  pipeline, that is how you prove the running version is the one you built.
- The footer also shows which backend instance answered. When you scale to more
  than one replica, watch it change.

## 1. Kontajnerizácia

Frontend a backend používajú oficiálny base image
`node:24-bookworm-slim`.

Dockerfiles inštalujú iba produkčné závislosti, kopírujú
potrebné aplikačné súbory a spúšťajú aplikáciu pod používateľom
`node`. Konfigurácia aplikácie sa odovzdáva pri spustení.

### Overenie

- Frontend: stránka sa načítala cez port 3000, zobrazila
  verziu 1.0.0 a stav „backend unreachable“.
- Backend: GET /api/info na porte 8080 vrátil HTTP 200,
  verziu 1.0.0, instance backend-test a databaseConnected: false.
- Používateľ v oboch kontajneroch: uid=1000(node), gid=1000(node).

### Porovnanie veľkostí images

Veľkosti boli zistené príkazom docker image inspect,
pomocou atribútu Size. Hodnoty sú v bajtoch.

| Image | Pred .dockerignore | Po .dockerignore | Rozdiel |
|---|---:|---:|---:|
| Frontend | 339184070 | 339184070 | 0 |
| Backend | 350006776 | 350006776 | 0 |

Veľkosti zostali rovnaké, pretože Dockerfiles už používajú
explicitné COPY iba pre potrebné súbory. Súbory .dockerignore
vylučujú nepotrebné a citlivé súbory z build contextu.

### Docker Hub

Images boli nahrané do vlastných verejných Docker Hub repozitárov:

| Komponent | Image |
|---|---|
| Frontend | `nadzady1/tasklist-frontend:1.0.0` |
| Backend | `nadzady1/tasklist-backend:1.0.0` |

Dostupnosť oboch tagov 1.0.0 bola overená v prehliadači
bez prihlásenia do Docker Hub.