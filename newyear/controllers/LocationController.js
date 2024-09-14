const LocationModel = require('../models/LocationModel');
const VoitureModel = require('../models/VoitureModel');
const moment = require('moment');

class LocationController {
    

    async createLocation(req, res) {
        const { voiture_matricule, date_debut, date_fin, client_id } = req.body;
    
        try {
            
            const dateDebutUtc = moment(date_debut).utc().format('YYYY-MM-DD');
            const dateFinUtc = moment(date_fin).utc().format('YYYY-MM-DD');
    
            const isAvailable = await VoitureModel.checkAvailability(voiture_matricule, dateDebutUtc, dateFinUtc);
    
            if (!isAvailable) {
                return res.status(400).send({ error: 'Voiture non disponible pour les dates spécifiées.' });
            }
    
            const voiture = await VoitureModel.getVoitureByMatricule(voiture_matricule);
            if (!voiture) {
                return res.status(404).send({ error: 'Voiture non trouvée.' });
            }
    
            const prix_par_jour = voiture.prix_par_jour;
    
            const locationId = await LocationModel.createLocation(voiture_matricule, dateDebutUtc, dateFinUtc, client_id, prix_par_jour);
            res.status(200).send({ message: 'Location créée avec succès.', locationId });
        } catch (error) {
            console.error("Erreur lors de la création de la location:", error);
            res.status(500).send({ error: 'Erreur lors de la création de la location.' });
        }
    }
    

    async getAllLocations(req, res) {
        try {
            const locations = await LocationModel.getAllLocations();
            res.status(200).send(locations);
        } catch (error) {
            console.error("Erreur lors de la récupération des locations:", error);
            res.status(500).send({ error: 'Erreur lors de la récupération des locations.' });
        }
    }

    async getCarAvailability(req, res) {
        const { voiture_matricule } = req.params;

        try {
            const availability = await LocationModel.getCarAvailability(voiture_matricule);
            if (availability.length > 0) {
                res.status(200).send({ available: false, dates: availability });
            } else {
                res.status(200).send({ available: true });
            }
        } catch (error) {
            console.error("Erreur lors de la récupération de la disponibilité de la voiture:", error);
            res.status(500).send({ error: 'Erreur lors de la récupération de la disponibilité de la voiture.' });
        }
    }

    async getLocationsByClient(req, res) {
        const client_id = req.params.clientId;

        try {
            const locations = await LocationModel.getLocationsByClient(client_id);
            res.status(200).send(locations);
        } catch (error) {
            console.error("Erreur lors de la récupération des locations par client:", error);
            res.status(500).send({ error: 'Erreur lors de la récupération des locations par client.' });
        }
    }

    async updateLocation(req, res) {
        const { voiture_matricule, date_debut, date_fin, client_id } = req.body;
        const { id } = req.params; 
    
        try {
          
            const voiture = await VoitureModel.getVoitureByMatricule(voiture_matricule);
            if (!voiture) {
                return res.status(404).send({ error: 'Voiture non trouvée.' });
            }
    
            const prix_par_jour = voiture.prix_par_jour;
    
            
            const updated = await LocationModel.updateLocation(id, voiture_matricule, date_debut, date_fin, client_id, prix_par_jour);
    
            if (updated.affectedRows === 0) {
                return res.status(404).send({ error: 'Location non trouvée.' });
            }
    
            res.status(200).send({ message: 'Location mise à jour avec succès.' });
        } catch (error) {
            console.error("Erreur lors de la mise à jour de la location:", error);
            res.status(500).send({ error: 'Erreur lors de la mise à jour de la location.' });
        }
    }
    

    async deleteLocation(req, res) {
        const { id } = req.params; 
    
        try {
            const success = await LocationModel.deleteLocation(id);
            if (success) {
                res.status(200).send({ message: 'Location supprimée avec succès.' });
            } else {
                res.status(404).send({ error: 'Location non trouvée.' });
            }
        } catch (error) {
            console.error("Erreur lors de la suppression de la location:", error);
            res.status(500).send({ error: 'Erreur lors de la suppression de la location.' });
        }
    }
    
}

module.exports = new LocationController();
