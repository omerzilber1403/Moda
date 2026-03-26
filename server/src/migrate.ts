import fs from 'fs';
import path from 'path';
import pool from './db';

async function migrate(): Promise<void> {
  console.log('Running database migration...');

  const sqlPath = path.join(__dirname, 'migrations', '001_initial.sql');
  const sql = fs.readFileSync(sqlPath, 'utf-8');

  try {
    await pool.query(sql);
    console.log('Migration completed successfully.');
  } catch (err) {
    console.error('Migration failed:', err);
    process.exit(1);
  } finally {
    await pool.end();
    process.exit(0);
  }
}

migrate();
