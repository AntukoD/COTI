CREATE TABLE IF NOT EXISTS materiales (
  id serial PRIMARY KEY,
  nombre text UNIQUE NOT NULL,
  unidad text NOT NULL DEFAULT 'UND',
  precio numeric(12,4) NOT NULL DEFAULT 0
);
CREATE TABLE IF NOT EXISTS cotizaciones (
  id serial PRIMARY KEY,
  fecha date NOT NULL DEFAULT CURRENT_DATE,
  cliente text, telefono text, direccion text, descripcion text,
  utilidad_pct numeric(6,2) NOT NULL DEFAULT 10,
  subtotal numeric(12,2), utilidad numeric(12,2), total numeric(12,2),
  items jsonb NOT NULL,
  creado timestamptz DEFAULT now()
);
CREATE TABLE IF NOT EXISTS config (clave text PRIMARY KEY, valor text);

-- Datos de ejemplo tomados de tu cotización (edítalos en la web)
INSERT INTO materiales(nombre,unidad,precio) VALUES
 ('TUBO 1 1/4 X 2 MM','UND',60),('TUBO L 1 1/2 X 2MM','UND',50),
 ('CHAPA CANTOL 1000','UND',150),('GALON X6','GALON',180),('TRAPO','KG',5),
 ('SOLDADURA','KG',18),('GLOSS SEGÚN MUESTRA','GALON',76),('THINNER','GALON',20),
 ('BISAGRAS','UND',6.6667),('MANO DE OBRA','DIAS',250)
ON CONFLICT DO NOTHING;
INSERT INTO config(clave,valor) VALUES
 ('empresa','MAX RODRISH S.A.C.'),('ruc','20615071707'),
 ('direccion','ASC. POBLADORES FLORES DEL CER MZA. C LOTE. 9 CALLE SAN IGNACIO URB. NIEVERIA'),
 ('telefono','940 844 158'),('correo','max.rodrish.14@gmail.com'),
 ('gerente','RODRIGO JESUS FLORES CUEVA'),
 ('validez','COTIZACIÓN VÁLIDA POR 7 DIAS A PARTIR DE FECHA DE EMISION'),
 ('nota','NO INCLUYE IGV'),('utilidad','10')
ON CONFLICT DO NOTHING;
