# Remembrance App - Progress Summary

## Current Status: Backend API Completed ✅

### What's Been Built

#### Backend API (Node.js/Express)
- **Location**: `backend/` folder
- **Features**:
  - User authentication (register/login with JWT tokens)
  - Photo upload with multer (supports images up to 10MB)
  - Photo listing and retrieval
  - Daily photo recall (deterministic pick based on day-of-year)
  - SQLite database for data persistence
  - Local file storage for uploaded images

#### API Endpoints
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/photos/upload` - Upload photos (multipart/form-data)
- `GET /api/photos` - List user's photos
- `GET /api/daily` - Get today's photo (deterministic)
- `GET /api/health` - Health check

#### Database Schema
- **Users table**: id, email, password_hash, created_at
- **Photos table**: id, user_id, filename, original_name, mime_type, size, created_at

### Files Created
```
backend/
├── package.json          # Dependencies and scripts
├── index.js             # Main API server
└── README.md            # API documentation
```

## Next Steps for Tomorrow

### 1. Start the Backend Server
```bash
cd backend
npm install
npm start
```
Server will run on `http://localhost:8080`

### 2. Test the API
- Test health endpoint: `GET http://localhost:8080/api/health`
- Test registration: `POST http://localhost:8080/api/auth/register`
- Test photo upload: `POST http://localhost:8080/api/photos/upload`

### 3. iOS App Development
- Create iOS app in Xcode
- Add networking code to connect to backend
- Implement photo picker and upload functionality
- Add authentication screens
- Create daily photo display

### 4. Alternative: Switch to Supabase/Firebase
- **Supabase**: Better for SQL queries, more generous free tier
- **Firebase**: More mature iOS SDK, better Apple Sign-In integration
- Both would eliminate server maintenance

## Technical Decisions Made

### Backend Choice
- **Current**: Custom Node.js/Express API with SQLite
- **Alternative**: Supabase or Firebase (recommended for production)

### Photo Storage
- **Current**: Local file system with SQLite metadata
- **Alternative**: Cloud storage (S3, Firebase Storage, Supabase Storage)

### Daily Photo Algorithm
- **Current**: Deterministic pick based on day-of-year modulo photo count
- **Logic**: `index = dayOfYear % photos.length`

## Cost Analysis
- **365 photos × ~3MB each = ~1.1GB**
- **Firebase**: Free (5GB limit)
- **Supabase**: Free (1GB limit, close to limit)
- **Custom backend**: Free (local storage)

## Development Environment
- **Backend**: Node.js, Express, SQLite, multer
- **iOS**: Xcode, Swift
- **Testing**: iPhone via USB connection

## Quick Start Commands
```bash
# Start backend
cd backend
npm install
npm start

# Test API
curl http://localhost:8080/api/health
```

## Notes
- Backend is production-ready for development
- Consider switching to Supabase/Firebase for easier deployment
- iOS app needs to be built from scratch
- Photo compression recommended to stay under free tier limits

---
*Last updated: [Current Date]*
*Next session: Continue with iOS app development or switch to cloud backend*








