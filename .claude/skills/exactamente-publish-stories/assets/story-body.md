## Historia

Como {{user_type}}, quiero {{capability}}, para {{value_benefit}}.

## Criterios de aceptación

- [ ] **Dado** {{precondition}} **cuando** {{action}} **entonces** {{expected_outcome}}
<!-- one checkbox per AC -->

## Alcance

- **Repo:** `{{repo}}`
- **Depende de:** {{dependencies_or_"nada"}}
- **Cambia el contrato de la API:** {{yes_no}}

## Notas técnicas

{{technical_notes_or_remove_section}}

## Definición de hecho

- [ ] Tests escritos primero y vistos fallar (TDD)
- [ ] Si cambia el contrato: `bun run gen:openapi` en el backend y `pnpm gen:api` en cada cliente
- [ ] CI en verde
- [ ] PR con `Closes #{{this_issue}}`

## Contexto

Story {{N.M}} de la épica {{epic_ref}} — detalle en
[`{{epics_path}}`](https://github.com/exactamente-ar/exactamente-workspace/blob/main/{{epics_path}}).

Para tomarla: `/exactamente-take-issue exactamente-ar/{{repo}}#{{this_issue}}` desde la raíz del workspace.
