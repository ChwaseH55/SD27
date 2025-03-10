const { Pool } = require('pg');

const pool = new Pool({
    user: 'ClubAdmin',
    host: 'golfclubucf.ch6e6y4m064c.us-east-2.rds.amazonaws.com',
    database: 'golfclub_db', // Use the correct database name
    password: 'X7knL34!#',
    port: 5432,
    ssl: {
      rejectUnauthorized: false, // Enable SSL
    },
  });
  

module.exports = pool;


// Function to test the connection
const testConnection = async () => {
    try {
        const client = await pool.connect();
        console.log('Connected to the database successfully');
        client.release(); // Release the client back to the pool
    } catch (err) {
        console.error('Database connection error:', err);
    }
};

// Call the test function (optional, can be removed later)
testConnection();

// Export the pool to use it in other parts of your application
module.exports = {
    query: (text, params) => pool.query(text, params),
    // Add other methods as needed
};
