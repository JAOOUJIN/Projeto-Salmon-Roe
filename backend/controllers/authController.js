// backend/controllers/authController.js
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const JWT_SECRET = 'seu123';

// Registrar usuário
exports.register = async (req, res) => {
  const { email, password, phone, name, cpf } = req.body;
  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = new User({ 
      email, 
      password: hashedPassword, 
      phone, 
      name: name || null, 
      cpf: cpf || null 
    });
    await newUser.save();
    res.status(201).json({ message: 'Usuário registrado com sucesso!' });
  } catch (error) {
    res.status(400).json({ error: 'Erro ao registrar usuário. O e-mail ou telefone já pode estar em uso.' });
  }
};

// Login do usuário
exports.login = async (req, res) => {
  const { loginId, password } = req.body;
  try {
    const user = await User.findOne({
      $or: [{ email: loginId }, { phone: loginId }]
    });

    if (!user) {
      return res.status(400).json({ error: 'Credenciais inválidas.' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ error: 'Credenciais inválidas.' });
    }

    const token = jwt.sign({ id: user._id }, JWT_SECRET, { expiresIn: '1h' });
    res.json({
      success: true,
      data: {
        user: {
          _id: user._id,
          email: user.email,
          phone: user.phone,
          name: user.name || null,
          cpf: user.cpf || null,
          addresses: user.addresses || [],
        },
        token,
      },
    });
  } catch (error) {
    res.status(500).json({ error: 'Erro no servidor.' });
  }
};
