const express = require('express');
const mabase = require('./config/database'); 
require('dotenv').config();
const verifyToken = require('./authMiddleware');

const app = express();
const router = require('./routes/router'); 

app.use(express.json()); 
app.use(router);

//app.use('/api', authRoutes);

const PORT = 3007;
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`); 
});
