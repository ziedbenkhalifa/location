const mabase = require('../config/database'); 

class Usermodel {
    static async getusers() {
        return new Promise((resolve, reject) => {
            mabase.query("SELECT * FROM admin", [], (error, result) => {
                if (error) {
                    console.error("Database query error:", error); 
                    reject(error); 
                } else {
                    console.log("Database query result:", result); 
                    resolve(result); 
                }
            });
        });
    }
    static async addadmin(nom, prenom, email, password) {
        return new Promise((resolve, reject) => {
            const sql = "INSERT INTO admin (nom, prenom, email, password) VALUES (?, ?, ?, ?)";
            mabase.query(sql, [nom, prenom, email, password], (error, result) => {
                if (error) {
                    console.error("Error adding admin:", error);
                    reject(error);
                } else {
                    resolve(result);
                }
            });
        });
    }
    static async updateadmin(id, nom, prenom, email, password) {
        return new Promise((resolve, reject) => {
            const sql = "UPDATE admin SET nom=?, prenom=?, email=?, password=? WHERE id=?";
            mabase.query(sql, [nom, prenom, email, password, id], (error, result) => {
                if (error) {
                    console.error("Error updating admin:", error);
                    reject(error);
                } else {
                    resolve(result);
                }
            });
        });
    }
}

module.exports = Usermodel;
