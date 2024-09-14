const express = require('express');
const router = express.Router();
const verifyToken = require('./authMiddleware');

router.get('/protected', verifyToken, (req, res) => {
    const userRole = req.user.role;
    const userId = req.user.id;

    if (userRole === 'admin') {
        res.json({ message: 'Bienvenue Admin', role: 'admin', userId: userId });
    } else if (userRole === 'client') {
        res.json({ message: 'Bienvenue Client', role: 'client', userId: userId });
    } else {
        res.status(403).json({ error: 'Rôle inconnu' });
    }
});

module.exports = router;
