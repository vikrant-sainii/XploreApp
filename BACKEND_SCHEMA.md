# CampusNode — Backend Database Schema & Architecture 🗄️

Authoritative reference for the CampusNode database models, relationships, role-based access controls (RBAC), and entity lifecycles built on **PostgreSQL** using **Prisma ORM**.

---

## 1. System Personas & Role Matrix

CampusNode uses a role-based access control (RBAC) architecture with dedicated account types and permissions.

### Account Types (Principals)
- **`StudentUser`**: Regular NITJ students (`@nitj.ac.in`), club heads, and student organizers.
- **`AdminRole`**: Faculty coordinators, payment administrators, and super administrators.
- **`ExternalUser`**: Inter-college participants from other institutions.
- **`ClubAccount`**: Official shared credentials for registered student clubs.
- **`InstitutionalAccount`**: Administrative accounts for central college bodies (e.g. DSW / Dean Student Welfare).

### Role Capabilities & Target Views

| Role | Key Capabilities | Primary Target Views |
| :--- | :--- | :--- |
| **`admin`** | Full platform oversight, create/delete clubs, manage coordinators, global audits, financial & transaction audits, venue control. | `/admin`, `/export-center` |
| **`facultyCoordinator`** | Review/Approve club event proposals, review club finances, manage blackout slots for club venues. | `/admin` (Coordinator view) |
| **`club` / `club_account`** | Create event drafts, manage rosters, review manual UPI payments, export registrations, design certificates. | `/club-dashboard`, `/create-event` |
| **`central_organizer`** | Manage institute-wide events (DSW / Mega Fests), collaborate with clubs, delegate event staff operators. | `/central-organizer/dashboard` |
| **`EVENT_STAFF`** | High-throughput QR scanner check-in, offline sync, attendee verification for delegated events. | `/scanner` |
| **`student` / `member`** | Browse events, individual/team registrations, submit feedback, download certificates, lost & found. | `/events`, `/my-events`, `/lost-found` |
| **`external`** | Register for open inter-college events, join teams, make payments, receive verified QR tickets. | `/events`, `/my-events` |

---

## 2. Core Model Relationships Summary

| Primary Model | Related Models | Relationship Description |
| :--- | :--- | :--- |
| **`Club`** | `ClubMembership`, `Event`, `ClubAnnouncement`, `ClubAchievement`, `ClubAccount` | One club has many members, events, announcements, achievements, and 1 official account. |
| **`Event`** | `Participation`, `Team`, `EventStaff`, `EventClub`, `EventFeedback`, `EventAIReview` | One event has many attendee registrations (`Participation`), teams, delegated staff, and feedback. |
| **`StudentUser`** | `ClubMembership`, `Participation`, `Team`, `EventStaff`, `LostFoundItem`, `EventFeedback` | One student can join multiple clubs, register for events, lead/join teams, and report lost items. |
| **`Team`** | `StudentUser` (Leader), `TeamMember` (Roster), `Participation` (Ticket) | A team belongs to an event, has 1 leader, multiple members, and linked participations. |
| **`Participation`** | `Event`, `StudentUser` / `ExternalUser`, `Team`, `AttendanceRecord` | Represents 1 registered attendee/ticket for an event, linked to attendance scan logs. |
| **`InstitutionalAccount`** | `InstitutionalAccountAssignment`, `Event` | Central body (DSW) assigns student central organizers and hosts central campus events. |
| **`LostFoundItem`** | `StudentUser`, `LostFoundReport`, `Notification` | A lost/found item is reported by a student and can be claimed or reported by others. |

---

## 3. Database Models & Field Reference

### 3.1 Identity & User Accounts

#### `StudentUser`
Represents verified NITJ students.
```prisma
id                      String    @id @db.VarChar(24)
name                    String
email                   String    @unique // Must be @nitj.ac.in
password                String    // Hashed with bcrypt
rollNo                  String?   @unique
branch                  String?
program                 String?   // "B.Tech", "M.Tech", "MBA", "M.Sc", "Ph.D", "OTHER"
expectedGraduationYear  Int?
academicStatus          String    @default("ACTIVE")
githubProfile           String?
linkedinProfile         String?
xProfile                String?
instagramProfile        String?
whatsappNumber          String?
portfolioUrl            String?
profileImage            String?
isVerified              Boolean   @default(false)
isTwoStepEnabled        Boolean   @default(false)
isBlocked               Boolean   @default(false)
accessLevel             String    @default("normal") // "normal" | "central_organizer"
createdAt               DateTime  @default(now())
updatedAt               DateTime  @updatedAt
```

