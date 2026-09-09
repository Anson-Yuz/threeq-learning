'use strict';

const { BOOKING_STATUS, BOOKING_SOURCE, NOTIFICATION_DELIVERY_STATUS } = require('../domain/constants');

function firstRow(result) {
  const rows = Array.isArray(result) ? result[0] : result;
  return Array.isArray(rows) && rows.length ? rows[0] : null;
}

function allRows(result) {
  const rows = Array.isArray(result) ? result[0] : result;
  return Array.isArray(rows) ? rows : [];
}

class BookingRepository {
  constructor({ pool }) {
    if (!pool || typeof pool.execute !== 'function') throw new TypeError('pool.execute is required');
    this.pool = pool;
  }

  async lockSession(sessionId, connection) {
    return firstRow(await connection.execute(
      `SELECT
         s.id, s.session_date, s.start_at, s.end_at, s.course_id,
         s.class_type_id, ct.code AS class_type_code,
         s.teacher_id, t.user_id AS teacher_user_id,
         s.classroom_id, s.min_students, s.capacity, s.booked_count,
         s.lifecycle_status, s.formation_status, s.formation_check_at,
         s.cancel_lock_at, s.booking_close_at, s.formation_decided_at,
         s.cancel_reason, s.cancelled_at, s.version,
         c.name AS course_name
       FROM class_sessions s
       JOIN class_types ct ON ct.id = s.class_type_id
       JOIN teachers t ON t.id = s.teacher_id
       JOIN courses c ON c.id = s.course_id
       WHERE s.id = ?
       LIMIT 1
       FOR UPDATE`,
      [sessionId]
    ));
  }

  async lockUser(userId, connection) {
    return firstRow(await connection.execute(
      'SELECT id, status FROM users WHERE id = ? LIMIT 1 FOR UPDATE',
      [userId]
    ));
  }

  async updateLifecycleStatus(sessionId, lifecycleStatus, connection) {
    const [result] = await connection.execute(
      'UPDATE class_sessions SET lifecycle_status = ?, version = version + 1 WHERE id = ?',
      [lifecycleStatus, sessionId]
    );
    return result.affectedRows === 1;
  }

  async countConfirmedBookings(sessionId, connection) {
    const row = firstRow(await connection.execute(
      `SELECT COUNT(*) AS confirmed_count
       FROM bookings
       WHERE session_id = ? AND status = ?`,
      [sessionId, BOOKING_STATUS.CONFIRMED]
    ));
    return Number(row ? row.confirmed_count : 0);
  }

  async lockConfirmedBookings(sessionId, connection) {
    return allRows(await connection.execute(
      `SELECT id, user_id
       FROM bookings
       WHERE session_id = ? AND status = ?
       ORDER BY id
       FOR UPDATE`,
      [sessionId, BOOKING_STATUS.CONFIRMED]
    ));
  }

  async setFormationFormed(sessionId, decidedAt, authoritativeCount, connection) {
    const [result] = await connection.execute(
      `UPDATE class_sessions
       SET formation_status = 'formed',
           formation_decided_at = ?,
           booked_count = ?,
           version = version + 1
       WHERE id = ? AND lifecycle_status IN ('open','in_progress','finished') AND formation_status = 'pending'`,
      [decidedAt, authoritativeCount, sessionId]
    );
    return result.affectedRows === 1;
  }

  async cancelForInsufficientStudents(sessionId, cancelledAt, connection) {
    const [result] = await connection.execute(
      `UPDATE class_sessions
       SET lifecycle_status = 'cancelled',
           formation_status = 'failed',
           formation_decided_at = ?,
           cancel_reason = 'insufficient_students',
           cancelled_at = ?,
           booked_count = 0,
           version = version + 1
       WHERE id = ? AND lifecycle_status IN ('open','in_progress','finished') AND formation_status = 'pending'`,
      [cancelledAt, cancelledAt, sessionId]
    );
    return result.affectedRows === 1;
  }

  async markConfirmedBookingsSystemCancelled(sessionId, cancelledAt, connection) {
    const [result] = await connection.execute(
      `UPDATE bookings
       SET status = 'system_cancelled',
           cancelled_at = ?,
           cancel_reason = 'insufficient_students',
           operator_user_id = NULL
       WHERE session_id = ? AND status = 'confirmed'`,
      [cancelledAt, sessionId]
    );
    return result.affectedRows;
  }

