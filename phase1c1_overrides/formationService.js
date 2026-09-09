'use strict';

const {
  CLASS_TYPE,
  LIFECYCLE_STATUS,
  FORMATION_STATUS,
  NOTIFICATION_CHANNEL,
  NOTIFICATION_TYPE,
  OPERATION_ACTOR_TYPE
} = require('../domain/constants');

function toDate(value) {
  return value instanceof Date ? value : new Date(value);
}

function toIso(value) {
  return toDate(value).toISOString();
}

class FormationService {
  constructor({ repository }) {
    this.repository = repository;
  }

  async reloadAuthoritativeSession(sessionId, connection, fallbackSession) {
    const authoritative = await this.repository.lockSession(sessionId, connection);
    return authoritative || fallbackSession;
  }

  async ensureFormationDecision({ connection, session, now }) {
    if (!connection) throw new TypeError('connection is required');
    if (!session) throw new TypeError('session is required');
    const nowDate = toDate(now);

    // A cancelled or draft session must never receive a new formation decision.
    // This guard intentionally runs before private/group normalization so an old
    // request cannot mutate formation state or create misleading system audit rows.
    if (
      session.lifecycle_status === LIFECYCLE_STATUS.CANCELLED ||
      session.lifecycle_status === LIFECYCLE_STATUS.DRAFT
    ) {
      return Object.freeze({ session, decision: session.formation_status });
    }

    if (session.class_type_code === CLASS_TYPE.PRIVATE.code) {
      if (session.formation_status === FORMATION_STATUS.NOT_REQUIRED) {
        return Object.freeze({ session, decision: FORMATION_STATUS.NOT_REQUIRED });
      }
      if (session.formation_status !== FORMATION_STATUS.PENDING) {
        return Object.freeze({ session, decision: session.formation_status });
      }

      const [result] = await connection.execute(
        `UPDATE class_sessions
         SET formation_status = 'not_required', formation_decided_at = NULL, version = version + 1
         WHERE id = ? AND formation_status = 'pending'`,
        [session.id]
      );
      if (result.affectedRows !== 1) {
        const authoritative = await this.reloadAuthoritativeSession(session.id, connection, session);
        return Object.freeze({ session: authoritative, decision: authoritative.formation_status });
      }
      session.formation_status = FORMATION_STATUS.NOT_REQUIRED;
      session.formation_decided_at = null;
      return Object.freeze({ session, decision: FORMATION_STATUS.NOT_REQUIRED });
    }

    if (session.formation_status !== FORMATION_STATUS.PENDING) {
      return Object.freeze({ session, decision: session.formation_status });
    }
    if (nowDate.getTime() < toDate(session.formation_check_at).getTime()) {
      return Object.freeze({ session, decision: FORMATION_STATUS.PENDING });
    }

    // Delayed decisions remain authoritative for open / in_progress / finished.
    // BookingService holds the session row lock before entering this method.
    const confirmedCount = await this.repository.countConfirmedBookings(session.id, connection);
    if (confirmedCount >= Number(session.min_students)) {
      const formed = await this.repository.setFormationFormed(session.id, nowDate, confirmedCount, connection);
      if (!formed) {
        const authoritative = await this.reloadAuthoritativeSession(session.id, connection, session);
        return Object.freeze({ session: authoritative, decision: authoritative.formation_status, confirmedCount });
      }

      const before = { formation_status: FORMATION_STATUS.PENDING, booked_count: Number(session.booked_count) };
      session.formation_status = FORMATION_STATUS.FORMED;
      session.formation_decided_at = nowDate;
      session.booked_count = confirmedCount;
      await this.repository.insertOperationLog({
        actorType: OPERATION_ACTOR_TYPE.SYSTEM,
        action: 'formation_formed',
        entityType: 'class_session',
        entityId: session.id,
        before,
        after: { formation_status: FORMATION_STATUS.FORMED, booked_count: confirmedCount },
        reason: null
      }, connection);
      return Object.freeze({ session, decision: FORMATION_STATUS.FORMED, confirmedCount });
    }

    const before = {
      lifecycle_status: session.lifecycle_status,
      formation_status: session.formation_status,
      booked_count: Number(session.booked_count)
    };
    const cancelled = await this.repository.cancelForInsufficientStudents(session.id, nowDate, connection);
    if (!cancelled) {
      const authoritative = await this.reloadAuthoritativeSession(session.id, connection, session);
      return Object.freeze({ session: authoritative, decision: authoritative.formation_status, confirmedCount });
    }

    // Only after the authoritative session transition succeeds may the related
    // booking mutations, outbox records and audit log be written.
    const affectedBookings = await this.repository.lockConfirmedBookings(session.id, connection);
    await this.repository.markConfirmedBookingsSystemCancelled(session.id, nowDate, connection);
    const payload = Object.freeze({
      session_id: String(session.id),
      course_name: session.course_name,
      start_at: toIso(session.start_at),
      end_at: toIso(session.end_at),
      cancel_reason: 'insufficient_students'
    });
    for (const booking of affectedBookings) {
      for (const channel of [NOTIFICATION_CHANNEL.IN_APP, NOTIFICATION_CHANNEL.WECHAT_SUBSCRIBE]) {
        await this.repository.insertNotification({
          userId: booking.user_id,
          sessionId: session.id,
          type: NOTIFICATION_TYPE.INSUFFICIENT_STUDENTS_CANCELLED,
          channel,
          payload,
          dedupeKey: `insufficient_students_cancelled:${session.id}:student:${booking.user_id}:${channel}`
        }, connection);
      }
    }
    if (session.teacher_user_id !== null && session.teacher_user_id !== undefined) {
      for (const channel of [NOTIFICATION_CHANNEL.IN_APP, NOTIFICATION_CHANNEL.WECHAT_SUBSCRIBE]) {
        await this.repository.insertNotification({
          userId: session.teacher_user_id,
          sessionId: session.id,
          type: NOTIFICATION_TYPE.INSUFFICIENT_STUDENTS_CANCELLED,
          channel,
          payload,
          dedupeKey: `insufficient_students_cancelled:${session.id}:teacher:${session.teacher_user_id}:${channel}`
        }, connection);
      }
    }
    await this.repository.insertOperationLog({
      actorType: OPERATION_ACTOR_TYPE.SYSTEM,
      action: 'session_cancelled_insufficient_students',
      entityType: 'class_session',
      entityId: session.id,
      before,
      after: {
        lifecycle_status: LIFECYCLE_STATUS.CANCELLED,
        formation_status: FORMATION_STATUS.FAILED,
        booked_count: 0,
        cancel_reason: 'insufficient_students'
      },
      reason: 'insufficient_students'
    }, connection);

    session.lifecycle_status = LIFECYCLE_STATUS.CANCELLED;
    session.formation_status = FORMATION_STATUS.FAILED;
    session.formation_decided_at = nowDate;
    session.cancel_reason = 'insufficient_students';
    session.cancelled_at = nowDate;
    session.booked_count = 0;
    return Object.freeze({ session, decision: FORMATION_STATUS.FAILED, confirmedCount });
  }
}

module.exports = Object.freeze({ FormationService });
