const express = require('express');
const {
  getAddresses,
  addAddress,
  updateAddress,
  deleteAddress,
  setDefaultAddress,
} = require('../controllers/addressController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

router.use(protect);
router.get('/', getAddresses);
router.post('/', addAddress);
router.put('/:addressId', updateAddress);
router.delete('/:addressId', deleteAddress);
router.put('/set-default/:addressId', setDefaultAddress);
module.exports = router;