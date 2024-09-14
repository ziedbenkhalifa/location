const db = require('../config/database');

class ClientModel {
    static async getAllClients() {
        return new Promise((resolve, reject) => {
            const sql = "SELECT * FROM client";
            db.query(sql, (error, results) => {
                if (error) {
                    console.error("Erreur lors de la récupération des clients:", error);
                    reject(error);
                } else {
                    resolve(results);
                }
            });
        });
    }

    static async getClientByEmail(email) {
        return new Promise((resolve, reject) => {
            const sql = "SELECT * FROM client WHERE email = ?";
            db.query(sql, [email], (error, results) => {
                if (error) {
                    console.error("Erreur lors de la récupération du client par email:", error);
                    reject(error);
                } else {
                    resolve(results[0]); 
                }
            });
        });
    }

    static async getClientLocations(clientId) {
        return new Promise((resolve, reject) => {
            const sql = `
                SELECT l.id, l.date_debut, l.date_fin, v.matricule, v.marque, v.couleur, v.type
                FROM location l
                INNER JOIN voiture v ON l.voiture_matricule = v.matricule
                WHERE l.client_id = ?;
            `;
            db.query(sql, [clientId], (error, results) => {
                if (error) {
                    console.error("Erreur lors de la récupération des locations:", error);
                    reject(error);
                } else {
                    resolve(results);
                }
            });
        });
    }

    static async getClientLikedCars(clientId) {
        return new Promise((resolve, reject) => {
            const sql = `
                SELECT v.matricule, v.marque, v.couleur, v.type
                FROM \`like\` l
                INNER JOIN voiture v ON l.voiture_matricule = v.matricule
                WHERE l.client_id = ?;
            `;
            db.query(sql, [clientId], (error, results) => {
                if (error) {
                    console.error("Erreur lors de la récupération des voitures likées:", error);
                    reject(error);
                } else {
                    resolve(results);
                }
            });
        });
    }

    static async emailExists(email) {
        return new Promise((resolve, reject) => {
            const sql = "SELECT COUNT(*) AS count FROM client WHERE email = ?";
            db.query(sql, [email], (error, results) => {
                if (error) {
                    console.error("Erreur lors de la vérification de l'email:", error);
                    reject(error);
                } else {
                    resolve(results[0].count > 0); 
                }
            });
        });
    }

    static async createClient({ nom, prenom, email, password }) {
        try {
         
            const emailAlreadyExists = await ClientModel.emailExists(email);
            if (emailAlreadyExists) {
                throw new Error('L\'email est déjà utilisé.');
            }
    
            return new Promise((resolve, reject) => {
                const sql = `INSERT INTO client (nom, prenom, email, password) VALUES (?, ?, ?, ?)`;
                db.query(sql, [nom, prenom, email, password], (error, results) => {
                    if (error) {
                        console.error("Erreur lors de la création du client:", error);
                        reject(error);
                    } else {
                        resolve(results.insertId); 
                    }
                });
            });
        } catch (error) {
            console.error("Erreur lors de la création du client:", error);
            throw error; 
        }
    }
    static async addLike(clientId, carId) {
        return new Promise((resolve, reject) => {
            const sql = 'INSERT INTO `like` (client_id, voiture_matricule) VALUES (?, ?)';
            db.query(sql, [clientId, carId], (error, results) => {
                if (error) {
                    console.error("Erreur lors de l'ajout du like:", error);
                    reject(error);
                } else {
                    resolve(results);
                }
            });
        });
    }
    
    static async removeLike(clientId, carId) {
        return new Promise((resolve, reject) => {
            const sql = 'DELETE FROM `like` WHERE client_id = ? AND voiture_matricule = ?';
            db.query(sql, [clientId, carId], (error, results) => {
                if (error) {
                    console.error("Erreur lors de la suppression du like:", error);
                    reject(error);
                } else {
                    resolve(results);
                }
            });
        });
    }
    static async getClientLikedCars(clientId) {
        return new Promise((resolve, reject) => {
            const sql = `
                SELECT v.matricule, v.marque, v.couleur, v.type, v.image_url
                FROM \`like\` l
                INNER JOIN voiture v ON l.voiture_matricule = v.matricule
                WHERE l.client_id = ?;
            `;
            db.query(sql, [clientId], (error, results) => {
                if (error) {
                    console.error("Erreur lors de la récupération des voitures aimées:", error);
                    reject(error);
                } else {
                    resolve(results); 
                }
            });
        });
    }
    static async getClientById(clientId) {
        return new Promise((resolve, reject) => {
            db.query("SELECT * FROM client WHERE id = ?", [clientId], (error, results) => {
                if (error) {
                    console.error("Database query error:", error);
                    reject(error);
                } else {
                    resolve(results[0]);
                }
            });
        });
    }
    static updateClient(id, clientData) {
        return new Promise((resolve, reject) => {
            const { nom, prenom, email, password } = clientData;
            const query = `UPDATE client SET nom = ?, prenom = ?, email = ?, password = ? WHERE id = ?`;
            db.query(query, [nom, prenom, email, password, id], (error, result) => {
                if (error) return reject(error);

                if (result.affectedRows === 0) {
                    return resolve(null);
                }

                resolve({ id, nom, prenom, email, password });
            });
        });
    }

    static deleteClient(id) {
        return new Promise((resolve, reject) => {
            const query = `DELETE FROM client WHERE id = ?`;
            db.query(query, [id], (error, result) => {
                if (error) return reject(error);

                resolve(result.affectedRows > 0);
            });
        });
    }
        
    
}

module.exports = ClientModel;
