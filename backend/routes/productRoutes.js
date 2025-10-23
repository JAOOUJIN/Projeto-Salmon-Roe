const express = require('express');
const { getProducts, addProduct, updateProduct, deleteProduct } = require('../controllers/productController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

// Rotas públicas
router.get('/', getProducts);

// Rotas protegidas ADMIN
router.use(protect);
router.post('/add', addProduct);
router.put('/:id', updateProduct);
router.delete('/:id', deleteProduct);

module.exports = router;