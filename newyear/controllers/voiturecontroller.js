const VoitureModel = require("../models/VoitureModel");

class VoitureController {
    static async getAllVoitures(req, res) {
        try {
            const voitures = await VoitureModel.getAllVoitures();
            res.status(200).send(voitures);
        } catch (error) {
            console.error("Error retrieving voitures:", error);
            res.status(500).send({ error: 'Error retrieving voitures' });
        }
    }

    static async addVoiture(req, res) {
        const { matricule, marque, couleur, type, disponibilite, image_url, prix_par_jour } = req.body;
        try {
            await VoitureModel.addVoiture(matricule, marque, couleur, type, disponibilite, image_url, prix_par_jour);
            res.status(201).send({ message: 'Voiture added successfully' });
        } catch (error) {
            console.error("Error adding voiture:", error);
            res.status(500).send({ error: 'Error adding voiture' });
        }
    }

    static async updateVoiture(req, res) {
        const { matricule } = req.params;
        const { marque, couleur, type, disponibilite, image_url, prix_par_jour } = req.body;
        try {
            await VoitureModel.updateVoiture(matricule, marque, couleur, type, disponibilite, image_url, prix_par_jour);
            res.status(200).send({ message: 'Voiture updated successfully' });
        } catch (error) {
            console.error("Error updating voiture:", error);
            res.status(500).send({ error: 'Error updating voiture' });
        }
    }

    static async deleteVoiture(req, res) {
        const { matricule } = req.params;
        try {
            await VoitureModel.deleteVoiture(matricule);
            res.status(200).send({ message: 'Voiture deleted successfully' });
        } catch (error) {
            console.error("Error deleting voiture:", error);
            res.status(500).send({ error: 'Error deleting voiture' });
        }
    }

    static async getAvailableVoitures(req, res) {
        try {
            const availableVoitures = await VoitureModel.getAvailableVoitures();
            res.status(200).send(availableVoitures);
        } catch (error) {
            console.error("Error retrieving available voitures:", error);
            res.status(500).send({ error: 'Error retrieving available voitures' });
        }
    }

    static async getNotAvailableVoitures(req, res) {
        try {
            const notAvailableVoitures = await VoitureModel.getNotAvailableVoitures();
            res.status(200).send(notAvailableVoitures);
        } catch (error) {
            console.error("Error retrieving not available voitures:", error);
            res.status(500).send({ error: 'Error retrieving not available voitures' });
        }
    }

    static checkAvailability(voiture_matricule, date_debut, date_fin) {
        return new Promise((resolve, reject) => {
            const sql = `
                SELECT COUNT(*) AS count 
                FROM location 
                WHERE voiture_matricule = ? 
                AND (
                    (date_debut <= ? AND date_fin >= ?) 
                    OR (date_debut <= ? AND date_fin >= ?) 
                    OR (date_debut >= ? AND date_fin <= ?)
                )
            `;
            const values = [voiture_matricule, date_debut, date_debut, date_fin, date_fin, date_debut, date_fin];

            mabase.query(sql, values, (error, result) => {
                if (error) {
                    console.error("Erreur lors de la vérification de la disponibilité de la voiture:", error);
                    reject(error);
                } else {
                    const count = result[0].count;
                    const isAvailable = count === 0; 
                    resolve(isAvailable);
                }
            });
        });
    }
   

static async getVoituresByBrandAndPrice(req, res) {
    const { marque, maxPrix } = req.query;

    try {
        const voitures = await VoitureModel.getVoituresByBrandAndPrice(marque, maxPrix);
        res.status(200).send(voitures);
    } catch (error) {
        console.error("Error retrieving voitures by brand and price:", error);
        res.status(500).send({ error: 'Error retrieving voitures by brand and price' });
    }
}


static async getVoitureById(req, res) {
    const matricule = req.params.id; 

    try {
        const voiture = await VoitureModel.getVoitureByMatricule(matricule);
        if (!voiture) {
            return res.status(404).send({ message: 'Voiture non trouvée' });
        }
        return res.status(200).send(voiture);
    } catch (error) {
        console.error('Error retrieving voiture:', error);
        return res.status(500).send({ error: 'Error retrieving voiture' });
    }
}

}

module.exports = VoitureController;
