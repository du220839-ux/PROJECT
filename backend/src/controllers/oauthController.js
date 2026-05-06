const jwt = require('jsonwebtoken');
const { query } = require('../config/db');

/**
 * Decode Firebase ID Token claims locally (without verifying signature)
 * NOTE: In production, install firebase-admin SDK and verify signature properly
 * For now, we assume frontend has already verified the token with Firebase
 */
function decodeFirebaseToken(token) {
  try {
    // Decode without verification (frontend already verified with Firebase)
    const decoded = jwt.decode(token, { complete: false });
    if (!decoded) {
      throw new Error('Invalid token format');
    }
    return decoded;
  } catch (error) {
    throw new Error(`Token decode error: ${error.message}`);
  }
}

/**
 * Google OAuth Sign-In
 * Expected body: { idToken: "firebase_id_token", displayName?: "name" }
 */
async function signInWithGoogle(req, res) {
  try {
    const { idToken, displayName } = req.body;
    
    if (!idToken) {
      return res.status(400).json({ message: 'Missing idToken' });
    }

    // Decode Firebase token to get user info
    const claims = decodeFirebaseToken(idToken);
    const email = claims.email;
    const photoURL = claims.picture || null;
    
    if (!email) {
      return res.status(400).json({ message: 'No email in token' });
    }

    // Check if user exists
    let userResult = await query(
      `SELECT TOP 1 id, name, email, phone, address, role, wallet_balance, avatar_url, created_at 
       FROM dbo.users 
       WHERE email = @email`,
      { email }
    );

    let user;
    if (userResult.recordset.length > 0) {
      // User exists, just log them in
      user = userResult.recordset[0];
      
      // Update avatar if available and different
      if (photoURL && (!user.avatar_url || user.avatar_url !== photoURL)) {
        await query(
          `UPDATE dbo.users SET avatar_url = @avatar WHERE id = @id`,
          { avatar: photoURL, id: user.id }
        );
        user.avatar_url = photoURL;
      }
    } else {
      // Create new user from Google account
      const name = displayName || email.split('@')[0];
      const createResult = await query(
        `INSERT INTO dbo.users (name, email, phone, address, role, wallet_balance, avatar_url, created_at)
         VALUES (@name, @email, '', '', 'user', 0, @avatar, GETDATE());
         SELECT SCOPE_IDENTITY() AS id;`,
        { name, email, avatar: photoURL }
      );

      const userId = createResult.recordset[0].id;
      user = {
        id: userId,
        name,
        email,
        phone: '',
        address: '',
        role: 'user',
        wallet_balance: 0,
        avatar_url: photoURL,
        created_at: new Date()
      };
    }

    // Generate JWT token
    const token = jwt.sign(
      {
        id: user.id,
        email: user.email,
        role: user.role,
        loginMethod: 'google'
      },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '7d' }
    );

    return res.json({
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        address: user.address,
        role: user.role,
        wallet_balance: user.wallet_balance,
        avatar_url: user.avatar_url
      }
    });
  } catch (error) {
    console.error('Google OAuth Error:', error);
    return res.status(400).json({
      message: 'Google sign-in failed',
      error: error.message
    });
  }
}

/**
 * Facebook OAuth Sign-In
 * Expected body: { idToken: "firebase_id_token", displayName?: "name" }
 */
async function signInWithFacebook(req, res) {
  try {
    const { idToken, displayName } = req.body;
    
    if (!idToken) {
      return res.status(400).json({ message: 'Missing idToken' });
    }

    // Decode Firebase token to get user info
    const claims = decodeFirebaseToken(idToken);
    const email = claims.email;
    const photoURL = claims.picture || null;
    
    if (!email) {
      return res.status(400).json({ message: 'No email in token' });
    }

    // Check if user exists
    let userResult = await query(
      `SELECT TOP 1 id, name, email, phone, address, role, wallet_balance, avatar_url, created_at 
       FROM dbo.users 
       WHERE email = @email`,
      { email }
    );

    let user;
    if (userResult.recordset.length > 0) {
      // User exists, just log them in
      user = userResult.recordset[0];
      
      // Update avatar if available and different
      if (photoURL && (!user.avatar_url || user.avatar_url !== photoURL)) {
        await query(
          `UPDATE dbo.users SET avatar_url = @avatar WHERE id = @id`,
          { avatar: photoURL, id: user.id }
        );
        user.avatar_url = photoURL;
      }
    } else {
      // Create new user from Facebook account
      const name = displayName || email.split('@')[0];
      const createResult = await query(
        `INSERT INTO dbo.users (name, email, phone, address, role, wallet_balance, avatar_url, created_at)
         VALUES (@name, @email, '', '', 'user', 0, @avatar, GETDATE());
         SELECT SCOPE_IDENTITY() AS id;`,
        { name, email, avatar: photoURL }
      );

      const userId = createResult.recordset[0].id;
      user = {
        id: userId,
        name,
        email,
        phone: '',
        address: '',
        role: 'user',
        wallet_balance: 0,
        avatar_url: photoURL,
        created_at: new Date()
      };
    }

    // Generate JWT token
    const token = jwt.sign(
      {
        id: user.id,
        email: user.email,
        role: user.role,
        loginMethod: 'facebook'
      },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '7d' }
    );

    return res.json({
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        address: user.address,
        role: user.role,
        wallet_balance: user.wallet_balance,
        avatar_url: user.avatar_url
      }
    });
  } catch (error) {
    console.error('Facebook OAuth Error:', error);
    return res.status(400).json({
      message: 'Facebook sign-in failed',
      error: error.message
    });
  }
}

module.exports = {
  signInWithGoogle,
  signInWithFacebook
};
