require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { initDB } = require('./config/database');
const logisticsRoutes = require('./routes/logisticsRoutes');

const app = express();
const PORT = process.env.PORT || 5002;

app.use(cors());
app.use(express.json());

app.get('/api/health', (req, res) => {
  res.json({ success: true, service: 'logistics-service', status: 'running', timestamp: new Date() });
});

app.use('/api', logisticsRoutes);

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ success: false, message: 'Internal server error' });
});

initDB().then(() => {
  app.listen(PORT, () => {
    console.log(`🚀 Logistics Service running on port ${PORT}`);
  });
});
