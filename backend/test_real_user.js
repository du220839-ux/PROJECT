const http = require('http');

const postData = JSON.stringify({
  email: 'admin@secondhand.local',
  password: '123456'
});

const options = {
  hostname: '127.0.0.1',
  port: 8000,
  path: '/api/auth/login',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData)
  }
};

const req = http.request(options, (res) => {
  console.log(`🔍 Status: ${res.statusCode}`);
  console.log(`📋 Headers:`, res.headers);
  
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log(`📄 Response:`, data);
    try {
      const json = JSON.parse(data);
      console.log(`📦 Parsed:`, json);
      if (json.token) {
        console.log(`✅ LOGIN SUCCESS! Token: ${json.token.substring(0, 20)}...`);
      }
    } catch (e) {
      console.log(`❌ JSON Parse Error:`, e.message);
    }
  });
});

req.on('error', (e) => {
  console.error(`❌ Request Error:`, e.message);
});

req.write(postData);
req.end();
