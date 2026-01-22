// backend/routes/userRoutes.js
const express = require('express');
const {
  updateInfo,
  updateAccess,
} = require('../controllers/userController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

router.use(protect); 

router.put('/update-info', updateInfo);  
router.put('/update-access', updateAccess);  
module.exports = router;
