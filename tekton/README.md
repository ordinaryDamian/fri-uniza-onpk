# TaskList CI/CD s Tektonom

Pipeline zostaví frontend a backend, odošle images na Docker Hub, nasadí ich
pomocou Helm chartov a vykoná smoke test aplikácie.

## Použité verzie

- Tekton Pipelines `v1.15.3`
- Tekton CLI `v0.46.1`
- Helm `v4.3.1`
- Buildah image pripnutý na nemenný OCI digest

## Priebeh Pipeline

```text
clone → build-backend ─┐
      → build-frontend ├→ deploy → smoke-test
                       ┘
```

Tasky `build-backend` a `build-frontend` sa vykonávajú paralelne.

Pipeline vykoná tieto kroky:

1. naklonuje zadanú Git revíziu do spoločného PVC,
2. zostaví frontend a backend pomocou Buildah,
3. odošle oba images na Docker Hub,
4. nasadí MongoDB, backend a frontend pomocou Helm,
5. overí `/healthz`, `/version`, `/api/info` a pripojenie k MongoDB.

## Súbory

| Súbor | Účel |
|---|---|
| `workspace-pvc.yaml` | Spoločný workspace pre zdrojový kód |
| `rbac.yaml` | ServiceAccount a namespace-scoped oprávnenia |
| `tasks/git-clone.yaml` | Klonovanie Git repozitára |
| `tasks/build-push.yaml` | Build a push jedného image |
| `tasks/helm-deploy.yaml` | Nasadenie troch Helm releases |
| `tasks/smoke-test.yaml` | Kontrola aplikácie po nasadení |
| `pipeline.yaml` | Definícia celej CI/CD Pipeline |
| `pipelinerun.yaml` | Reprodukovateľný príklad spustenia |

## Registry Secret

Kubernetes Secret `dockerhub-credentials` sa vytvára ručne v namespace
`tasklist`. Obsahuje Docker Hub personal access token s oprávnením
`Repo Read & Write`.

Secret ani token nie sú uložené v tomto repozitári.

## Aplikovanie manifestov

Namespace `tasklist` musí existovať:

```bash
kubectl create namespace tasklist
```

Ak už existuje, hlásenie `AlreadyExists` je neškodné.

Manifesty sa aplikujú v tomto poradí:

```bash
kubectl apply -f tekton/workspace-pvc.yaml
kubectl apply -f tekton/rbac.yaml
kubectl apply -f tekton/tasks/
kubectl apply -f tekton/pipeline.yaml
```

Pred spustením musí existovať Secret:

```text
dockerhub-credentials
```

## Spustenie

Pred novým vydaním sa v `pipelinerun.yaml` nastaví nový parameter
`image-tag`. PipelineRun sa vytvorí príkazom:

```bash
kubectl create -f tekton/pipelinerun.yaml
tkn pipelinerun logs --last --follow -n tasklist
```

Stav a výsledky:

```bash
tkn pipelinerun list -n tasklist
tkn pipelinerun describe --last -n tasklist
```

## Overený beh

PipelineRun pre tag `1.0.1` skončil stavom `Succeeded`.

| Výsledok | Hodnota |
|---|---|
| Git commit | `684b8aad903f34686aff9856558febfb2ac39e8e` |
| Backend digest | `sha256:daf4ae2c6ac4fce340495fc45f4af0fdd854466407cb05675da2636dabe9cb01` |
| Frontend digest | `sha256:e59612f4b2c98f3694c922a2f6e8cdbcea04c032d99d08b493ed6d98eba686e0` |
| Nasadený tag | `1.0.1` |

Smoke test potvrdil verziu `1.0.1` na frontende aj backende a hodnotu
`databaseConnected: true`.
