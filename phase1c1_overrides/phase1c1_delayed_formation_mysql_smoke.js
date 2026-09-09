'use strict';

const mysql = require('mysql2/promise');
const { BookingRepository } = require('../backend/booking/bookingRepository');
const { FormationService } = require('../backend/booking/formationService');
const { BookingService } = require('../backend/booking/bookingService');

let passCount = 0;
let failCount = 0;

function pass(label) { passCount += 1; console.log(`PASS | ${label}`); }
function fail(label, detail = '') { failCount += 1; console.error(`FAIL | ${label}${detail ? ` | ${detail}` : ''}`); }
function assertCheck(condition, label, detail = '') { if (condition) pass(label); else fail(label, detail); }
function mysqlDate(value) { return new Date(value).toISOString().slice(0, 23).replace('T', ' '); }
function plusMinutes(value, minutes) { return new Date(new Date(value).getTime() + minutes * 60_000); }
function auth(userId) { return { user: { id: userId, status: 'active' }, roles: ['student'], teacher: null }; }
function resultCode(settled) { return settled.status === 'rejected' && settled.reason ? settled.reason.code : null; }

async function row(pool, sql, params = []) {
  const [rows] = await pool.execute(sql, params);
  return rows[0] || null;
}

async function count(pool, sql, params = []) {
  const value = await row(pool, sql, params);
  return Number(Object.values(value)[0]);
}

