const ClientModel = require('../models/ClientModel');
const AdminModel = require('../models/AdminModel');
const jwt = require('jsonwebtoken');
const verifyToken = require('../authMiddleware');

class ClientController {
    static async getAllClients(req, res) {
        try {
            const clients = await ClientModel.getAllClients();
            res.status(200).json(clients);
        } catch (error) {
            console.error("Erreur lors de la récupération des clients:", error);
            res.status(500).json({ error: 'Erreur lors de la récupération des clients.' });
        }
    }

    static async loginController(req, res) {
        try {
            const { email, password } = req.body;
    
            let user = await ClientModel.getClientByEmail(email);
            let role = 'client';
    
            if (!user) {
                user = await AdminModel.getAdminByEmail(email);
                role = 'admin';
            }
    
            if (!user) {
                return res.status(404).json({ error: 'Utilisateur introuvé dans la base' });
            }
    
            if (user.password !== password) {
                return res.status(404).json({ error: 'Mot de passe invalide' });
            }
    
            const token = jwt.sign(
                { id: user.id, role: role }, 
                process.env.JWT_SECRET, 
                { expiresIn: '1h' }
            );
    
            res.status(200).json({
                message: 'Connexion réussie',
                token,
                userId: user.id,  
                role: role        
            });
        } catch (error) {
            console.error("Erreur lors de la récupération des utilisateurs:", error);
            res.status(500).json({ error: error.message });
        }
    }

    static async getClientLocations(req, res) {
        try {
            const clientId = req.params.clientId;
            const locations = await ClientModel.getClientLocations(clientId);

            if (locations.length === 0) {
                return res.status(404).json({ message: "Aucune location trouvée pour ce client." });
            }

            res.status(200).json(locations);
        } catch (error) {
            console.error("Erreur lors de la récupération des locations:", error);
            res.status(500).json({ error: 'Erreur lors de la récupération des locations.' });
        }
    }

    static async getClientLikedCars(req, res) {
        try {
            const clientId = req.params.clientId;
            const likedCars = await ClientModel.getClientLikedCars(clientId);

            if (likedCars.length === 0) {
                return res.status(404).json({ message: "Aucune voiture likée trouvée pour ce client." });
            }

            res.status(200).json(likedCars);
        } catch (error) {
            console.error("Erreur lors de la récupération des voitures likées:", error);
            res.status(500).json({ error: 'Erreur lors de la récupération des voitures likées.' });
        }
    }
    static async createClient(req, res) {
        try {
            const { nom, prenom, email, password } = req.body;
            const clientId = await ClientModel.createClient({ nom, prenom, email, password });
            res.status(201).json({ message: 'Client créé avec succès', clientId });
        } catch (error) {
            if (error.message === 'L\'email est déjà utilisé.') {
                res.status(400).json({ error: error.message });
            } else {
                console.error("Erreur lors de la création du client:", error);
                res.status(500).json({ error: 'Erreur lors de la création du client.' });
            }
        }
    }
    static async updateClient(req, res) {
        try {
            const { id } = req.params;
            const { nom, prenom, email, password } = req.body;
            const updatedClient = await ClientModel.updateClient(id, { nom, prenom, email, password });
    
            if (updatedClient) {
                res.status(200).json({ message: 'Client modifié avec succès', updatedClient });
            } else {
                res.status(404).json({ error: 'Client non trouvé.' });
            }
        } catch (error) {
            if (error.message === 'L\'email est déjà utilisé.') {
                res.status(400).json({ error: error.message });
            } else {
                console.error("Erreur lors de la modification du client:", error);
                res.status(500).json({ error: 'Erreur lors de la modification du client.' });
            }
        }
    }
    static async deleteClient(req, res) {
        try {
            const { id } = req.params;
            const deleted = await ClientModel.deleteClient(id);
    
            if (deleted) {
                res.status(200).json({ message: 'Client supprimé avec succès' });
            } else {
                res.status(404).json({ error: 'Client non trouvé.' });
            }
        } catch (error) {
            console.error("Erreur lors de la suppression du client:", error);
            res.status(500).json({ error: 'Erreur lors de la suppression du client.' });
        }
    }
        
   
static async likeCar(req, res) {
    try {
        const { clientId, carId } = req.body;

     
        const existingLike = await ClientModel.getClientLikedCars(clientId);
        const carIsLiked = existingLike.some(car => car.matricule === carId);

        if (carIsLiked) {
          
            await ClientModel.removeLike(clientId, carId);
        } else {
          
            await ClientModel.addLike(clientId, carId);
        }

        res.status(200).json({ message: carIsLiked ? 'Like removed' : 'Car liked' });
    } catch (error) {
        console.error("Erreur lors de la mise à jour du like:", error);
        res.status(500).json({ error: 'Erreur lors de la mise à jour du like.' });
    }
}



static async getClientLikedCars(req, res) {
    try {
        const clientId = req.params.clientId;
        const likedCars = await ClientModel.getClientLikedCars(clientId);

        if (likedCars.length === 0) {
            return res.status(404).json({ message: "Aucune voiture aimée trouvée pour ce client." });
        }

        res.status(200).json(likedCars);
    } catch (error) {
        console.error("Erreur lors de la récupération des voitures aimées:", error);
        res.status(500).json({ error: 'Erreur lors de la récupération des voitures aimées.' });
    }
}
static async getClientById(req, res) {
    const clientId = req.params.id; 

    try {
        const client = await ClientModel.getClientById(clientId);
        if (client) {
            res.send(client); 
        } else {
            res.status(404).send({ error: 'Client not found' });
        }
    } catch (error) {
        console.error("Error retrieving client data:", error); 
        res.status(500).send({ error: 'Error retrieving client data' }); 
    }
}

    
}

module.exports = ClientController;
