const express = require('express');
const router = express.Router();
const lc = require('../controllers/logisticsController');
const sc = require('../controllers/shipmentController');
const { authMiddleware } = require('../middleware/auth');

// Public tracking
router.get('/shipments/track/:tracking_number', sc.trackByNumber);

// Protected routes
router.use(authMiddleware);

router.get('/dashboard/stats', sc.getDashboardStats);

router.get('/vehicles', lc.getVehicles);
router.get('/vehicles/:id', lc.getVehicle);
router.post('/vehicles', lc.createVehicle);
router.put('/vehicles/:id', lc.updateVehicle);
router.delete('/vehicles/:id', lc.deleteVehicle);

router.get('/drivers', lc.getDrivers);
router.get('/drivers/:id', lc.getDriver);
router.post('/drivers', lc.createDriver);
router.put('/drivers/:id', lc.updateDriver);
router.delete('/drivers/:id', lc.deleteDriver);

router.get('/warehouses', lc.getWarehouses);
router.post('/warehouses', lc.createWarehouse);
router.put('/warehouses/:id', lc.updateWarehouse);
router.delete('/warehouses/:id', lc.deleteWarehouse);

router.get('/routes', lc.getRoutes);
router.post('/routes', lc.createRoute);

router.get('/shipments', sc.getShipments);
router.get('/shipments/:id', sc.getShipment);
router.post('/shipments', sc.createShipment);
router.put('/shipments/:id/status', sc.updateStatus);

module.exports = router;
