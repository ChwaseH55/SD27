const admin = require('firebase-admin');
const path = require('path');

// Load the service account key
const serviceAccount = require(path.join(__dirname, 'firebase-service-key.json')); // update path as needed

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket: 'sd27-87d55.firebasestorage.app'
  });
}

module.exports = admin;
