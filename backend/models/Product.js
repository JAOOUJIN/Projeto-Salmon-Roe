const mongoose = require('mongoose');

const ProductSchema = new mongoose.Schema({
  ds_produto: {
    type: String,
    required: true,
    trim: true,
  },
  vl_produto: {
    type: Number,
    required: true,
    min: 0,
  },
}, { timestamps: true });

module.exports = mongoose.model('Product', ProductSchema);