async function main() {
  const pool = mysql.createPool({
    host: process.env.DB_HOST || '127.0.0.1',
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || 'root',
    database: process.env.DB_NAME || 'hubeier_phase1c1_smoke',
    timezone: 'Z',
    charset: 'utf8mb4',
    waitForConnections: true,
    connectionLimit: 12
  });

  try {
    const [versionRows] = await pool.execute('SELECT VERSION() AS version, @@transaction_isolation AS isolation');
    console.log(`MYSQL_VERSION=${versionRows[0].version}`);
    console.log(`TRANSACTION_ISOLATION=${versionRows[0].isolation}`);
    assertCheck(/^8\./.test(versionRows[0].version), 'real MySQL 8.x instance is running');
    assertCheck(String(versionRows[0].isolation).toUpperCase().includes('REPEATABLE'), 'delayed formation smoke runs under REPEATABLE READ');

    await pool.execute(`INSERT INTO users (id, openid, real_name, status) VALUES (9900, 'phase1c1-teacher', 'Phase1C1 Teacher', 'active')`);
    await pool.execute(`INSERT INTO user_roles (user_id, role_code) VALUES (9900, 'teacher')`);
    await pool.execute(`INSERT INTO teachers (id, user_id, name, status) VALUES (9900, 9900, 'Phase1C1 Teacher', 'active')`);
    await pool.execute(`INSERT INTO courses (id, name, enabled) VALUES (9900, 'Phase1C1 Course', 1)`);

    for (let id = 2001; id <= 2020; id += 1) {
      await pool.execute(`INSERT INTO users (id, openid, real_name, status) VALUES (?, ?, ?, 'active')`, [id, `phase1c1-student-${id}`, `Student ${id}`]);
      await pool.execute(`INSERT INTO user_roles (user_id, role_code) VALUES (?, 'student')`, [id]);
    }

    async function createSession({ id, startAt, lifecycle = 'open', formation = 'pending', bookedCount = 0, cancelReason = null, cancelledAt = null }) {
      const start = new Date(startAt);
      const end = plusMinutes(start, 45);
      const formationCheck = plusMinutes(start, -60);
      const cancelLock = plusMinutes(start, -50);
      await pool.execute(
        `INSERT INTO class_sessions (
           id, session_date, time_slot_id, start_at, end_at, course_id, class_type_id,
           teacher_id, classroom_id, min_students, capacity, booked_count,
           lifecycle_status, formation_status, formation_check_at, cancel_lock_at,
           booking_close_at, formation_decided_at, cancel_reason, cancelled_at, generation_key
         ) VALUES (?, ?, NULL, ?, ?, 9900, 1, 9900, 1, 3, 18, ?, ?, ?, ?, ?, ?, NULL, ?, ?, ?)`,
        [
          id, mysqlDate(start).slice(0, 10), mysqlDate(start), mysqlDate(end), bookedCount,
          lifecycle, formation, mysqlDate(formationCheck), mysqlDate(cancelLock), mysqlDate(start),
          cancelReason, cancelledAt ? mysqlDate(cancelledAt) : null, `phase1c1-delayed-${id}`
        ]
      );
    }

    async function seedConfirmed(sessionId, userIds) {
      for (const userId of userIds) {
        await pool.execute(`INSERT INTO bookings (session_id, user_id, status, source) VALUES (?, ?, 'confirmed', 'student')`, [sessionId, userId]);
      }
      await pool.execute(`UPDATE class_sessions SET booked_count=? WHERE id=?`, [userIds.length, sessionId]);
    }

    function service(nowValue) {
      const repository = new BookingRepository({ pool });
      const formationService = new FormationService({ repository });
      return new BookingService({ repository, formationService, now: () => new Date(nowValue) });
    }

    // A. open+pending reaches exact start with only 2 confirmed students.
    await createSession({ id: 6001, startAt: '2026-09-20T11:00:00.000Z' });
    await seedConfirmed(6001, [2001, 2002]);
    const a = await Promise.allSettled([
      service('2026-09-20T11:00:00.000Z').createBooking({ authContext: auth(2003), sessionId: '6001' })
    ]);
    assertCheck(resultCode(a[0]) === 'SESSION_CANCELLED', 'A booking request returns SESSION_CANCELLED after delayed insufficient decision');
    const aSession = await row(pool, `SELECT lifecycle_status, formation_status, cancel_reason, booked_count FROM class_sessions WHERE id=6001`);
    assertCheck(aSession.lifecycle_status === 'cancelled' && aSession.formation_status === 'failed' && aSession.cancel_reason === 'insufficient_students', 'A final session is cancelled+failed+insufficient_students, never in_progress+pending');
    assertCheck(aSession.booked_count === 0, 'A booked_count becomes 0');
    assertCheck(await count(pool, `SELECT COUNT(*) c FROM bookings WHERE session_id=6001 AND status='system_cancelled'`) === 2, 'A original confirmed bookings become system_cancelled');
    assertCheck(await count(pool, `SELECT COUNT(*) c FROM bookings WHERE session_id=6001 AND user_id=2003`) === 0, 'A current third booking is not created');

    // B. open+pending reaches exact start with 3 confirmed students.
    await createSession({ id: 6002, startAt: '2026-09-21T11:00:00.000Z' });
    await seedConfirmed(6002, [2004, 2005, 2006]);
    const b1 = await Promise.allSettled([
      service('2026-09-21T11:00:00.000Z').createBooking({ authContext: auth(2007), sessionId: '6002' })
    ]);
    assertCheck(resultCode(b1[0]) === 'SESSION_STARTED', 'B current booking is rejected because exact start has been reached');
    const bSession = await row(pool, `SELECT lifecycle_status, formation_status, formation_decided_at, booked_count FROM class_sessions WHERE id=6002`);
    assertCheck(bSession.lifecycle_status === 'in_progress' && bSession.formation_status === 'formed' && bSession.formation_decided_at !== null, 'B final session is in_progress+formed with formation_decided_at');
    assertCheck(bSession.booked_count === 3, 'B authoritative booked_count remains 3');
    const b2 = await Promise.allSettled([
      service('2026-09-21T11:00:00.000Z').createBooking({ authContext: auth(2008), sessionId: '6002' })
    ]);
    assertCheck(resultCode(b2[0]) === 'SESSION_STARTED', 'B repeated old request remains rejected as started');
    assertCheck(await count(pool, `SELECT COUNT(*) c FROM operation_logs WHERE entity_type='class_session' AND entity_id='6002' AND action='formation_formed'`) === 1, 'B formation_formed operation log is written exactly once');

    // C. cancelled+pending+admin_cancelled is authoritative and must not be re-decided.
    await createSession({
      id: 6003,
      startAt: '2026-09-22T11:00:00.000Z',
      lifecycle: 'cancelled',
      formation: 'pending',
      cancelReason: 'admin_cancelled',
      cancelledAt: '2026-09-22T09:30:00.000Z'
    });
    const c = await Promise.allSettled([
      service('2026-09-22T11:00:00.000Z').createBooking({ authContext: auth(2009), sessionId: '6003' })
    ]);
    assertCheck(resultCode(c[0]) === 'SESSION_CANCELLED', 'C old booking request returns SESSION_CANCELLED');
    const cSession = await row(pool, `SELECT lifecycle_status, formation_status, cancel_reason FROM class_sessions WHERE id=6003`);
    assertCheck(cSession.lifecycle_status === 'cancelled' && cSession.formation_status === 'pending' && cSession.cancel_reason === 'admin_cancelled', 'C cancelled+pending+admin_cancelled remains unchanged');
    assertCheck(await count(pool, `SELECT COUNT(*) c FROM operation_logs WHERE entity_type='class_session' AND entity_id='6003' AND action IN ('formation_formed','session_cancelled_insufficient_students')`) === 0, 'C produces no false formation audit record');
    assertCheck(await count(pool, `SELECT COUNT(*) c FROM notifications WHERE session_id=6003 AND type='insufficient_students_cancelled'`) === 0, 'C produces no insufficient cancellation outbox');

    // D. finished+pending with >= minimum must still resolve delayed formation.
    await createSession({ id: 6004, startAt: '2026-09-23T10:00:00.000Z', lifecycle: 'finished', formation: 'pending' });
    await seedConfirmed(6004, [2010, 2011, 2012]);
    const d = await Promise.allSettled([
      service('2026-09-23T11:00:00.000Z').createBooking({ authContext: auth(2013), sessionId: '6004' })
    ]);
    assertCheck(resultCode(d[0]) === 'SESSION_STARTED', 'D finished session still rejects booking');
    const dSession = await row(pool, `SELECT lifecycle_status, formation_status, formation_decided_at FROM class_sessions WHERE id=6004`);
    assertCheck(dSession.lifecycle_status === 'finished' && dSession.formation_status === 'formed' && dSession.formation_decided_at !== null, 'D delayed finished+pending resolves to finished+formed');
    assertCheck(await count(pool, `SELECT COUNT(*) c FROM operation_logs WHERE entity_type='class_session' AND entity_id='6004' AND action='formation_formed'`) === 1, 'D formation_formed audit is written exactly once');

    console.log(`SUMMARY | pass=${passCount} fail=${failCount}`);
    if (failCount > 0) process.exitCode = 1;
  } finally {
    await pool.end();
  }
}

main().catch((error) => {
  console.error('FATAL | phase1c1 delayed formation mysql smoke crashed');
  console.error(error && error.stack ? error.stack : error);
  process.exitCode = 1;
});