#### `AdminRole`
Represents faculty coordinators, payment admins, and super admins.
```prisma
id                      String        @id @db.VarChar(24)
name                    String
email                   String        @unique
password                String
role                    AdminRoleType @default(admin) // "admin" | "facultyCoordinator" | "paymentAdmin" | "lostFoundAdmin"
isTwoStepEnabled        Boolean       @default(false)
profileImage            String?
createdAt               DateTime      @default(now())
updatedAt               DateTime      @updatedAt
```

#### `ExternalUser`
Represents participants from outside NITJ for open hackathons/cultural events.
```prisma
id                      String    @id @db.VarChar(24)
name                    String
email                   String    @unique
password                String
collegeName             String
phone                   String?
program                 String?
graduationYear          Int?
profileImage            String?
isVerified              Boolean   @default(true)
createdAt               DateTime  @default(now())
updatedAt               DateTime  @updatedAt
```

#### `ClubAccount`
Shared official club credentials managed by the club executive board.
```prisma
id                      String    @id @db.VarChar(24)
clubId                  String    @unique @db.VarChar(24)
email                   String    @unique
password                String
isActive                Boolean   @default(true)
createdAt               DateTime  @default(now())
updatedAt               DateTime  @updatedAt
```

#### `InstitutionalAccount`
Central authority accounts (such as DSW / Dean Student Welfare).
```prisma
id                      String                   @id @db.VarChar(24)
name                    String
type                    InstitutionalAccountType @default(DSW)
email                   String?                  @unique
password                String?
isActive                Boolean                  @default(true)
createdAt               DateTime                 @default(now())
updatedAt               DateTime                 @updatedAt
```

---

### 3.2 Clubs, Memberships & Showcases

#### `Club`
Student societies and clubs recognized on campus.
```prisma
id                   String    @id @db.VarChar(24)
clubName             String    @unique
slug                 String    @unique
description          String?
category             String?   // "Technical", "Cultural", "Sports", etc.
clubLogo             String?
bannerImage          String?
clubEmail            String?
facultyCoordinatorId String?   @db.VarChar(24) // References AdminRole
facultyName          String?
facultyEmail         String?
studentCoordinators  String[]  @default([])
motto                String?
mission              String?
establishedYear      String?
createdAt            DateTime  @default(now())
updatedAt            DateTime  @updatedAt
```

#### `ClubMembership`
Links students to clubs with designated roles and fine-grained permissions.
```prisma
id                String         @id @db.VarChar(24)
studentId         String         @db.VarChar(24) // References StudentUser
clubId            String         @db.VarChar(24) // References Club
role              ClubMemberRole @default(MEMBER) // "CLUB_HEAD" | "COORDINATOR" | "MEMBER"
status            String         @default("ACTIVE") // "ACTIVE" | "INACTIVE"
canEditEvents     Boolean        @default(false)
canTakeAttendance Boolean        @default(true)
customPermissions String[]       @default([])
createdAt         DateTime       @default(now())
updatedAt         DateTime       @updatedAt
```

#### `ClubAnnouncement` & `ClubAchievement`
```prisma
// ClubAnnouncement
id          String   @id @db.VarChar(24)
clubId      String   @db.VarChar(24)
title       String
content     String
isPinned    Boolean  @default(false)
isPublished Boolean  @default(true)
authorName  String?
createdAt   DateTime @default(now())

// ClubAchievement
id          String   @id @db.VarChar(24)
clubId      String   @db.VarChar(24)
title       String
description String?
date        String?
imageUrl    String?
externalUrl String?
createdAt   DateTime @default(now())
```

---

### 3.3 Events, Venues & Collaborations

