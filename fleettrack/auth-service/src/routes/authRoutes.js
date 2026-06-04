const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/authController');
const { authMiddleware, adminMiddleware } = require('../middleware/auth');

router.post('/auth/register', ctrl.register);
router.post('/auth/login', ctrl.login);
router.get('/auth/me', authMiddleware, ctrl.me);
router.post('/auth/logout', authMiddleware, ctrl.logout);

router.get('/users', authMiddleware, adminMiddleware, ctrl.getUsers);
router.put('/users/:id', authMiddleware, adminMiddleware, ctrl.updateUser);
router.delete('/users/:id', authMiddleware, adminMiddleware, ctrl.deleteUser);

module.exports = router;
