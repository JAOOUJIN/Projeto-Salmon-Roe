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
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
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
    enum: ['pending', 'confirmed', 'shipped', 'on_the_way', 'delivered', 'cancelled'],
    default: 'pending',
    required: true,
  },
  itens: [SaleItemSchema],
}, {
  timestamps: {
    currentTime: () => new Date(Date.now() - 3 * 60 * 60 * 1000)
  }
});

module.exports = mongoose.model('Sale', SaleSchema);