#### `Event`
Core entity for campus workshops, hackathons, sports, and cultural fests.
```prisma
id                   String             @id @db.VarChar(24)
title                String
slug                 String?            @unique
description          String?
venue                String
startTime            DateTime
endTime              DateTime
registrationDeadline DateTime?
totalSeats           Int                @default(0) // 0 = unlimited
registeredCount      Int                @default(0)
views                Int                @default(0)
imageUrl             String?
organizerType        EventOrganizerType @default(CLUB) // "CLUB" | "CENTRAL"
clubId               String?            @db.VarChar(24)
createdById          String?            @db.VarChar(24)
centralOrganizerId   String?            @db.VarChar(24)
institutionalAccountId String?          @db.VarChar(24)
reviewStatus         ReviewStatus       @default(PENDING) // "DRAFT" | "PENDING" | "PUBLISHED" | "REJECTED"
reviewComment        String?
reviewedById         String?            @db.VarChar(24)
isFeatured           Boolean            @default(false)
allowExternal        Boolean            @default(true)
feedbackEnabled      Boolean            @default(true)
allowedPrograms      String[]           @default(["BTECH", "MTECH", "OTHER"])
allowedYears         String[]           @default([])
allowedBranches      String[]           @default([])
registrationType     String             @default("individual") // "individual" | "team"
minTeamSize          Int                @default(1)
maxTeamSize          Int                @default(1)
paymentMethod        String             @default("FREE") // "FREE" | "MANUAL_UPI" | "COLLEGE_GATEWAY"
entryFee             Float              @default(0)
registrationFee      Float              @default(0)
upiId                String?
accountHolderName    String?
paymentInstructions  String?
collegePaymentUrl    String?
postRegistrationMessage String?
provideCertificate   Boolean            @default(false)
certificateTemplate  Json?
winners              Json?
showWinner           Boolean            @default(false)
customFields         Json?              // Custom form question builder schema
requiredFields       String[]           @default([])
waitingListIds       String[]           @default([])
createdAt            DateTime           @default(now())
updatedAt            DateTime           @updatedAt
```

#### `Venue` & `VenueBlackout`
```prisma
// Venue
id        String   @id @db.VarChar(24)
name      String   @unique // e.g. "Main Auditorium", "IT Conference Hall"
isOpen    Boolean  @default(true)
createdAt DateTime @default(now())
updatedAt DateTime @updatedAt

// VenueBlackout (Prevents booking conflicts during maintenance or exams)
id          String   @id @db.VarChar(24)
venue       String
title       String
reason      String?
startTime   DateTime
endTime     DateTime
createdById String?  @db.VarChar(24)
createdAt   DateTime @default(now())
```

#### `EventStaff`
Delegates operational responsibilities (such as scanning tickets) to specific students.
```prisma
id          String           @id @db.VarChar(24)
eventId     String           @db.VarChar(24)
userId      String           @db.VarChar(24) // References StudentUser
invitedById String?          @db.VarChar(24)
permissions String[]         @default([])    // ["ATTENDANCE_OPERATOR", "REGISTRATION_DESK"]
status      EventStaffStatus @default(PENDING) // "PENDING" | "ACTIVE" | "REJECTED" | "REVOKED" | "EXPIRED"
expiresAt   DateTime?
revokedAt   DateTime?
createdAt   DateTime         @default(now())
```

---

### 3.4 Registrations, Teams & Cryptographic Attendance

#### `Participation`
Unified registration record and digital admission ticket for an event.
```prisma
id                   String              @id @db.VarChar(24)
eventId              String              @db.VarChar(24)
studentId            String?             @db.VarChar(24) // Null if external participant
externalUserId       String?             @db.VarChar(24) // Null if internal student
externalEmail        String?
externalName         String?
teamId               String?             @db.VarChar(24) // References Team if team event
status               ParticipationStatus @default(REGISTERED) // "REGISTERED" | "ATTENDED" | "WAITLISTED" | "CANCELLED" | "INVITED"
qrCode               String?             @unique // Unique Ticket ID (e.g. 12-char base64url)
qrVersion            Int?                // 1 = Ed25519 Signed QR, null = Legacy
qrPayload            String?             // Base64URL payload containing signature & header
qrKeyId              String?             // ID of the public key for rotation validation
attendedAt           DateTime?
markedByMemberId     String?             @db.VarChar(24)
paymentStatus        PaymentStatus       @default(SUCCESS) // "PENDING" | "SUCCESS" | "APPROVED" | "REJECTED" | "NEED_MORE_DETAILS"
amountPaid           Float               @default(0)
transactionId        String?             // UTR Number entered by student
payerName            String?
paymentRemarks       String?
paymentReviewedBy    String?             @db.VarChar(24)
paymentReviewedAt    DateTime?
paymentReviewMessage String?
formResponses        Json?               // Student responses to custom event questions
createdAt            DateTime            @default(now())
updatedAt            DateTime            @updatedAt
```

