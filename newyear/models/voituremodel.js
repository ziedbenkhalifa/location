const mabase = require('../config/database');

class VoitureModel {
    static async getAllVoitures() {
        return new Promise((resolve, reject) => {
            mabase.query("SELECT * FROM voiture", (error, result) => {
                if (error) {
                    console.error("Database query error:", error);
                    reject(error);
                } else {
                    resolve(result);
                }
            });
        });
    }

    static async addVoiture(matricule, marque, couleur, type, disponibilite, image_url, prix_par_jour) {
        return new Promise((resolve, reject) => {
            const sql = "INSERT INTO voiture (matricule, marque, couleur, type, disponibilite, image_url, prix_par_jour) VALUES (?, ?, ?, ?, ?, ?, ?)";
            mabase.query(sql, [matricule, marque, couleur, type, disponibilite, image_url, prix_par_jour], (error, result) => {
                if (error) {
                    console.error("Error adding voiture:", error);
                    reject(error);
                } else {
                    resolve(result);
                }
            });
        });
    }

    static async updateVoiture(matricule, marque, couleur, type, disponibilite, image_url, prix_par_jour) {
        return new Promise((resolve, reject) => {
            const sql = "UPDATE voiture SET marque=?, couleur=?, type=?, disponibilite=?, image_url=?, prix_par_jour=? WHERE matricule=?";
            mabase.query(sql, [marque, couleur, type, disponibilite, image_url, prix_par_jour, matricule], (error, result) => {
                if (error) {
                    console.error("Error updating voiture:", error);
                    reject(error);
                } else {
                    resolve(result);
                }
            });
        });
    }

    static async getVoitureByMatricule(matricule) {
        return new Promise((resolve, reject) => {
            const sql = "SELECT * FROM voiture WHERE matricule = ?";
            mabase.query(sql, [matricule], (error, result) => {
                if (error) {
                    console.error("Error retrieving voiture by matricule:", error);
                    reject(error);
                } else {
                    resolve(result[0]);
                }
            });
        });
    }

    static async getNotAvailableVoitures() {
        return new Promise((resolve, reject) => {
            const sql = "SELECT matricule, marque, couleur, type, prix_par_jour FROM voiture WHERE disponibilite = 0";
            mabase.query(sql, (error, result) => {
                if (error) {
                    console.error("Error retrieving not available voitures:", error);
                    reject(error);
                } else {
                    resolve(result);
                }
            });
        });
    }

    static async getVoitureByMatricule(matricule) {
        return new Promise((resolve, reject) => {
            const sql = "SELECT * FROM voiture WHERE matricule = ?";
            mabase.query(sql, [matricule], (error, result) => {
                if (error) {
                    console.error("Error retrieving voiture by matricule:", error);
                    reject(error);
                } else {
                    resolve(result[0]);
                }
            });
        });
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

    static updateDisponibilite(voiture_matricule, disponibilite) {
        return new Promise((resolve, reject) => {
            const sql = "UPDATE voiture SET disponibilite = ? WHERE matricule = ?";
            const values = [disponibilite, voiture_matricule];

            mabase.query(sql, values, (error, result) => {
                if (error) {
                    console.error("Erreur lors de la mise à jour de la disponibilité de la voiture:", error);
                    reject(error);
                } else {
                    resolve(result);
                }
            });
        });
    }
    static async getVoituresByBrandAndPrice(marque, maxPrix) {
        return new Promise((resolve, reject) => {
        
            const sql = `
                SELECT * FROM voiture 
                WHERE marque LIKE ? AND prix_par_jour <= ?
            `;
           
            const values = [`%${marque}%`, parseFloat(maxPrix)];
    
         
            mabase.query(sql, values, (error, result) => {
                if (error) {
                    console.error("Error retrieving voitures by brand and price:", error);
                    reject(error);
                } else {
                    resolve(result);
                }
            });
        });
    }

    static async deleteVoiture(matricule) {
        return new Promise((resolve, reject) => {
            const sql = "DELETE FROM voiture WHERE matricule = ?";
            mabase.query(sql, [matricule], (error, result) => {
                if (error) {
                    console.error("Error deleting voiture:", error);
                    reject(error);
                } else {
                    resolve(result);
                }
            });
        });
    }



    static async getVoitureByMatricule(matricule) {
        return new Promise((resolve, reject) => {
            const sql = "SELECT * FROM voiture WHERE matricule = ?";
            mabase.query(sql, [matricule], (error, result) => {
                if (error) {
                    console.error("Error retrieving voiture by matricule:", error);
                    reject(error);
                } else {
                    resolve(result[0]); 
                }
            });
        });
    }
}

module.exports = VoitureModel;