  async findConfirmedBooking(sessionId, userId, connection) {
    return firstRow(await connection.execute(
      `SELECT id, session_id, user_id, status, source, created_at
       FROM bookings
       WHERE session_id = ? AND user_id = ? AND status = ?
       LIMIT 1`,
      [sessionId, userId, BOOKING_STATUS.CONFIRMED]
    ));
  }

  async findStudentTimeConflict(userId, sessionId, startAt, endAt, connection) {
    return firstRow(await connection.execute(
      `SELECT b.id AS booking_id, s.id AS session_id, s.start_at, s.end_at
       FROM bookings b
       JOIN class_sessions s ON s.id = b.session_id
       WHERE b.user_id = ?
         AND b.status = 'confirmed'
         AND s.id <> ?
         AND s.lifecycle_status <> 'cancelled'
         AND s.start_at < ?
         AND s.end_at > ?
       LIMIT 1
       FOR UPDATE`,
      [userId, sessionId, endAt, startAt]
    ));
  }

  async insertConfirmedBooking({ sessionId, userId }, connection) {
    const [result] = await connection.execute(
      `INSERT INTO bookings (session_id, user_id, status, source)
       VALUES (?, ?, ?, ?)`,
      [sessionId, userId, BOOKING_STATUS.CONFIRMED, BOOKING_SOURCE.STUDENT]
    );
    return result.insertId;
  }

  async setBookedCount(sessionId, count, connection) {
    const [result] = await connection.execute(
      `UPDATE class_sessions
       SET booked_count = ?, version = version + 1
       WHERE id = ?`,
      [count, sessionId]
    );
    return result.affectedRows === 1;
  }

  async insertNotification({ userId, sessionId, type, channel, payload, dedupeKey }, connection) {
    const [result] = await connection.execute(
      `INSERT INTO notifications
         (user_id, session_id, type, channel, delivery_status, payload, dedupe_key)
       VALUES (?, ?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id)`,
      [
        userId,
        sessionId,
        type,
        channel,
        NOTIFICATION_DELIVERY_STATUS.PENDING,
        JSON.stringify(payload),
        dedupeKey
      ]
    );
    return result.insertId;
  }

  async insertOperationLog({ actorType, operatorUserId = null, action, entityType, entityId, before = null, after = null, reason = null }, connection) {
    const [result] = await connection.execute(
      `INSERT INTO operation_logs
         (actor_type, operator_user_id, action, entity_type, entity_id, before_json, after_json, reason)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        actorType,
        operatorUserId,
        action,
        entityType,
        String(entityId),
        before === null ? null : JSON.stringify(before),
        after === null ? null : JSON.stringify(after),
        reason
      ]
    );
    return result.insertId;
  }

  async findIdempotencyForUpdate({ userId, scope, key }, connection) {
    return firstRow(await connection.execute(
      `SELECT id, user_id, scope, idempotency_key, request_hash, state,
              response_status, response_body, expires_at
       FROM idempotency_keys
       WHERE user_id = ? AND scope = ? AND idempotency_key = ?
       LIMIT 1
       FOR UPDATE`,
      [userId, scope, key]
    ));
  }

  async reserveIdempotency({ userId, scope, key, requestHash, expiresAt }, connection) {
    try {
      await connection.execute(
        `INSERT INTO idempotency_keys
           (user_id, scope, idempotency_key, request_hash, state, expires_at)
         VALUES (?, ?, ?, ?, 'in_progress', ?)`,
        [userId, scope, key, requestHash, expiresAt]
      );
      return Object.freeze({ created: true, record: null });
    } catch (error) {
      if (!(error && (error.code === 'ER_DUP_ENTRY' || error.errno === 1062))) throw error;
      const record = firstRow(await connection.execute(
        `SELECT id, user_id, scope, idempotency_key, request_hash, state,
                response_status, response_body, expires_at
         FROM idempotency_keys
         WHERE user_id = ? AND scope = ? AND idempotency_key = ?
         LIMIT 1
         FOR UPDATE`,
        [userId, scope, key]
      ));
      return Object.freeze({ created: false, record });
    }
  }

  async completeIdempotency({ userId, scope, key, responseStatus, responseBody }, connection) {
    const [result] = await connection.execute(
      `UPDATE idempotency_keys
       SET state = 'completed', response_status = ?, response_body = ?
       WHERE user_id = ? AND scope = ? AND idempotency_key = ? AND state = 'in_progress'`,
      [responseStatus, JSON.stringify(responseBody), userId, scope, key]
    );
    return result.affectedRows === 1;
  }
}

module.exports = Object.freeze({ BookingRepository });
