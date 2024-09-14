const mabase = require('../config/database');

class LocationModel {
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

    static createLocation(voiture_matricule, date_debut, date_fin, client_id, prix_par_jour) {
        return new Promise((resolve, reject) => {
            const sql = "INSERT INTO location (voiture_matricule, date_debut, date_fin, client_id, prix_par_jour) VALUES (?, ?, ?, ?, ?)";
            const values = [voiture_matricule, date_debut, date_fin, client_id, prix_par_jour];
    
            mabase.query(sql, values, (error, result) => {
                if (error) {
                    console.error("Erreur lors de la création de la location:", error);
                    reject(error);
                } else {
                    resolve(result.insertId); 
                }
            });
        });
    }
    

    static getAllLocations() {
        return new Promise((resolve, reject) => {
            const sql = "SELECT * FROM location";

            mabase.query(sql, (error, results) => {
                if (error) {
                    console.error("Erreur lors de la récupération des locations:", error);
                    reject(error);
                } else {
                    resolve(results);
                }
            });
        });
    }

    static getCarAvailability(voiture_matricule) {
        return new Promise((resolve, reject) => {
            const sql = `
                SELECT date_debut, date_fin
                FROM location
                WHERE voiture_matricule = ? 
                AND date_fin >= CURDATE()
                ORDER BY date_debut ASC
            `;
            mabase.query(sql, [voiture_matricule], (error, result) => {
                if (error) {
                    console.error("Erreur lors de la récupération de la disponibilité de la voiture:", error);
                    reject(error);
                } else {
                    resolve(result);
                }
            });
        });
    }

    static getLocationsByClient(client_id) {
        return new Promise((resolve, reject) => {
            const sql = `
                SELECT location.date_debut, location.date_fin, voiture.marque, voiture.couleur, voiture.prix_par_jour, voiture.type
                FROM location
                JOIN voiture ON location.voiture_matricule = voiture.matricule
                WHERE location.client_id = ?
            `;
            mabase.query(sql, [client_id], (error, results) => {
                if (error) {
                    console.error("Erreur lors de la récupération des locations du client:", error);
                    reject(error);
                } else {
                    resolve(results);
                }
            });
        });
    }

    static updateLocation(id, voiture_matricule, date_debut, date_fin, client_id, prix_par_jour) {
        return new Promise((resolve, reject) => {
            const sql = `
                UPDATE location 
                SET voiture_matricule = ?, date_debut = ?, date_fin = ?, client_id = ?, prix_par_jour = ?
                WHERE id = ?
            `;
            const values = [voiture_matricule, date_debut, date_fin, client_id, prix_par_jour, id];
    
            mabase.query(sql, values, (error, result) => {
                if (error) {
                    console.error("Erreur lors de la mise à jour de la location:", error);
                    reject(error);
                } else {
                    resolve(result); 
                }
            });
        });
    }
    

    static deleteLocation(id) {
        return new Promise((resolve, reject) => {
            const sql = "DELETE FROM location WHERE id = ?";
            mabase.query(sql, [id], (error, result) => {
                if (error) {
                    console.error("Erreur lors de la suppression de la location:", error);
                    reject(error);
                } else {
                    resolve(result.affectedRows > 0); 
                }
            });
        });
    }
    
}

module.exports = LocationModel;
