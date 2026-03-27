const express = require('express');
const { createSale, getSales, getMyOrders, getLastOrderStatus, getSaleById } = require('../controllers/saleController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

// Rotas protegidas
router.use(protect);
router.post('/', createSale);
router.get('/', getSales);
router.get('/my-orders', getMyOrders); 
router.get('/last-order-status', getLastOrderStatus); 
router.get('/:id', getSaleById); 


module.exports = router;