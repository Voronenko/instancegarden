# Branch Deploy — Traefik TLS Architecture

## Certificate flow

```
Request: traefik.vagrant.fiks.im
    │
    ▼
Router label: tls=true (no certresolver)
    │
    ▼
Traefik SNI lookup in dynamic config ←── THIS IS WHERE IT MATTERS
    │
    ▼
tls.certificates in traefik-dynamic.yml:
  fiksim_fullchain.pem (SAN: *.vagrant.fiks.im)  →  MATCH
    │
    ▼
Serves ZeroSSL wildcard cert (CN=fiks.im)
```

## Why `tls.certificates` must be in dynamic config, not static

- Traefik v3's static config (`traefik.yml`) defines **providers, entrypoints, resolvers**
- Traefik v3's dynamic config (`dynamic.yml`) defines **routers, services, middlewares, certificates**
- Certificates in static config are **not used for SNI matching** — they're treated as config schema, not runtime certs
- Moving `tls.certificates` + `tls.stores` to dynamic config makes them available for TLS handshake SNI

## Pitfalls fixed

| Problem | Root cause | Fix |
|---------|-----------|-----|
| Self-signed cert on dashboard | `defaultGeneratedCert` took priority over `defaultCertificate` | Removed `defaultGeneratedCert` block |
| Still self-signed after removing `defaultGeneratedCert` | `tls.certificates` was in static config (ignored by v3 for SNI) | Moved `tls.certificates` + `tls.stores` to dynamic config |
| Dashboard router requesting LE cert | `tls.certresolver=le` on dashboard router — domain not publicly resolvable for HTTP challenge | Changed to `tls=true` (use static cert) |
| Plugin error on startup | Dummy plugin `github.com/your/module` active under `traefik_enable_api` guard | Changed guard to `traefik_enable_plugins` (defaults `false`) |

## Key files

- `templates/traefik.yml.j2` — Static config (providers, entrypoints, resolvers — NO tls block)
- `templates/traefik-dynamic.yml.j2` — Dynamic config (certificates, stores, options, middlewares)
- `templates/docker-compose-traefik.yml.j2` — Service labels (dashboard uses `tls=true`, app routers use `tls.certresolver=le`)
- `components/traefik.yml` — Ansible tasks to deploy + template render
