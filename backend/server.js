const express = require('express');
const mongoose = require('mongoose');
const authRoutes = require('./routes/authRoutes'); 
const userRoutes = require('./routes/userRoutes');
const productRoutes = require('./routes/productRoutes');
const saleRoutes = require('./routes/saleRoutes');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 5000;

const MONGODB_URI = 'mongodb+srv://casierrajin_db_user:jin123@cluster0.hocefhi.mongodb.net/'; 
mongoose.connect(MONGODB_URI)
  .then(() => console.log('Conectado ao MongoDB!'))
  .catch(err => console.error('Erro de conexão ao MongoDB:', err));

app.use(cors());
app.use(express.json());

// Rotas
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