#### `Team` & `TeamMember`
```prisma
// Team
id               String       @id @db.VarChar(24)
eventId          String       @db.VarChar(24)
teamName         String
leaderId         String       @db.VarChar(24)
leaderStudentId  String?      @db.VarChar(24) // References StudentUser
leaderExternalId String?      @db.VarChar(24) // References ExternalUser
status           String       @default("active")
createdAt        DateTime     @default(now())

// TeamMember
id             String        @id @db.VarChar(24)
teamId         String        @db.VarChar(24)
userId         String        @db.VarChar(24)
studentId      String?       @db.VarChar(24)
externalUserId String?       @db.VarChar(24)
role           String        @default("member") // "leader" | "member"
joinedAt       DateTime      @default(now())
```

#### `ScannerSession` & `AttendanceRecord`
Enables offline and real-time attendance verification at scale.
```prisma
// ScannerSession
id        String    @id @db.VarChar(24)
eventId   String    @db.VarChar(24)
userId    String    @db.VarChar(24)
deviceId  String
mode      String    // "ONLINE" | "OFFLINE"
status    String    @default("ACTIVE") // "ACTIVE" | "ENDED"
startedAt DateTime  @default(now())
endedAt   DateTime?

// AttendanceRecord (Duplicate-safe attendance log)
id                String    @id @db.VarChar(24)
eventId           String    @db.VarChar(24)
participationId   String    @db.VarChar(24)
scannerSessionId  String?   @db.VarChar(24)
scannedAt         DateTime
verificationMode  String    // "ONLINE" | "OFFLINE"
syncedAt          DateTime?
localAttendanceId String?   @unique // Client UUID for idempotent sync
createdAt         DateTime  @default(now())
```

---

### 3.5 Feedback, Sentiment & AI Reviews

#### `EventFeedback`
Post-event student survey with 6 rating dimensions.
```prisma
id                  String        @id @db.VarChar(24)
eventId             String        @db.VarChar(24)
userId              String        @db.VarChar(24)
overallRating       Int           // 1 to 5
organizationRating  Int           // 1 to 5
usefulnessRating    Int           // 1 to 5
speakerRating       Int           // 1 to 5
venueRating         Int           // 1 to 5
timingRating        Int           // 1 to 5
attendSimilar       AttendSimilar // "YES" | "MAYBE" | "NO"
liked               String?
improvements        String?
comments            String?
submittedAt         DateTime      @default(now())
```

#### `EventAIReview`
Gemini-generated sentiment intelligence report summarizing all student feedback.
```prisma
id                     String    @id @db.VarChar(24)
eventId                String    @db.VarChar(24)
reviewNumber           Int       // 1 (Interim) or 2 (Final)
status                 String    // "COMPLETED" | "FAILED" | "IN_PROGRESS"
responseCount          Int
attendeeCount          Int
overallSentiment       String    // "very_positive" | "positive" | "mixed" | "negative"
overallSummary         String    @db.Text
whatStudentsLiked      Json      // Array<{ theme: string, summary: string, evidenceCount?: number }>
improvementAreas       Json      // Array<{ theme: string, summary: string, priority: "high" | "medium" | "low" }>
keyTakeaways           Json      // string[]
recommendations        Json      // Array<{ title: string, description: string, priority: string }>
positiveHighlights     Json      // Array<{ quote: string, reason: string }>
constructiveHighlights Json      // Array<{ quote: string, reason: string }>
attendAgainSummary     Json?     // { yesPercentage: number, maybePercentage: number, noPercentage: number }
model                  String
generatedAt            DateTime  @default(now())
```

---

### 3.6 Notifications, Web Push & Lost & Found

#### `Notification` & `PushSubscription`
```prisma
// Notification
id                            String   @id @db.VarChar(24)
title                         String
message                       String
type                          String?  // "TEAM_INVITATION", "PAYMENT_REVIEW", "STAFF_INVITATION", etc.
senderStudentId               String?  @db.VarChar(24)
senderAdminId                 String?  @db.VarChar(24)
senderInstitutionalAccountId  String?  @db.VarChar(24)
senderClubAccountId           String?  @db.VarChar(24)
recipientStudentId            String?  @db.VarChar(24) // Null for broadcasts
eventId                       String?  @db.VarChar(24)
teamId                        String?  @db.VarChar(24)
readBy                        String[] @default([]) // Array of User IDs who opened the notif
createdAt                     DateTime @default(now())

// PushSubscription (Web Push VAPID)
id         String   @id @db.VarChar(24)
userId     String   @db.VarChar(24)
endpoint   String   @unique
p256dh     String
auth       String
userAgent  String?
createdAt  DateTime @default(now())
```

