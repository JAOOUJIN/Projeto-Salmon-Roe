const Product = require('../models/Product');

// Listar todos os produtos
exports.getProducts = async (req, res) => {
  try {
    const products = await Product.find();
    res.json(products);
  } catch (error) {
    res.status(500).json({ error: 'Erro ao listar produtos.' });
  }
};

// Adicionar produto (protegido, para admins)
exports.addProduct = async (req, res) => {
  const { ds_produto, vl_produto } = req.body;
  try {
    const newProduct = new Product({ ds_produto, vl_produto });
    await newProduct.save();
    res.status(201).json({ message: 'Produto adicionado!', product: newProduct });
  } catch (error) {
    res.status(400).json({ error: 'Erro ao adicionar produto.' });
  }
};

// Atualizar produto
exports.updateProduct = async (req, res) => {
  const { id } = req.params;
  const { ds_produto, vl_produto } = req.body;
  try {
    const product = await Product.findByIdAndUpdate(id, { ds_produto, vl_produto }, { new: true });
    if (!product) return res.status(404).json({ error: 'Produto não encontrado.' });
    res.json({ message: 'Produto atualizado!', product });
  } catch (error) {
    res.status(500).json({ error: 'Erro ao atualizar produto.' });
  }
};

// Deletar produto
exports.deleteProduct = async (req, res) => {
  const { id } = req.params;
  try {
    await Product.findByIdAndDelete(id);
    res.json({ message: 'Produto deletado!' });
  } catch (error) {
    res.status(500).json({ error: 'Erro ao deletar produto.' });
  }
};