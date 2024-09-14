const jwt = require('jsonwebtoken');

function verifyToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Token manquant ou mal formaté' });
    }

    const token = authHeader.split(' ')[1];

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;

       
        const currentTime = Math.floor(Date.now() / 1000);
        const timeLeft = decoded.exp - currentTime;

      
        res.setHeader('X-Token-Expiration-Time', timeLeft);

        next();
    } catch (err) {
        res.status(401).json({ error: 'Token invalide ou expiré' });
    }
}

module.exports = verifyToken;
