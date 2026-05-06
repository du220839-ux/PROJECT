const { query } = require('../config/db');

// Middleware to check if user is admin
const requireAdmin = async (req, res, next) => {
  try {
    // Get token from header
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'No token provided' });
    }

    const token = authHeader.substring(7);
    
    // Verify JWT token (you'll need to implement JWT verification)
    const jwt = require('jsonwebtoken');
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Check if user has admin role
    const userResult = await query(`
      SELECT u.*, ar.role_name, ar.permissions 
      FROM users u
      LEFT JOIN admin_users au ON u.id = au.user_id
      LEFT JOIN admin_roles ar ON au.role_id = ar.role_id
      WHERE u.id = @user_id AND au.is_active = 1
    `, { user_id: decoded.id });

    if (userResult.recordset.length === 0) {
      return res.status(403).json({ message: 'Admin access required' });
    }

    const user = userResult.recordset[0];
    
    // Parse permissions
    let permissions = [];
    if (user.permissions) {
      try {
        permissions = JSON.parse(user.permissions);
      } catch (e) {
        permissions = [];
      }
    }

    // Check if user has specific permission (optional)
    const hasPermission = (permission) => {
      return permissions.includes('*') || permissions.includes(permission);
    };

    // Add user and permission check to request
    req.user = {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role_name,
      permissions: permissions,
      hasPermission
    };

    next();
  } catch (error) {
    console.error('Admin auth error:', error);
    return res.status(401).json({ message: 'Invalid token' });
  }
};

// Middleware to check specific permission
const requirePermission = (permission) => {
  return (req, res, next) => {
    if (!req.user || !req.user.hasPermission(permission)) {
      return res.status(403).json({ 
        message: `Permission '${permission}' required` 
      });
    }
    next();
  };
};

module.exports = {
  requireAdmin,
  requirePermission
};