#### `LostFoundItem` & `LostFoundReport`
```prisma
// LostFoundItem
id             String          @id @db.VarChar(24)
title          String
description    String
type           LostFoundType   @default(LOST)   // "LOST" | "FOUND"
status         LostFoundStatus @default(ACTIVE) // "ACTIVE" | "REUNITED"
imageUrl       String?
imagePublicId  String?
whatsapp       String?
isFraud        Boolean         @default(false)
reportedBy     String[]        @default([])
userId         String          @db.VarChar(24) // Reporter Student
reunitedAt     DateTime?
createdAt      DateTime        @default(now())
updatedAt      DateTime        @updatedAt

// LostFoundReport
id         String   @id @db.VarChar(24)
itemId     String   @db.VarChar(24)
reporterId String   @db.VarChar(24)
liarId     String   @db.VarChar(24)
reason     String?
createdAt  DateTime @default(now())
```

---

### 3.7 Governance, Auditing & Export Logs

#### `AuditLog`
Immutable security and administrative ledger for tracking critical operations.
```prisma
id         String   @id @db.VarChar(24)
action     String   // e.g. "EVENT_CREATED", "PAYMENT_APPROVED", "STAFF_DELEGATED"
actorType  String?  // "STUDENT", "ADMIN", "INSTITUTIONAL", "CLUB"
actorId    String   @db.VarChar(24)
actorEmail String
targetId   String?  @db.VarChar(24)
clubId     String?  @db.VarChar(24)
eventId    String?  @db.VarChar(24)
metadata   Json?    // Context payload
source     String?  // "WEB", "SCANNER", "API"
createdAt  DateTime @default(now())
```

#### `ExportLog`
Audit log recording every CSV data export event from the Export Center.
```prisma
id          String   @id @db.VarChar(24)
dataset     String   // "events", "attendance", "feedback", "finances", "clubs"
recordCount Int      @default(0)
actorId     String   @db.VarChar(24)
actorEmail  String
actorRole   String
filters     Json?
columns     String[] @default([])
createdAt   DateTime @default(now())
```

---

## 4. Key Entity Lifecycles & State Transitions

### 4.1 Event Review Lifecycle
1. **`DRAFT`**: Event created as a draft by club lead or organizer.
2. **`PENDING`**: Submitted to Faculty Coordinator / Admin for review.
3. **`PUBLISHED`**: Approved and visible on public calendar/feed.
4. **`REJECTED`**: Declined by faculty with feedback comment; organizer can modify and resubmit.
5. **`DELETION_REQUESTED`**: Club requests removal of an already published event.

### 4.2 Participation & Ticket Lifecycle
- **Individual Free Event**: Direct `REGISTERED` status -> Scanned at venue -> `ATTENDED`.
- **Manual UPI Paid Event**: `PENDING` payment review -> Coordinator approves -> `APPROVED` (Active ticket) -> Scanned -> `ATTENDED`.
  - If coordinator requests proof: `NEED_MORE_DETAILS` -> Student re-submits UTR -> `PENDING`.
  - If invalid: `REJECTED`.
- **Team Event Invitation**: `INVITED` -> Teammate accepts -> `REGISTERED` (or `WAITLISTED` if seats full).
  - If teammate declines: `CANCELLED`.

### 4.3 Lost & Found Item Lifecycle
- **`ACTIVE`**: Item posted on Lost & Found feed.
- **`REUNITED`**: Owner claims item and verification is confirmed. (Auto-cleaned after 3 days).
- **Flagged Fraud**: Item marked fraudulent by 3+ reports or admin moderation.

---

## 5. Frontend Design & Developer Guidelines

1. **IDs and Data Types**:
   - All Primary Keys (`id`) are 24-character hexadecimal strings (MongoDB ObjectId format).
   - Foreign keys use `@db.VarChar(24)`.
2. **Dates & Timestamps**:
   - Stored in UTC (`ISO 8601` format: `YYYY-MM-DDTHH:mm:ss.sssZ`).
   - Format on client using `Intl.DateTimeFormat` (e.g. `15 Oct 2026, 09:00 AM`).
3. **Dynamic Forms (`customFields` & `formResponses`)**:
   - Events can define dynamic registration questions inside `Event.customFields`.
   - Responses are submitted and saved as key-value pairs inside `Participation.formResponses`.
4. **Offline Scanner QR Payloads**:
   - Valid QR codes contain a base64url payload with version header (`v1`) and Ed25519 signature verified against `/api/keys/public`.
