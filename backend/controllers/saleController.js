const Sale = require('../models/Sale');
const Product = require('../models/Product');

// Criar venda (calcula valor total automaticamente)
exports.createSale = async (req, res) => {
  const { cd_venda, itens } = req.body;  // itens: [{ cd_produto, qt_item }]
  try {
    let vl_venda = 0;
    for (const item of itens) {
      const product = await Product.findOne({ _id: item.cd_produto });  // Assumindo cd_produto como _id do produto
      if (!product) return res.status(404).json({ error: `Produto ${item.cd_produto} não encontrado.` });
      vl_venda += product.vl_produto * item.qt_item;
    }

    const newSale = new Sale({ cd_venda, vl_venda, itens });
    await newSale.save();
    res.status(201).json({ message: 'Venda criada!', sale: newSale });
  } catch (error) {
    res.status(400).json({ error: 'Erro ao criar venda.' });
  }
};

// Listar vendas (para dashboard)
exports.getSales = async (req, res) => {
  try {
    const sales = await Sale.find().populate('itens.cd_produto');  
    res.json(sales);
  } catch (error) {
    res.status(500).json({ error: 'Erro ao listar vendas.' });
  }
};