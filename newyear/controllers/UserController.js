const Usermodel = require("../models/Usermodel");

class UserController {
    static async getallusers(req, res) {
        try {
            const results = await Usermodel.getusers();
            if (results) {
                res.send(results); 
            } else {
                res.status(404).send({ error: 'No users found' });
            }
        } catch (error) {
            console.error("Error retrieving users:", error); 
            res.status(500).send({ error: 'Error retrieving users' }); 
        }
    }
 
        static async addadmin(req, res) {
            const { nom, prenom, email, password } = req.body;
            try {
                await Usermodel.addadmin(nom, prenom, email, password);
                res.status(201).send({ message: 'Admin added successfully' });
            } catch (error) {
                console.error("Error adding admin:", error);
                res.status(500).send({ error: 'Error adding admin', details: error.message });
            }
        }
    static async updateadmin(req, res) {
        const { id } = req.params;
        const { nom, prenom, email, password } = req.body;
        try {
            await Usermodel.updateadmin(id, nom, prenom, email, password);
            res.status(200).send({ message: 'admin updated successfully' });
        } catch (error) {
            console.error("Error updating voiture:", error);
            res.status(500).send({ error: 'Error updating voiture' });
        }
    }
}

module.exports = UserController;