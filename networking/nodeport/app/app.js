const express = require('express');
const mysql = require('mysql2/promise');
const bodyParser = require('body-parser');
const session = require('express-session');

const app = express();
app.use(bodyParser.json());
app.use(express.urlencoded({ extended: true })); // para forms
app.use(session({
  secret: 'segredo',
  resave: false,
  saveUninitialized: true
}));

// Configura conexão MySQL (variáveis de ambiente)
const dbConfig = {
  host: process.env.DB_HOST || 'mysql',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASS || 'root',
  database: process.env.DB_NAME || 'noticiasdb'
};

// Middleware login
function autenticar(req, res, next) {
  if (req.session.usuario) next();
  else res.status(401).json({ erro: 'Não autenticado' });
}

// Rota de login
app.post('/login', async (req, res) => {
  const { usuario, senha } = req.body; // req.body precisa estar preenchido
  if (usuario === 'admin' && senha === 'admin') {
    req.session.usuario = usuario;
    res.redirect('/noticias');
  } else {
    res.status(401).json({ erro: 'Credenciais inválidas' });
  }
});


// Rota para cadastrar notícia
app.post('/noticias', autenticar, async (req, res) => {
  const { titulo, conteudo, autor } = req.body;
  try {
    const conn = await mysql.createConnection(dbConfig);
    await conn.execute('INSERT INTO noticias (titulo, conteudo, autor) VALUES (?,?,?)',
      [titulo, conteudo, autor]);
    await conn.end();
    res.json({ msg: 'Notícia cadastrada' });
  } catch (err) {
    res.status(500).json({ erro: err.message });
  }
});

// Rota para listar notícias
app.get('/noticias', async (req, res) => {
  try {
    const conn = await mysql.createConnection(dbConfig);
    const [rows] = await conn.execute('SELECT * FROM noticias ORDER BY id DESC');
    await conn.end();
    res.json(rows);
  } catch (err) {
    res.status(500).json({ erro: err.message });
  }
});


// página login
app.get('/', (req, res) => {
  res.render('login', { titulo: 'Login' });
});

 

// página notícias
app.get('/noticias', autenticar, async (req, res) => {
  const conn = await mysql.createConnection(dbConfig);
  const [rows] = await conn.execute('SELECT * FROM noticias ORDER BY id DESC');
  await conn.end();
  res.render('noticias', { titulo: 'Notícias', noticias: rows });
});

// post notícias (HTML form)
app.post('/noticias', autenticar, async (req, res) => {
  const { titulo, conteudo, autor } = req.body;
  const conn = await mysql.createConnection(dbConfig);
  await conn.execute(
    'INSERT INTO noticias (titulo, conteudo, autor) VALUES (?,?,?)',
    [titulo, conteudo, autor]
  );
  await conn.end();
  res.redirect('/noticias');
});



async function initDB() {
  const conn = await mysql.createConnection({
    host: process.env.DB_HOST || 'mysql',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASS || 'root'
  });

  // Criar banco se não existir
  await conn.query('CREATE DATABASE IF NOT EXISTS noticiasdb');
  await conn.query('USE noticiasdb');

  // Criar tabela se não existir
  await conn.query(`
    CREATE TABLE IF NOT EXISTS noticias (
      id INT AUTO_INCREMENT PRIMARY KEY,
      titulo VARCHAR(255) NOT NULL,
      conteudo TEXT NOT NULL,
      autor VARCHAR(100),
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // Inserir uma notícia inicial se tabela estiver vazia
  const [rows] = await conn.query('SELECT COUNT(*) as count FROM noticias');
  if (rows[0].count === 0) {
    await conn.query(`
      INSERT INTO noticias (titulo, conteudo, autor)
      VALUES ('Notícia de Boas-Vindas', 'Esta é a primeira notícia do portal.', 'Admin')
    `);
  }

  await conn.end();
}

// Inicializa DB e depois sobe o app
initDB().then(() => {
  app.listen(3500, () => console.log('App rodando na porta 3000'));
}).catch(err => console.error('Erro inicializando DB:', err));


app.set('view engine', 'ejs');
app.set('views', __dirname + '/views');

const expressLayouts = require('express-ejs-layouts');
app.use(expressLayouts);
app.set('layout', 'layout'); // arquivo views/layout.ejs

