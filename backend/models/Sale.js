const mongoose = require('mongoose');

const SaleItemSchema = new mongoose.Schema({
  cd_produto: {
    type: Number,
    required: true,
  },
  qt_item: {
    type: Number,
    required: true,
    min: 1,
  },
});

const SaleSchema = new mongoose.Schema({
  cd_venda: {
    type: Number,
    required: true,
    unique: true,
  },
  vl_venda: {
    type: Number,
    required: true,
    min: 0,
  },
  dt_emissao: {
    type: Date,
    default: Date.now,
  },
  itens: [SaleItemSchema],  
}, { timestamps: true });

module.exports = mongoose.model('Sale', SaleSchema);