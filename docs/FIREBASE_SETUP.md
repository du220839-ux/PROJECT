# Firebase Gmail Verification Setup

If registration works but Gmail verification cannot be tested, your Firebase Web config is likely missing.

## 1) Enable Email/Password in Firebase
- Open Firebase Console > Authentication > Sign-in method.
- Enable `Email/Password`.

## 2) Authorize localhost for web
- Open Firebase Console > Authentication > Settings > Authorized domains.
- Add `localhost` and `127.0.0.1`.

## 3) Create local env file
- Copy `firebase_env.sample.bat` to `firebase_env.local.bat`.
- Fill the required values from Firebase Project Settings > General > Your apps (Web).

## 4) Run app with Firebase vars
- Run `run_app_firebase.bat`.

## 5) Test flow
- Register with a new Gmail.
- App opens Verify Email screen.
- Open Gmail and click verification link.
- Return app and click `Toi da xac minh`.
- Login with same email/password.

## Notes
- Without Firebase vars, app still supports backend registration/login but skips Gmail verification.
- If you see `operation-not-allowed`, Email/Password is not enabled in Firebase Auth.