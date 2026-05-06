SecondHand Backend (Express + SQL Server)

1) Install dependencies
- Open terminal in backend folder
- Run: npm install

2) Configure environment
- Copy .env.example to .env
- Update values if needed

3) Run server
- Dev mode: npm run dev
- Production mode: npm start

Base URL:
- http://localhost:8000/api

APIs ready for Flutter:
1. POST /api/auth/login
   Body JSON:
   {
     "email": "user@example.com",
     "password": "123456"
   }
   Response:
   {
     "token": "...",
     "user": { ... }
   }

2. GET /api/products?page=1&limit=20
   Header optional:
   Authorization: Bearer <token>
   Response:
   {
     "data": [ ... ],
     "page": 1,
     "limit": 20
   }

3. POST /api/favorites/toggle
   Header required:
   Authorization: Bearer <token>
   Body JSON:
   {
     "product_id": 1
   }

Flutter config:
- Update lib/config/app_config.dart
- Set baseUrl to backend API, for example:
  Android emulator: http://10.0.2.2:8000/api
  iOS simulator / desktop: http://127.0.0.1:8000/api
