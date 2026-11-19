import express from 'express';
import pg from 'pg';

pg.types.setTypeParser(1082, v => v);      // date -> texto "YYYY-MM-DD"
pg.types.setTypeParser(1700, parseFloat);  // numeric -> número
const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL, ssl: { rejectUnauthorized: false } });
const q = async (s, p) => (await pool.query(s, p)).rows;
const r2 = n => Math.round((n + Number.EPSILON) * 100) / 100;

const app = express();
app.use(express.json({ limit: '3mb' }));
app.use(express.static('public'));

// Clave simple: la web la pide una vez; el bot la manda en el header x-api-key
app.use('/api', (req, res, next) => {
  const k = process.env.ACCESS_KEY;
  if (k && req.get('x-api-key') !== k) return res.status(401).json({ error: 'Clave incorrecta' });
  next();
});
const h = f => (req, res) => f(req, res).then(d => res.json(d)).catch(e => res.status(400).json({ error: e.message }));

// ---- Materiales ----
app.get('/api/materiales', h(() => q('SELECT * FROM materiales ORDER BY nombre')));
app.post('/api/materiales', h(async ({ body: b }) =>
  (await q('INSERT INTO materiales(nombre,unidad,precio) VALUES($1,$2,$3) RETURNING *', [b.nombre.trim(), b.unidad.trim(), b.precio]))[0]));
app.put('/api/materiales/:id', h(async ({ params, body: b }) =>
  (await q('UPDATE materiales SET nombre=$1,unidad=$2,precio=$3 WHERE id=$4 RETURNING *', [b.nombre.trim(), b.unidad.trim(), b.precio, params.id]))[0]));
app.delete('/api/materiales/:id', h(async ({ params }) => { await q('DELETE FROM materiales WHERE id=$1', [params.id]); return { ok: true }; }));

// ---- Datos de empresa ----
app.get('/api/config', h(async () => Object.fromEntries((await q('SELECT * FROM config')).map(r => [r.clave, r.valor]))));
app.put('/api/config', h(async ({ body }) => {
  for (const [k, v] of Object.entries(body))
    await q('INSERT INTO config(clave,valor) VALUES($1,$2) ON CONFLICT(clave) DO UPDATE SET valor=EXCLUDED.valor', [k, String(v ?? '')]);
  return { ok: true };
}));

// ---- Cotizaciones ----
app.get('/api/cotizaciones', h(() => q('SELECT id,fecha,cliente,descripcion,total FROM cotizaciones ORDER BY id DESC LIMIT 200')));
app.get('/api/cotizaciones/:id', h(async ({ params }) => {
  const [c] = await q('SELECT * FROM cotizaciones WHERE id=$1', [params.id]);
  if (!c) throw new Error('No existe esa cotización');
  return c;
}));
// Body: { cliente, telefono, direccion, descripcion, fecha?, utilidad_pct?,
//         lineas:[{material_id | material:"nombre", cantidad}], globales:[{nombre, monto}] }
app.post('/api/cotizaciones', h(async ({ body: b }) => {
  const items = [];
  for (const l of b.lineas || []) {
    const [m] = l.material_id
      ? await q('SELECT * FROM materiales WHERE id=$1', [l.material_id])
      : await q('SELECT * FROM materiales WHERE nombre ILIKE $1 ORDER BY length(nombre) LIMIT 1', ['%' + l.material + '%']);
    if (!m) throw new Error('Material no encontrado: ' + (l.material || l.material_id));
    items.push({ nombre: m.nombre, unidad: m.unidad, cantidad: l.cantidad, precio: m.precio, total: r2(l.cantidad * m.precio) });
  }
  for (const g of b.globales || []) items.push({ global: true, nombre: g.nombre, total: r2(g.monto) });
  if (!items.length) throw new Error('La cotización está vacía');
  const pct = b.utilidad_pct ?? 10;
  const subtotal = r2(items.reduce((a, i) => a + i.total, 0));
  const utilidad = r2(subtotal * pct / 100);
  const [c] = await q(
    `INSERT INTO cotizaciones(fecha,cliente,telefono,direccion,descripcion,utilidad_pct,subtotal,utilidad,total,items)
     VALUES(COALESCE($1::date,CURRENT_DATE),$2,$3,$4,$5,$6,$7,$8,$9,$10) RETURNING *`,
    [b.fecha || null, b.cliente || '', b.telefono || '', b.direccion || '', b.descripcion || '', pct, subtotal, utilidad, r2(subtotal + utilidad), JSON.stringify(items)]);
  return c;
}));

app.listen(process.env.PORT || 3000, () => console.log('Cotizador listo'));
