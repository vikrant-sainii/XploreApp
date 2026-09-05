# CampusNode API Endpoints Documentation

Comprehensive documentation of all backend REST API endpoints in the CampusNode platform.

**Base URL:**
- Development: `http://localhost:5000/api`
- Production: `https://<domain>/api`

**Authentication:**
- Authentication is handled via HTTP-Only JWT cookies or `Authorization: Bearer <token>` header.
- Roles: `student` / `member`, `club` / `club_account`, `facultyCoordinator`, `central_organizer` / `institutional`, `paymentAdmin`, `admin`.

---

## Table of Contents
1. [Authentication (`/api/auth`)](#1-authentication-apiauth)
2. [User Profile & Identity (`/api/users`)](#2-user-profile--identity-apiusers)
3. [Events Management & Participation (`/api/events`)](#3-events-management--participation-apievents)
4. [Team Registrations & Invitations (`/api/teams`)](#4-team-registrations--invitations-apiteams)
5. [Payments & Financial Verification (`/api/payment`)](#5-payments--financial-verification-apipayment)
6. [Clubs & Showcases (`/api/clubs`)](#6-clubs--showcases-apiclubs)
7. [Club Memberships & Leadership (`/api/club-members`)](#7-club-memberships--leadership-apiclub-members)
8. [Central Organizer & Institutional Portals (`/api/central-organizer`)](#8-central-organizer--institutional-portals-apicentral-organizer)
9. [Event Staff Delegations (`/api/event-staff`)](#9-event-staff-delegations-apievent-staff)
10. [High-Throughput QR Scanner & Offline Sync (`/api/scanner` & `/api/participation`)](#10-high-throughput-qr-scanner--offline-sync-apiscanner--apiparticipation)
11. [Event Feedback & AI Analytics (`/api/feedback`)](#11-event-feedback--ai-analytics-apifeedback)
12. [Certificates Engine (`/api/certificates`)](#12-certificates-engine-apicertificates)
13. [Notifications & Web Push (`/api/notifications` & `/api/push`)](#13-notifications--web-push-apinotifications--apipush)
14. [Lost & Found Portal (`/api/lost-found` & `/api/admin/lost-found`)](#14-lost--found-portal-apilost-found--apiadminlost-found)
15. [Venues & Blackouts (`/api/venues`)](#15-venues--blackouts-apivenues)
16. [Administration (`/api/admin`)](#16-administration-apiadmin)
17. [Export Center (`/api/export-center`)](#17-export-center-apiexport-center)
18. [System, Health & Cryptographic Keys](#18-system-health--cryptographic-keys)

---

## 1. Authentication (`/api/auth`)

| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| POST | `/register/student` | Register a new student account | No |
| POST | `/register/external` | Register an external participant | No |
| POST | `/login` or `/login/student` | Authenticate student/external user | No |
| POST | `/login/admin` | Authenticate admin, faculty, or institutional account | No |
| POST | `/login/external` | Authenticate external participant account | No |
| POST | `/verify-2fa` | Verify 2FA OTP for privileged accounts | No |
| GET | `/verify-email/:token` | Verify student email address | No |
| POST | `/forgot-password` | Request password reset token via email | No |
| POST | `/reset-password/:token` | Set new password using email token | No |
| POST | `/change-password` | Change password for logged-in user | Yes |
| POST | `/logout` | Clear authentication session/cookies | Yes |

---

## 2. User Profile & Identity (`/api/users`)

| Method | Endpoint | Description | Auth / Permissions |
| :--- | :--- | :--- | :--- |
| GET | `/me` | Get current logged-in user profile & active roles | Authenticated |
| PUT | `/:role/:id` | Update profile info (roll, branch, bio, social links) | Self or Admin |
| GET | `/search` | Search verified students by name, email, or roll no | Authenticated |
| GET | `/lookup/:rollNo` | Look up student public info by roll number | Authenticated |
| POST | `/profile-photo` | Upload user profile avatar | Authenticated |
| DELETE | `/profile-photo` | Remove custom profile avatar | Authenticated |

---

## 3. Events Management & Participation (`/api/events`)

| Method | Endpoint | Description | Auth / Permissions |
| :--- | :--- | :--- | :--- |
| GET | `/` | Get all published events (supports filtering, search, pagination) | Public |
| GET | `/:id` | Get single event details by ID or Slug | Public (Unpublished: Creator/Admin/Faculty) |
| GET | `/calendar` | Fetch published & upcoming events for calendar view | `EVENT_VIEW` |
| GET | `/conflicts` | Detect venue and time slot booking conflicts | `EVENT_VIEW` |
| GET | `/club/:clubId` | Get published events organized by a club | Public |
| GET | `/club-co/:id` | Get events created by a specific coordinator | Creator or Admin |
| GET | `/club-manage/:clubId` | Get all events (drafts, pending, published) for club | Club Coordinator / Head |
| GET | `/club-manage/:clubId/export` | Export event attendance & revenue summaries for a club | Club Coordinator / Head |
| GET | `/user/:userId` | Get list of event registrations for a student | Self or Admin / Club |
| POST | `/` | Create a new event proposal (PENDING review) | `EVENT_CREATE` |
| POST | `/upload` | Upload event poster banner image | `EVENT_CREATE` |
| PUT | `/:id` | Update event information, rules, and settings | `EVENT_UPDATE` |
| PUT | `/:id/reschedule` | Reschedule event date, time, or venue | `EVENT_UPDATE` |
| DELETE | `/:id` | Delete event proposal | `EVENT_DELETE` |
| PUT | `/:id/review` | Approve (`PUBLISHED`) or Reject (`REJECTED`) event | `EVENT_APPROVE` (Faculty / Admin) |
| POST | `/:id/register` | Register for an event (Free or Manual payment) | `REGISTRATION_CREATE` |
| DELETE | `/:id/register` | Cancel registration / deregister | `REGISTRATION_CANCEL` |
| GET | `/:id/registrations` | Get list of registered participants | Club Lead / Faculty / Admin |
| POST | `/:id/check-in` | Mark attendance via scanned QR ticket | `EVENT_ATTENDANCE` |
| POST | `/:id/attendance-manual` | Manually mark attendee attendance by participation ID | `EVENT_ATTENDANCE` |
| PATCH | `/:id/feature` | Toggle featured event spotlight status | Club Lead / Event Manager |

---

## 4. Team Registrations & Invitations (`/api/teams`)

| Method | Endpoint | Description | Auth / Permissions |
| :--- | :--- | :--- | :--- |
| POST | `/` | Create team and register leader for team event | `TEAM_CREATE` (Student/External) |
| POST | `/invitations/:id/accept` | Accept team invitation notification | Authenticated Invitee |
| POST | `/invitations/:id/decline` | Decline team invitation notification | Authenticated Invitee |
| POST | `/:id/invite` | Leader invites another teammate by student ID | Team Leader |
| GET | `/event/:eventId/lookup-leader` | Search team by leader name, roll no, or team name | Authenticated |
| GET | `/:id` | Get complete team roster and member details | Authenticated |

---

## 5. Payments & Financial Verification (`/api/payment`)

| Method | Endpoint | Description | Auth / Permissions |
| :--- | :--- | :--- | :--- |
| PUT | `/:participationId/review` | Review manual payment (`APPROVED`, `REJECTED`, `NEED_MORE_DETAILS`) | `PAYMENT_VERIFY` (Club/Admin) |
| GET | `/event/:eventId/registrations` | View paid event registrations with transaction IDs | `PAYMENT_VIEW` |
| GET | `/event/:eventId/stats` | View financial revenue and ticket sales stats | Club Head / Faculty / Admin |
| PUT | `/:participationId/update-details` | Participant updates/re-submits transaction proof | Participant (Self) |

---

## 6. Clubs & Showcases (`/api/clubs`)

| Method | Endpoint | Description | Auth / Permissions |
| :--- | :--- | :--- | :--- |
| GET | `/` | List all active student clubs | Public |
| GET | `/leaderboard` | Club activity, event, and points leaderboard | Public |
| GET | `/:id` | Get club profile, leads, events, announcements & gallery | Public |
| PUT | `/:id` | Update club description, social links, logo, and metadata | `CLUB_UPDATE` |
| POST | `/:id/banner` | Upload club banner cover image | `CLUB_UPDATE` |
| POST | `/:id/announcements` | Publish a new club announcement | `CLUB_UPDATE` |
| PUT | `/:id/announcements/:announcementId` | Edit club announcement | `CLUB_UPDATE` |
| PATCH | `/:id/announcements/:announcementId/pin` | Pin/unpin announcement to top | `CLUB_UPDATE` |
| DELETE | `/:id/announcements/:announcementId` | Delete announcement | `CLUB_UPDATE` |
| POST | `/:id/achievements` | Add club award / achievement | `CLUB_UPDATE` |
| PUT | `/:id/achievements/:achievementId` | Edit club achievement | `CLUB_UPDATE` |
| DELETE | `/:id/achievements/:achievementId` | Delete club achievement | `CLUB_UPDATE` |
| POST | `/:id/gallery` | Upload showcase photo to club gallery | `CLUB_UPDATE` |
| DELETE | `/:id/gallery/:mediaId` | Delete photo from club gallery | `CLUB_UPDATE` |

---

## 7. Club Memberships & Leadership (`/api/club-members`)

| Method | Endpoint | Description | Auth / Permissions |
| :--- | :--- | :--- | :--- |
| GET | `/:clubId/members` | Get current roster of club leads, coordinators & members | Public |
| GET | `/:clubId/search-students` | Search eligible students to invite into club team | `CLUB_INVITE_MEMBERS` |
| POST | `/:clubId/members` | Add/invite student into club with designated role | `CLUB_INVITE_MEMBERS` |
| POST | `/:clubId/transfer-student-lead` | Transfer Club Head / Lead authority to another student | `CLUB_TRANSFER_LEADERSHIP` |
| PUT | `/members/:membershipId` | Update member role & scanner permissions | `CLUB_ASSIGN_ROLES` |
| DELETE | `/members/:membershipId` | Remove member from club roster | `CLUB_REMOVE_MEMBERS` |

---

## 8. Central Organizer & Institutional Portals (`/api/central-organizer`)

| Method | Endpoint | Description | Auth / Permissions |
| :--- | :--- | :--- | :--- |
| GET | `/events` | List all central institutional events | `central_organizer` / `institutional` |
| POST | `/events` | Create new central event | `central_organizer` / `institutional` |
| PUT | `/events/:eventId` | Update central event details | `central_organizer` / `institutional` |
| DELETE | `/events/:eventId` | Delete central event | `central_organizer` / `institutional` |
| POST | `/events/:eventId/clubs` | Associate/collab with partner clubs | `central_organizer` / `institutional` |
| DELETE | `/events/:eventId/clubs/:clubId` | Disassociate partner club from event | `central_organizer` / `institutional` |
| GET | `/events/:eventId/staff` | List active delegated staff for central event | `central_organizer` / `institutional` |
| POST | `/events/:eventId/staff` | Delegate event staff & assign scanner/ops permissions | `central_organizer` / `institutional` |
| PUT | `/events/:eventId/staff/:staffId` | Modify staff permissions or expiration time | `central_organizer` / `institutional` |
| DELETE | `/events/:eventId/staff/:staffId` | Revoke staff delegation assignment | `central_organizer` / `institutional` |
| GET | `/dashboard-stats` | Analytics for central events & attendance | `central_organizer` / `institutional` |
| GET | `/audit-logs` | View audit trail of actions | `central_organizer` / `institutional` |
| GET | `/students/search` | Search students to delegate as staff | `central_organizer` / `institutional` |

---

## 9. Event Staff Delegations (`/api/event-staff`)

| Method | Endpoint | Description | Auth / Permissions |
| :--- | :--- | :--- | :--- |
| GET | `/my-assignments` | Get all active and pending event staff invitations for current user | Authenticated Student |
| POST | `/invitations/:staffId/accept` | Accept event staff delegation invitation | Authenticated Assignee |
| POST | `/invitations/:staffId/reject` | Reject event staff delegation invitation | Authenticated Assignee |
| GET | `/events/:eventId/overview` | Get event control room overview for authorized staff | Delegated Staff Operator |

---

## 10. High-Throughput QR Scanner & Offline Sync (`/api/scanner` & `/api/participation`)

### Scanner Endpoints (`/api/scanner`)
| Method | Endpoint | Description | Auth / Permissions |
| :--- | :--- | :--- | :--- |
| POST | `/login` | Dedicated scanner terminal login for operators & staff | Operator Credentials |
| GET | `/events` | Get list of assigned events available for scanning | Authenticated Operator |
| GET | `/events/:eventId/offline-package` | Download offline attendance package & cryptographic public keys | Operator / Staff |
| POST | `/sessions` | Start an ONLINE or OFFLINE scanner session | Operator / Staff |
| POST | `/sessions/:sessionId/end` | Close an active scanner session | Session Owner or Admin |
| POST | `/attendance/check-in` | Online real-time QR attendance check-in | Operator / Staff |
| POST | `/attendance/sync` | Batch sync offline attendance scans with conflict resolution | Operator / Staff |
| GET | `/events/:eventId/sync-state` | Fetch current sync delta state & attendance counts | Operator / Staff |
| GET | `/keys/public` or `/keys` | Public keys for cryptographic offline verification | Public |

### Universal Participation Verification (`/api/participation`)
| Method | Endpoint | Description | Auth / Permissions |
| :--- | :--- | :--- | :--- |
| POST | `/verify` | Universal ticket verification endpoint (signed QR & legacy) | `EVENT_ATTENDANCE` |
| PATCH | `/verify/:qrCode` | Verify attendee ticket by QR code string | `EVENT_ATTENDANCE` |

---

## 11. Event Feedback & AI Analytics (`/api/feedback`)

| Method | Endpoint | Description | Auth / Permissions |
| :--- | :--- | :--- | :--- |
| GET | `/pending` | Get attended events awaiting student feedback | Authenticated Attendee |
| GET | `/my-feedback` | Get feedback submitted by the user | Authenticated Attendee |
| POST | `/:eventId` | Submit event rating, feedback & survey responses | Attended Participant |
| GET | `/:eventId/analytics` | View aggregated rating metrics & feedback distribution | Club / Faculty / Admin |
| GET | `/:eventId/ai-reviews` | Get list of generated AI feedback analytical reports | Club / Faculty / Admin |
| POST | `/:eventId/ai-review` | Generate AI review & sentiment insights | Club / Faculty / Admin |
| GET | `/:eventId/ai-reviews/:reviewNumber/pdf` | Export AI event review report as PDF | Club / Faculty / Admin |
| GET | `/:eventId/ai-reviews/:reviewNumber/json` | Get raw AI review data in JSON format | Club / Faculty / Admin |

---

## 12. Certificates Engine (`/api/certificates`)

| Method | Endpoint | Description | Auth / Permissions |
| :--- | :--- | :--- | :--- |
| POST | `/:eventId/template` | Save certificate design template coordinates & styling | `EVENT_CERTIFICATE` (Club/Admin) |
| POST | `/upload-template` | Upload background template image | `EVENT_CERTIFICATE` (Club/Admin) |
| GET | `/:eventId/download` | Render and download customized student certificate (PDF) | Attended Student |

---

## 13. Notifications & Web Push (`/api/notifications` & `/api/push`)

### In-App Notifications (`/api/notifications`)
| Method | Endpoint | Description | Auth / Permissions |
| :--- | :--- | :--- | :--- |
| POST | `/` | Broadcast notification to registered students or entire campus | `NOTIFICATION_CREATE` |
| GET | `/` | Get notifications for current user | `NOTIFICATION_VIEW` |
| GET | `/sent` | Get notifications sent by current club / authority | `NOTIFICATION_VIEW` |
| PUT | `/read-all` | Mark all user notifications as read | `NOTIFICATION_VIEW` |
| PUT | `/:id/read` | Mark specific notification as read | `NOTIFICATION_VIEW` |

### Web Push Notifications (`/api/push`)
| Method | Endpoint | Description | Auth / Permissions |
| :--- | :--- | :--- | :--- |
| GET | `/vapid-public-key` | Get VAPID public key for browser push subscription | Public |
| POST | `/subscribe` | Register browser Web Push subscription | Authenticated |
| POST | `/unsubscribe` | Unregister browser Web Push subscription | Authenticated |

---

## 14. Lost & Found Portal (`/api/lost-found` & `/api/admin/lost-found`)

### Student Portal (`/api/lost-found`)
| Method | Endpoint | Description | Auth / Permissions |
| :--- | :--- | :--- | :--- |
| GET | `/` | Browse reported lost and found items | Authenticated |
| GET | `/my-posts` | List items posted by current user | Authenticated |
| POST | `/` | Report a lost or found item | Authenticated (Non-Blocked) |
| POST | `/upload` | Upload photo of lost/found item | Authenticated |
| GET | `/signature` | Direct upload signature | Authenticated |
| PATCH | `/:id/reunite` | Mark item as reunited with owner | Item Owner / Admin |
| POST | `/:id/claim` | Submit claim request for a found item | Authenticated (Non-Blocked) |
| POST | `/:id/report` | Report fraudulent or spam item post | Authenticated |
| POST | `/:id/report-liar` | Report false claim on an item | Authenticated |

### Moderation & Admin (`/api/admin/lost-found`)
| Method | Endpoint | Description | Auth / Permissions |
| :--- | :--- | :--- | :--- |
| GET | `/all` | View all posts including flagged items | `LOST_FOUND_MODERATE` |
| GET | `/stats` | Statistics on reported, resolved, and pending items | `LOST_FOUND_MODERATE` |
| DELETE | `/:id` | Remove fraudulent or inappropriate post | `LOST_FOUND_MODERATE` |
| PATCH | `/:id/toggle-fraud` | Toggle fraud flag on post | `LOST_FOUND_MODERATE` |
| PATCH | `/user/:userId/block` | Block/unblock user from Lost & Found | `LOST_FOUND_MODERATE` |

---

## 15. Venues & Blackouts (`/api/venues`)

### Campus Venues (`/api/venues`)
| Method | Endpoint | Description | Auth / Permissions |
| :--- | :--- | :--- | :--- |
| GET | `/` | List all campus venues (`?openOnly=true`) | Public |
| POST | `/` | Create a new campus venue | Admin |
| PUT | `/:id` | Update venue name and availability | Admin |
| PATCH | `/:id/toggle-status` | Toggle venue open/closed status | Admin |
| DELETE | `/:id` | Delete venue | Admin |

### Venue Blackouts (`/api/venues/blackouts`)
| Method | Endpoint | Description | Auth / Permissions |
| :--- | :--- | :--- | :--- |
| GET | `/` | List active blackout periods (`?start=&end=&venue=`) | Public |
| POST | `/` | Schedule venue blackout / maintenance slot | Admin / Faculty Coordinator |
| PUT | `/:id` | Update blackout timing or reason | Admin / Faculty Coordinator |
| DELETE | `/:id` | Remove blackout period | Admin / Faculty Coordinator |

---

## 16. Administration (`/api/admin`)

| Method | Endpoint | Description | Auth / Permissions |
| :--- | :--- | :--- | :--- |
| POST | `/login` | Admin & Faculty portal authentication | Public |
| GET | `/dashboard-stats` | Global campus statistics, registrations & finance | `AUDIT_VIEW` (Admin) |
| GET | `/user-info/:id` | Retrieve user details | `USER_VIEW` |
| GET | `/clubs-list` | List all clubs with coordinator assignments | `CLUB_VIEW` |
| POST | `/clubs` | Create new club with faculty & club credentials | `CLUB_CREATE` |
| PUT | `/clubs/:id` | Update club credentials or faculty coordinator | `CLUB_UPDATE` |
| DELETE | `/clubs/:id` | Delete student club | `CLUB_DELETE` |
| GET | `/coordinators` | List faculty coordinators | `USER_VIEW` |
| POST | `/coordinators` | Create/assign new faculty coordinator | `USER_ASSIGN_ROLE` |
| PUT | `/coordinators/:id` | Update faculty coordinator assignment | `USER_ASSIGN_ROLE` |
| GET | `/manual-payments` | View all pending manual payments across campus | `PAYMENT_VERIFY` |
| GET | `/event-data-export` | Platform data dump | `AUDIT_EXPORT` |
| GET | `/central-organizer` | List institutional accounts & central organizers | Admin |
| POST | `/central-organizer` | Create institutional portal account | Admin |
| DELETE | `/central-organizer/:id` | Delete institutional portal account | Admin |
| GET | `/students/search` | Admin search for students | Admin |

---

## 17. Export Center (`/api/export-center`)

| Method | Endpoint | Description | Auth / Permissions |
| :--- | :--- | :--- | :--- |
| GET | `/events-list` | Get list of events available for export filters | Authenticated |
| GET | `/datasets` | Get list of exportable datasets authorized for current role | Authenticated |
| GET | `/preview` | Preview paginated dataset records with selected columns | Authenticated |
| POST | `/export` | Export dataset to downloadable CSV file with audit logging | Authenticated |
| GET | `/history` | View data export audit trail | `AUDIT_VIEW` |

---

## 18. System, Health & Cryptographic Keys

| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| GET | `/health` | Server uptime, latency, and performance metrics | No |
| GET | `/api/keys` | Public keys for cryptographic ticket verification | No |
| GET | `/api/keys/public` | Alias for cryptographic public keys | No |

---

## Common Payload Schemas

### 1. Student Registration (`POST /api/auth/register/student`)
```json
{
  "name": "Alex Smith",
  "rollNo": "22103045",
  "branch": "Computer Science and Engineering",
  "program": "B.Tech",
  "expectedGraduationYear": 2026,
  "email": "alex.cs.22@campus.edu",
  "password": "SecurePassword123!"
}
```

### 2. Create Event (`POST /api/events`)
```json
{
  "title": "Campus Hackathon 2026",
  "description": "Annual 24-hour hackathon with exciting challenges.",
  "venue": "Main Auditorium",
  "startTime": "2026-10-15T09:00:00.000Z",
  "endTime": "2026-10-16T09:00:00.000Z",
  "registrationDeadline": "2026-10-10T23:59:59.000Z",
  "maxSeats": 150,
  "isPaid": false,
  "isTeamEvent": true,
  "minTeamSize": 2,
  "maxTeamSize": 4,
  "allowExternal": true,
  "allowedPrograms": ["B.Tech", "M.Tech"],
  "allowedBranches": ["Computer Science and Engineering", "Information Technology"]
}
```

### 3. Team Registration (`POST /api/teams`)
```json
{
  "eventId": "66d3a8e9f2b1a4c3d8e5f123",
  "teamName": "ByteBusters",
  "members": ["66d3a8e9f2b1a4c3d8e5f456", "66d3a8e9f2b1a4c3d8e5f789"],
  "formResponses": {
    "Project Domain": "Web3 & AI"
  }
}
```

### 4. Review Manual Payment (`PUT /api/payment/:participationId/review`)
```json
{
  "status": "APPROVED",
  "message": "Payment verified via reference number."
}
```

### 5. Offline Scanner Sync (`POST /api/scanner/attendance/sync`)
```json
{
  "eventId": "66d3a8e9f2b1a4c3d8e5f123",
  "scannerSessionId": "66d3a8e9f2b1a4c3d8e5f999",
  "records": [
    {
      "participationId": "66d3a8e9f2b1a4c3d8e5f456",
      "ticketId": "aBcD1234XyZ",
      "scannedAt": "2026-10-15T09:15:32.000Z",
      "offlineSignature": "base64-signature"
    }
  ]
}
```
