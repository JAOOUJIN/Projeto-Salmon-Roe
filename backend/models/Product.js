const mongoose = require('mongoose');

const ProductSchema = new mongoose.Schema({
  name_produto: {
    type: String,
    required: true,
    trim: true,
  },
  ds_produto: {
    type: String,
    required: true,
    trim: true,
  },
  image_url: {
    type: String,
    required: true,
    trim: true,
  },
  vl_produto: {
    type: Number,
    required: true,
    min: 0,
  },
  vl_antigo: {
    type: Number,
    default: 0,
  },
  is_destaque: {
    type: Boolean,
    default: false,
  },
  is_novo: {
    type: Boolean,
    default: false,
  },
}, { timestamps: true });

module.exports = mongoose.model('Product', ProductSchema);