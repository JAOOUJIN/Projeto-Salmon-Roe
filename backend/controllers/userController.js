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
    res.json({
      message: 'Informações atualizadas com sucesso!',
      user: user,
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
    res.json({ message: 'Informações atualizadas com sucesso.', user });
  } catch (error) {
    res.status(500).json({ error: 'Erro ao atualizar acesso.' });
  }
};

// Listar endereços do usuário logado
exports.getAddresses = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (!user) return res.status(404).json({ error: 'Usuário não encontrado.' });
    res.json({ addresses: user.addresses });
  } catch (error) {
    res.status(500).json({ error: 'Erro ao listar endereços.' });
  }
};


// Adicionar endereço
exports.addAddress = async (req, res) => {
  const { street, number, city, state, zip, neighborhood, complement } = req.body;

  try {
    const user = await User.findById(req.user._id);
    if (!user) return res.status(404).json({ error: 'Usuário não encontrado.' });

    const newAddress = { street, number, city, state, zip, neighborhood, complement };
    user.addresses.push(newAddress);

    await user.save();
    res.json({ message: 'Endereço adicionado com sucesso!', addresses: user.addresses });
  } catch (error) {
    res.status(500).json({ error: 'Erro ao adicionar endereço.' });
  }
};

// Atualizar endereço
exports.updateAddress = async (req, res) => {
  const { addressId } = req.params;
  const { street, number, city, state, zip, neighborhood, complement } = req.body;
  try {
    const user = await User.findOne({ 'addresses._id': addressId });
    if (!user) return res.status(404).json({ error: 'Endereço não encontrado.' });

    if (user._id.toString() !== req.user._id.toString()) {
      return res.status(403).json({ error: 'Acesso negado. Você não pode alterar este endereço.' });
    }
    const address = user.addresses.id(addressId);
    if (street) address.street = street;
    if (number) address.number = number;
    if (city) address.city = city;
    if (state) address.state = state;
    if (zip) address.zip = zip;
    if (neighborhood) address.neighborhood = neighborhood;
    if (complement) address.complement = complement;
    await user.save();
    res.json({ message: 'Endereço atualizado com sucesso!', addresses: user.addresses });
  } catch (error) {
    res.status(500).json({ error: 'Erro ao atualizar endereço.' });
  }
};

// Deletar endereço
exports.deleteAddress = async (req, res) => {
  const { addressId } = req.params;
  try {
    const user = await User.findOne({ 'addresses._id': addressId });
    if (!user) return res.status(404).json({ error: 'Endereço não encontrado.' });

    if (user._id.toString() !== req.user._id.toString()) {
      return res.status(403).json({ error: 'Acesso negado. Você não pode excluir este endereço.' });
    }
    user.addresses = user.addresses.filter(a => a._id.toString() !== addressId);
    await user.save();
    res.json({ message: 'Endereço excluído com sucesso.', addresses: user.addresses });
  } catch (error) {
    res.status(500).json({ error: 'Erro ao excluir endereço.' });
  }
};
