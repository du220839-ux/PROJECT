const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { query } = require('../config/db');

function parseGpsAddress(address) {
  const text = String(address || '').trim();
  if (!text.toUpperCase().startsWith('GPS:')) return null;
  const raw = text.slice(4).trim();
  const parts = raw.split(',');
  if (parts.length !== 2) return null;

  const lat = Number(parts[0].trim());
  const lng = Number(parts[1].trim());
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) return null;

  return { lat, lng };
}

async function reverseGeocode(lat, lng) {
  try {
    const nominatimUrl = `https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${lat}&lon=${lng}&accept-language=vi`;
    const nominatimResp = await fetch(nominatimUrl, {
      headers: { 'User-Agent': 'secondhand-backend/1.0' }
    });

    if (nominatimResp.ok) {
      const data = await nominatimResp.json();
      const a = data?.address || {};
      const city = String(a.city || a.town || a.county || '').trim();
      const state = String(a.state || '').trim();
      if (city && state) return city.toLowerCase() === state.toLowerCase() ? city : `${city}, ${state}`;
      if (state) return state;
      if (city) return city;
    }
  } catch (_) {}

  try {
    const bdcUrl = `https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${lat}&longitude=${lng}&localityLanguage=vi`;
    const bdcResp = await fetch(bdcUrl);
    if (!bdcResp.ok) return null;
    const data = await bdcResp.json();
    const city = String(data?.city || '').trim();
    const province = String(data?.principalSubdivision || '').trim();
    if (city && province) return city.toLowerCase() === province.toLowerCase() ? city : `${city}, ${province}`;
    if (province) return province;
    if (city) return city;
    return null;
  } catch (_) {
    return null;
  }
}

async function normalizeAddressIfGps(userId, address) {
  const parsed = parseGpsAddress(address);
  if (!parsed) return address;

  const readable = await reverseGeocode(parsed.lat, parsed.lng);
  if (!readable) return address;

  try {
    await query(
      `UPDATE dbo.users
       SET [address] = @address
       WHERE id = @id`,
      {
        id: Number(userId),
        address: readable
      }
    );
    return readable;
  } catch (_) {
    return address;
  }
}

async function register(req, res) {
  try {
    const name = String(req.body.name || '').trim();
    const email = String(req.body.email || '').trim().toLowerCase();
    const password = String(req.body.password || '');
    const phone = String(req.body.phone || '').trim();

    if (!name || !email || !password) {
      return res.status(400).json({ message: 'Name, email and password are required' });
    }

    if (password.length < 6) {
      return res.status(400).json({ message: 'Password must be at least 6 characters' });
    }

    const existing = await query(
      `SELECT TOP 1 id
       FROM dbo.users
       WHERE email = @email`,
      { email }
    );

    if (existing.recordset.length) {
      return res.status(409).json({ message: 'Email already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const inserted = await query(
      `INSERT INTO dbo.users (name, email, [password], phone, [role])
       OUTPUT INSERTED.id, INSERTED.name, INSERTED.email, INSERTED.phone,
              INSERTED.[address], INSERTED.[role], INSERTED.avatar, INSERTED.created_at
       VALUES (@name, @email, @password, @phone, 'user')`,
      {
        name,
        email,
        password: hashedPassword,
        phone: phone || null
      }
    );

    return res.status(201).json({
      message: 'Register success',
      user: inserted.recordset[0]
    });
  } catch (error) {
    return res.status(500).json({ message: 'Register failed', error: error.message });
  }
}

async function login(req, res) {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }

    const result = await query(
      `SELECT TOP 1 id, name, email, [password], phone, [address], [role], avatar, created_at
       FROM dbo.users
       WHERE email = @email`,
      { email }
    );

    if (!result.recordset.length) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const user = result.recordset[0];

    // Support both bcrypt hash and plain text password for quick local setup.
    const validPassword = user.password.startsWith('$2')
      ? await bcrypt.compare(password, user.password)
      : password === user.password;

    if (!validPassword) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    const normalizedAddress = await normalizeAddressIfGps(user.id, user.address);
    const { password: _password, ...safeUser } = user;
    safeUser.address = normalizedAddress;

    return res.json({ token, user: safeUser });
  } catch (error) {
    return res.status(500).json({ message: 'Login failed', error: error.message });
  }
}

async function getProfile(req, res) {
  try {
    const userId = Number(req.user.id);

    const result = await query(
      `SELECT TOP 1 id, name, email, phone, [address], [role], avatar, created_at
       FROM dbo.users
       WHERE id = @id`,
      { id: userId }
    );

    if (!result.recordset.length) {
      return res.status(404).json({ message: 'User not found' });
    }

    const row = result.recordset[0];
    row.address = await normalizeAddressIfGps(row.id, row.address);
    return res.json({ user: row });
  } catch (error) {
    return res.status(500).json({ message: 'Cannot load profile', error: error.message });
  }
}

async function updateProfile(req, res) {
  try {
    const userId = Number(req.user.id);
    const name = req.body.name != null ? String(req.body.name).trim() : null;
    const phone = req.body.phone != null ? String(req.body.phone).trim() : null;
    const address = req.body.address != null ? String(req.body.address).trim() : null;

    const current = await query(
      `SELECT TOP 1 name, phone, [address]
       FROM dbo.users
       WHERE id = @id`,
      { id: userId }
    );

    if (!current.recordset.length) {
      return res.status(404).json({ message: 'User not found' });
    }

    const row = current.recordset[0];
    const nextName = name == null || name === '' ? row.name : name;
    const nextPhone = phone == null ? row.phone : (phone === '' ? null : phone);
    const nextAddress = address == null ? row.address : (address === '' ? null : address);

    const updated = await query(
      `UPDATE dbo.users
       SET name = @name,
           phone = @phone,
           [address] = @address
       OUTPUT INSERTED.id, INSERTED.name, INSERTED.email, INSERTED.phone,
              INSERTED.[address], INSERTED.[role], INSERTED.avatar, INSERTED.created_at
       WHERE id = @id`,
      {
        id: userId,
        name: nextName,
        phone: nextPhone,
        address: nextAddress
      }
    );

    return res.json({ message: 'Profile updated', user: updated.recordset[0] });
  } catch (error) {
    return res.status(500).json({ message: 'Update profile failed', error: error.message });
  }
}

module.exports = {
  register,
  login,
  getProfile,
  updateProfile
};
