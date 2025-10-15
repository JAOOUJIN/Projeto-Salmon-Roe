// backend/routes/auth.js
const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const router = express.Router();
const JWT_SECRET = 'seu123';

// Atualizar informações pessoais
router.put('/update-info/:id', async (req, res) => {
  const { name, cpf } = req.body;

  try {
    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({ error: 'Usuário não encontrado.' });
    }

    // Atualiza nome livremente
    if (name) {
      user.name = name;
    }

    // CPF só pode ser definido se ainda não existir
    if (cpf) {
      if (user.cpf && user.cpf.trim() !== '') {
        return res.status(400).json({ error: 'O CPF já foi cadastrado e não pode ser alterado.' });
      }
      user.cpf = cpf;
    }

    await user.save();
    res.json({
      message: 'Informações atualizadas com sucesso!',
      user: {
        id: user._id,
        email: user.email,
        phone: user.phone,
        name: user.name,
        cpf: user.cpf,
      },
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erro ao atualizar informações do usuário.' });
  }
});

// Atualizar telefone / senha (verifica senha antiga antes de trocar senha)
router.put('/update-access/:id', async (req, res) => {
  const { phone, currentPassword, newPassword } = req.body;

  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ error: 'Usuário não encontrado.' });

    // Atualiza telefone (pode sempre atualizar)
    if (phone) user.phone = phone;

    if (newPassword) {
      if (!currentPassword) {
        return res.status(400).json({ error: 'Senha atual é obrigatória para alterar a senha.' });
      }

      const isMatch = await bcrypt.compare(currentPassword, user.password);
      if (!isMatch) {
        return res.status(400).json({ error: 'Senha atual incorreta.' });
      }

      const hashed = await bcrypt.hash(newPassword, 10);
      user.password = hashed;
    }

    await user.save();

    res.json({
      success: true,
      data: {
        user: {
          _id: user._id,
          email: user.email,
          phone: user.phone,
          name: user.name || null,
          cpf: user.cpf || null
        }
      },
      message: 'Informações de acesso atualizadas com sucesso.'
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erro ao atualizar informações.' });
  }
});

// Rota de Registro
router.post('/register', async (req, res) => {
  const { email, password, phone, name, cpf } = req.body;
  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = new User({ email, password: hashedPassword, phone, name: name || null, cpf: cpf || null });
    await newUser.save();
    res.status(201).json({ message: 'Usuário registrado com sucesso!' });
  } catch (error) {
    res.status(400).json({ error: 'Erro ao registrar usuário. O e-mail ou telefone já pode estar em uso.' });
  }
});

// Rota de Login
router.post('/login', async (req, res) => {
  const { loginId, password } = req.body;
  try {
    const user = await User.findOne({
      $or: [
        { email: loginId },
        { phone: loginId }
      ]
    });

    if (!user) {
      return res.status(400).json({ error: 'Credenciais inválidas.' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ error: 'Credenciais inválidas' });
    }

    // Geração do token
    const token = jwt.sign({ id: user._id }, JWT_SECRET, { expiresIn: '1h' });
    res.json({
      success: true,
      data: {
        user: {
          _id: user._id,
          email: user.email,
          phone: user.phone,
          name: user.name || null,
          cpf: user.cpf || null
        },
        token: token
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Erro no servidor' });
  }
});

module.exports = router;