// backend/controllers/userController.js
const bcrypt = require('bcryptjs');
const User = require('../models/User');

// Atualizar nome e CPF
exports.updateInfo = async (req, res) => {
  const { name, cpf } = req.body;

  try {
    const user = await User.findById(req.user._id);
    if (!user) return res.status(404).json({ error: 'Usuário não encontrado.' });

    if (name) user.name = name;

    if (cpf) {
      if (user.cpf && user.cpf.trim() !== '') {
        return res.status(400).json({ error: 'O CPF já foi cadastrado e não pode ser alterado.' });
      }
      user.cpf = cpf;
    }

    await user.save();

    // Retorna apenas os campos necessários
    const userResponse = {
      _id: user._id,
      name: user.name,
      phone: user.phone,
      email: user.email,
      cpf: user.cpf,
    };

    res.json({
      message: 'Informações atualizadas com sucesso!',
      user: userResponse,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erro ao atualizar informações.' });
  }
};

// Atualizar telefone ou senha
exports.updateAccess = async (req, res) => {
  const { phone, currentPassword, newPassword } = req.body;

  try {
    const user = await User.findById(req.user._id);
    if (!user) return res.status(404).json({ error: 'Usuário não encontrado.' });

    if (phone) user.phone = phone;

    if (newPassword) {
      if (!currentPassword) {
        return res.status(400).json({ error: 'Senha atual é obrigatória.' });
      }

      const isMatch = await bcrypt.compare(currentPassword, user.password);
      if (!isMatch) {
        return res.status(400).json({ error: 'Senha atual incorreta.' });
      }

      const hashed = await bcrypt.hash(newPassword, 10);
      user.password = hashed;
    }

    await user.save();

    // Retorna apenas os campos necessários
    const userResponse = {
      _id: user._id,
      name: user.name,
      phone: user.phone,
      email: user.email,
    };

    res.json({ message: 'Informações atualizadas com sucesso.', user: userResponse });
  } catch (error) {
    res.status(500).json({ error: 'Erro ao atualizar acesso.' });
  }
};
