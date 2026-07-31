# Colaboradores

Quién es quién en Exactamente, qué puede hacer cada uno, y cómo sumarse.

---

## El roster

| Usuario de GitHub | Rol | Repos | Puede mergear a rama protegida |
|---|---|---|---|
| [`@juanpe44`](https://github.com/juanpe44) | Maintainer · creador del proyecto | los 5 | ✅ |

<!--
Sumate acá en tu primer PR al workspace. Una fila, en este formato:

| [`@tu-usuario`](https://github.com/tu-usuario) | Rol | Repos que tocás | ❌ |

Roles en uso: Maintainer, Colaborador. Si no estás seguro, poné Colaborador.
-->

Si acabás de entrar y no estás en esta tabla, agregate — es tu primer PR al workspace y sirve de
prueba de que tenés el setup andando.

---

## Cómo pedir acceso

Los repos viven en la org **[`exactamente-ar`](https://github.com/exactamente-ar)**. Necesitás
acceso de colaborador a los 5 **antes** de correr `./setup.sh`: el script clona todo de una, y si
alguno falla se corta a la mitad.

Escribile a [`@juanpe44`](https://github.com/juanpe44) — por GitHub, o por donde ya estén
hablando. Contale en qué querés meterte, así te da el acceso que corresponde.

Verificás que quedó bien antes de invertir tiempo en el setup:

```bash
git ls-remote git@github.com:exactamente-ar/exactamente-frontend-admin.git >/dev/null \
  && echo "acceso ok" || echo "todavía no"
```

El admin es el más restrictivo de los cinco — si ese anda, andan todos.

---

## Qué te habilita el acceso

| Podés | No podés |
|---|---|
| Clonar los 5 repos y correr el setup completo | Pushear directo a `main` / `master` |
| Crear ramas `<tu-usuario>/<lo-que-sea>` | Mergear a rama protegida (salvo el admin) |
| Abrir PRs en cualquier repo, con el CI corriendo | Bypassear un check en rojo |
| Mergear en `exactamente-frontend-admin` | Cambiar branch protection o secretos |

La restricción de merge no es desconfianza ni un permiso mal configurado: mergear a `main` del
backend **despliega a producción** vía Dokploy, sin paso manual en el medio. Por eso está
limitado a una persona y `enforce_admins` está en `true` — la protección aplica también a los
admins del repo, incluido quien la configuró.

Abrís el PR, avisás, y lo mergea `@juanpe44`. El CI corre igual para todos.

---

## Reglas de convivencia

- **Tu prefijo de rama es tu usuario de GitHub.** `juanpe44/algo` si sos juanpe44, tu usuario si
  no. El prefijo existe para que mirando la lista de ramas se sepa quién tiene qué en vuelo.
- **Los commits van a nombre de quien los escribe.** La autoría sale de tu `git config`; no pases
  `--author`. Cada uno firma lo suyo.
- **El backend se mergea primero.** Ningún cliente mergea contra un contrato que no está en
  `main` del backend.
- **Si tocás algo compartido, decilo.** Un cambio en un schema del backend le llega a los 3
  clientes. `codegraph explore "<símbolo>"` te dice a quiénes antes de que te lo diga el CI de
  otro repo.

---

## Por dónde empezar

1. [README.md](README.md) — qué es esto y cómo levantarlo
2. [CONTRIBUTING.md](CONTRIBUTING.md) — el ciclo de trabajo, en corto
3. [METODOLOGIA.md](METODOLOGIA.md) — el detalle, cuando lo necesites
4. La documentación del repo que vayas a tocar

Buen primer PR: agregate a la tabla de arriba. Segundo: algo chico y acotado en un solo repo,
para pasar por el ciclo completo (rama → TDD → gates → PR) sin que además sea difícil.
