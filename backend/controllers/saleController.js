const Sale = require('../models/Sale');
const Product = require('../models/Product');

// Criar venda 
exports.createSale = async (req, res) => {
  const { cd_venda, itens } = req.body;
  try {
    const products = await Promise.all(
      itens.map(item => Product.findById(item.cd_produto))
    );

    let vl_venda = 0;
    products.forEach((product, i) => {
      if (!product) throw new Error(`Produto ${itens[i].cd_produto} não encontrado.`);
      vl_venda += product.vl_produto * itens[i].qt_item;
    });

    const newSale = new Sale({ cd_venda, vl_venda, itens });
    await newSale.save();
    res.status(201).json({ message: 'Venda criada!', sale: newSale });
  } catch (error) {
    res.status(400).json({ error: error.message || 'Erro ao criar venda.' });
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

// Buscar venda por ID
exports.getSaleById = async (req, res) => {
  try {
    const sale = await Sale.findById(req.params.id).populate('itens.cd_produto');
    if (!sale) return res.status(404).json({ error: 'Venda não encontrada.' });
    res.json(sale);
  } catch (error) {
    res.status(500).json({ error: 'Erro ao buscar venda.' });
  }
};
