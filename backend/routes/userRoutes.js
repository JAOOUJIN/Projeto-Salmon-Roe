// backend/routes/userRoutes.js
const express = require('express');
const {
  updateInfo,
  updateAccess,
  addAddress,
  updateAddress,
  deleteAddress,
  getAddresses,
} = require('../controllers/userController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

router.use(protect); 

router.put('/update-info', updateInfo);  
router.put('/update-access', updateAccess);  
router.get('/', getAddresses);
router.post('/address', addAddress);  
router.put('/address/:addressId', updateAddress);
router.delete('/address/:addressId', deleteAddress);
module.exports = router;
