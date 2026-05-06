const { query } = require('../config/db');

async function createReport(req, res) {
  try {
    const reporterId = Number(req.user.id);
    const productId = Number(req.body.product_id);
    const reason = (req.body.reason || '').trim();

    if (!productId || !reason) {
      return res.status(400).json({ message: 'product_id and reason are required' });
    }

    const inserted = await query(
      `INSERT INTO dbo.reports (product_id, reporter_id, reason, [status])
       OUTPUT INSERTED.id, INSERTED.product_id, INSERTED.reporter_id, INSERTED.reason, INSERTED.[status], INSERTED.created_at
       VALUES (@product_id, @reporter_id, @reason, 'pending')`,
      {
        product_id: productId,
        reporter_id: reporterId,
        reason
      }
    );

    return res.status(201).json({ message: 'Report submitted', report: inserted.recordset[0] });
  } catch (error) {
    return res.status(500).json({ message: 'Cannot create report', error: error.message });
  }
}

async function getReports(req, res) {
  try {
    const result = await query(
      `SELECT
          r.id,
          r.product_id,
          r.reporter_id,
          r.reason,
          r.[status],
          r.created_at,
          p.title AS product_title,
          u.name AS reporter_name,
          u.email AS reporter_email
       FROM dbo.reports r
       LEFT JOIN dbo.products p ON p.id = r.product_id
       LEFT JOIN dbo.users u ON u.id = r.reporter_id
       ORDER BY r.created_at DESC`
    );

    return res.json({ data: result.recordset });
  } catch (error) {
    return res.status(500).json({ message: 'Cannot load reports', error: error.message });
  }
}

async function updateReportStatus(req, res) {
  try {
    const reportId = Number(req.params.id);
    const status = String(req.body.status || '').toLowerCase().trim();

    if (!reportId) {
      return res.status(400).json({ message: 'Invalid report id' });
    }

    if (!['pending', 'reviewing', 'resolved', 'rejected'].includes(status)) {
      return res.status(400).json({ message: 'Invalid status value' });
    }

    const updated = await query(
      `UPDATE dbo.reports
       SET [status] = @status
       OUTPUT INSERTED.id, INSERTED.product_id, INSERTED.reporter_id, INSERTED.reason, INSERTED.[status], INSERTED.created_at
       WHERE id = @id`,
      { id: reportId, status }
    );

    if (!updated.recordset.length) {
      return res.status(404).json({ message: 'Report not found' });
    }

    return res.json({ message: 'Report status updated', report: updated.recordset[0] });
  } catch (error) {
    return res.status(500).json({ message: 'Cannot update report', error: error.message });
  }
}

module.exports = {
  createReport,
  getReports,
  updateReportStatus
};
