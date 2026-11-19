# Cotizador

Catálogo de materiales con costos → eliges solo cantidades → cotización con tu formato → PDF. Funciona en PC y celular.
Stack gratuito: **Neon** (PostgreSQL) + **Render** (Node/Express + web) + GitHub.

## Puesta en marcha
1. **Neon**: crea un proyecto, abre el *SQL Editor*, pega y ejecuta `schema.sql`. Copia la *connection string*.
2. **GitHub**: sube esta carpeta a un repositorio.
3. **Render**: *New → Web Service* con tu repo. Build: `npm install`. Start: `npm start`.
   Variables de entorno: `DATABASE_URL` (la de Neon) y `ACCESS_KEY` (una clave tuya).
4. Abre la URL de Render, escribe la clave una vez y listo. En **Empresa** sube tu logo y revisa tus datos.

Local: `cp .env.example .env`, exporta las variables y `npm install && npm start` → http://localhost:3000

> En el plan gratis de Render el servicio se duerme tras un rato sin uso; la primera visita tarda unos segundos.

## API (para conectar un bot de Telegram/IA)
Todas las rutas llevan el header `x-api-key: <ACCESS_KEY>`.

| Ruta | Qué hace |
|---|---|
| `GET /api/materiales` | Lista el catálogo |
| `POST /api/materiales` | `{nombre, unidad, precio}` |
| `POST /api/cotizaciones` | Crea una cotización y devuelve el total |
| `GET /api/cotizaciones/:id` | Lee una cotización |

Ejemplo de cotización (el material se puede dar por nombre; el servidor lo busca):
```json
{ "cliente": "LLAVE EN MANO INMOBILIARIA", "descripcion": "REFUERZO METÁLICA DE PUERTA",
  "utilidad_pct": 10,
  "lineas": [{"material": "TUBO 1 1/4", "cantidad": 8}, {"material": "MANO DE OBRA", "cantidad": 3}],
  "globales": [{"nombre": "TAXI", "monto": 200}, {"nombre": "INSTALACION", "monto": 250}] }
```
