const express = require('express');
const mongoose = require('mongoose');
const authRoutes = require('./routes/auth'); 

const app = express();
const PORT = process.env.PORT || 5000;

const MONGODB_URI = 'mongodb+srv://casierrajin_db_user:jin123@cluster0.hocefhi.mongodb.net/'; 
mongoose.connect(MONGODB_URI)
  .then(() => console.log('Conectado ao MongoDB!'))
  .catch(err => console.error('Erro de conexão ao MongoDB:', err));

app.use(express.json());

// Usa as rotas de autenticação
app.use('/api/auth', authRoutes);

app.get('/', (req, res) => {
  res.send('Servidor do Salmon Roe está rodando!');
});

app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});