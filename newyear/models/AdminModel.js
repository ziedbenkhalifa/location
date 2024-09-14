const db = require('../config/database'); 

class AdminModel {
    static getAdminByEmail(email) {
        return new Promise((resolve, reject) => {
            const sql = "SELECT * FROM admin WHERE email = ?";
            db.query(sql, [email], (error, results) => {
                if (error) {
                    console.error("Erreur lors de la récupération des admins:", error);
                    reject(error);
                } else {
                    resolve(results[0]);
                }
            });
        });
    }
}

module.exports = AdminModel;
