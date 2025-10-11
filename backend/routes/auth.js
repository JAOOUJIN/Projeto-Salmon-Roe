// backend/routes/auth.js
const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const router = express.Router();
const JWT_SECRET = 'seu123';

// Rota de Registro
router.post('/register', async (req, res) => {
    const { email, password, phone } = req.body;
    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        const newUser = new User({ email, password: hashedPassword, phone });
        await newUser.save();
        res.status(201).json({ message: 'Usuário registrado com sucesso!' });
    } catch (error) {
        res.status(400).json({ error: 'Erro ao registrar usuário. O e-mail ou telefone já pode estar em uso.' });
    }
});

// Rota de Login
router.post('/login', async (req, res) => {
    const { loginId, password } = req.body;
    try {
        const user = await User.findOne({
            $or: [
                { email: loginId },
                { phone: loginId }
            ]
        });

        if (!user) {
            return res.status(400).json({ error: 'Credenciais inválidas.' });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ error: 'Credenciais inválidas' });
        }

        // Geração do token
        const token = jwt.sign({ id: user._id }, JWT_SECRET, { expiresIn: '1h' });
        res.json({
            success: true,
            data: {
                user: {
                    _id: user._id,
                    email: user.email,
                    phone: user.phone
                },
                token: token
            }
        });
    } catch (error) {
        res.status(500).json({ error: 'Erro no servidor' });
    }
});

module.exports = router;