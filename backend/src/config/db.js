const sql = require('mssql');

const config = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER,
  database: process.env.DB_NAME,
  port: Number(process.env.DB_PORT || 1433),
  options: {
    encrypt: String(process.env.DB_ENCRYPT).toLowerCase() === 'true',
    trustServerCertificate: String(process.env.DB_TRUST_CERT).toLowerCase() !== 'false'
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000
  }
};

let pool;

async function connectDB() {
  if (pool) return pool;
  pool = await sql.connect(config);
  return pool;
}

async function query(sqlText, inputs = {}) {
  const db = await connectDB();
  const request = db.request();
  
  Object.entries(inputs).forEach(([key, value]) => {
    // Auto-detect type for parameters
    if (typeof value === 'number') {
      if (Number.isInteger(value)) {
        request.input(key, sql.Int, value);
      } else {
        request.input(key, sql.Decimal(10, 2), value);
      }
    } else if (typeof value === 'boolean') {
      request.input(key, sql.Bit, value ? 1 : 0);
    } else if (value instanceof Date) {
      request.input(key, sql.DateTime, value);
    } else {
      // Default to VarChar for strings
      request.input(key, sql.VarChar(sql.MAX), value);
    }
  });
  
  return request.query(sqlText);
}

module.exports = {
  sql,
  connectDB,
  query
};
