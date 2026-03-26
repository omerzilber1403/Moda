import { Pool } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle database client', err);
});

// Test connection on startup
pool.query('SELECT 1')
  .then(() => console.log('Database connected'))
  .catch((err) => console.error('Database connection failed:', err.message));

export default pool;
