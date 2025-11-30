const mongoose = require('mongoose');

const SaleItemSchema = new mongoose.Schema({
  cd_produto: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
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
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'], 
    default: 'pending', 
    required: true,
  },
  itens: [SaleItemSchema],
}, { timestamps: true });

module.exports = mongoose.model('Sale', SaleSchema);