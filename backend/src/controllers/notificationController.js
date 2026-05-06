const { query } = require('../config/db');

async function getMyNotifications(req, res) {
  try {
    const userId = Number(req.user.id);
    const result = await query(
      `SELECT id, user_id, title, content, is_read, created_at
       FROM dbo.notifications
       WHERE user_id = @user_id
       ORDER BY created_at DESC`,
      { user_id: userId }
    );

    const unreadResult = await query(
      `SELECT COUNT(*) AS unread_count
       FROM dbo.notifications
       WHERE user_id = @user_id AND is_read = 0`,
      { user_id: userId }
    );

    return res.json({
      data: result.recordset,
      unread_count: unreadResult.recordset[0].unread_count
    });
  } catch (error) {
    return res.status(500).json({ message: 'Cannot load notifications', error: error.message });
  }
}

async function markNotificationRead(req, res) {
  try {
    const userId = Number(req.user.id);
    const notificationId = Number(req.params.id);

    const updated = await query(
      `UPDATE dbo.notifications
       SET is_read = 1
       OUTPUT INSERTED.id, INSERTED.user_id, INSERTED.title, INSERTED.content, INSERTED.is_read, INSERTED.created_at
       WHERE id = @id AND user_id = @user_id`,
      { id: notificationId, user_id: userId }
    );

    if (!updated.recordset.length) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    return res.json({ message: 'Notification marked as read', notification: updated.recordset[0] });
  } catch (error) {
    return res.status(500).json({ message: 'Cannot update notification', error: error.message });
  }
}

async function markAllNotificationsRead(req, res) {
  try {
    const userId = Number(req.user.id);
    await query(
      `UPDATE dbo.notifications
       SET is_read = 1
       WHERE user_id = @user_id AND is_read = 0`,
      { user_id: userId }
    );

    return res.json({ message: 'All notifications marked as read' });
  } catch (error) {
    return res.status(500).json({ message: 'Cannot update notifications', error: error.message });
  }
}

module.exports = {
  getMyNotifications,
  markNotificationRead,
  markAllNotificationsRead
};
