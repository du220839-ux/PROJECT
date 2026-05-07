@echo off
REM Copy this file to firebase_env.local.bat and fill your Firebase Web App values.

set FIREBASE_API_KEY=YOUR_FIREBASE_API_KEY
set FIREBASE_APP_ID=YOUR_FIREBASE_APP_ID
set FIREBASE_MESSAGING_SENDER_ID=YOUR_FIREBASE_MESSAGING_SENDER_ID
set FIREBASE_PROJECT_ID=YOUR_FIREBASE_PROJECT_ID

REM Optional but recommended for web auth.
set FIREBASE_AUTH_DOMAIN=YOUR_PROJECT_ID.firebaseapp.com
set FIREBASE_STORAGE_BUCKET=YOUR_PROJECT_ID.appspot.com

REM Optional for iOS bundles.
set FIREBASE_IOS_BUNDLE_ID=