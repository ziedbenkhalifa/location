const express = require('express');
const router = express.Router();
const UserController = require("../controllers/UserController");
const locationController = require('../controllers/LocationController'); 
const ClientController = require("../controllers/ClientController");
const VoitureController = require("../controllers/voiturecontroller");

router.get("/", (req, res) => {
    res.send("Running on port 3007");
});

router.get("/zied", (req, res) => {
    res.send("route zied");
});
router.post('/like', ClientController.likeCar);

router.post('/clients', ClientController.createClient);
router.get('/client/:clientId/locations', ClientController.getClientLocations);
router.get('/client/:clientId/liked-cars', ClientController.getClientLikedCars);
router.get('/car-availability/:voiture_matricule', locationController.getCarAvailability);

router.post('/login', ClientController.loginController);
router.post('/locations', locationController.createLocation);
router.get('/locations', locationController.getAllLocations);

router.get("/alladmins", UserController.getallusers);
router.post('/ajadmin', UserController.addadmin);
router.put('/admin/:id', UserController.updateadmin);

router.get("/clientss", ClientController.getAllClients);
router.get('/voitures', VoitureController.getAllVoitures);
router.get('/voituresdispo', VoitureController.getAvailableVoitures);
router.get('/voituresindispo', VoitureController.getNotAvailableVoitures);
router.post('/ajvoitures', VoitureController.addVoiture);
router.put('/voitures/:matricule', VoitureController.updateVoiture);
router.delete('/voitures/:matricule', VoitureController.deleteVoiture);
router.get('/liked-cars/:clientId', ClientController.getClientLikedCars);
router.get('/search', VoitureController.getVoituresByBrandAndPrice);
router.get('/locations/client/:clientId', locationController.getLocationsByClient);
router.get('/client/:id', ClientController.getClientById);

router.put('/clients/:id', ClientController.updateClient);

router.delete('/clients/:id', ClientController.deleteClient);




router.post('/locations', locationController.createLocation);


router.put('/locations/:id', locationController.updateLocation);

router.delete('/locations/:id', locationController.deleteLocation);



router.get('/voiture/:id', VoitureController.getVoitureById);

module.exports = router;
