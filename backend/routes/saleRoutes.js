const express = require('express');
const { createSale, getSales } = require('../controllers/saleController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

// Rotas protegidas
router.use(protect);
router.post('/', createSale);
router.get('/', getSales);  

module.exports = router;