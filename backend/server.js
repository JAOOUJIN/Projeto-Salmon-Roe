require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const addressRoutes = require('./routes/addressRoutes');
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const productRoutes = require('./routes/productRoutes');
const saleRoutes = require('./routes/saleRoutes');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 5000;

//const MONGODB_URI = 'mongodb+srv://db_admin:admin123@salmon-roe-cluster.xmbnlaz.mongodb.net/salmon-roe?retryWrites=true&w=majority&appName=Salmon-roe-cluster';
const MONGODB_URI = process.env.MONGODB_URI;
mongoose.connect(MONGODB_URI)
  .then(() => console.log('Conectado ao MongoDB!'))
  .catch(err => console.error('Erro de conexão ao MongoDB:', err));

// cabeçalho, métodos e origens permitidos
app.use(cors({
  origin: '*', 
  methods: ['GET', 'POST', 'PUT', 'DELETE'], 
  allowedHeaders: ['Content-Type', 'Authorization'], 
}));
app.use(express.json());

// Rotas
app.use('/api/address', addressRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);
app.use('/api/products', productRoutes);
app.use('/api/sale', saleRoutes);

app.get('/', (req, res) => {
  res.send('Servidor do Salmon Roe está rodando!');
});

app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});