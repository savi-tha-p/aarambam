-- ====================================================================
-- Aarambam Event Management Database Schema
-- Compatible with PostgreSQL and SQLite
-- ====================================================================

-- 1. Accounts Table (User profiles & credentials)
CREATE TABLE IF NOT EXISTS accounts (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    gender TEXT,
    dob TEXT,
    password TEXT NOT NULL,
    role TEXT DEFAULT 'user',
    verified INTEGER DEFAULT 0,          -- Boolean (0=false, 1=true)
    profile_complete INTEGER DEFAULT 0,  -- Boolean (0=false, 1=true)
    address TEXT,
    pin TEXT,
    aadhaar TEXT,
    status TEXT DEFAULT 'active',        -- 'active' or 'inactive'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_accounts_email ON accounts(email);

-- 2. Bookings Table (Registrations for events & time slots)
CREATE TABLE IF NOT EXISTS bookings (
    ticket_id TEXT PRIMARY KEY,
    event_id TEXT NOT NULL,
    event_name TEXT NOT NULL,
    date TEXT NOT NULL,
    time TEXT NOT NULL,
    room_name TEXT,
    email TEXT NOT NULL,
    user_name TEXT,
    user_phone TEXT,
    skills TEXT,                         -- Comma-separated or JSON list of selected skills
    fee REAL DEFAULT 0.0,
    status TEXT DEFAULT 'confirmed',     -- 'confirmed', 'cancelled', etc.
    qr_code TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (email) REFERENCES accounts(email) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_bookings_email ON bookings(email);
CREATE INDEX IF NOT EXISTS idx_bookings_event ON bookings(event_id);

-- 3. Members Table (Membership Registry)
CREATE TABLE IF NOT EXISTS members (
    member_id TEXT PRIMARY KEY,          -- Format e.g., ARM-2026-001
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    dob TEXT,
    gender TEXT,
    aadhaar TEXT,
    photo TEXT,                          -- Base64 encoded profile image string
    joined_date TEXT NOT NULL,
    validity_years INTEGER DEFAULT 1,
    status TEXT DEFAULT 'active',        -- 'active' or 'inactive'
    fee_status TEXT DEFAULT 'paid',      -- 'paid', 'due'
    fee_amount REAL DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_members_email ON members(email);

-- 4. Room Reservations Table (Slots reserved on the calendar)
CREATE TABLE IF NOT EXISTS room_reservations (
    id TEXT PRIMARY KEY,
    room_id TEXT NOT NULL,
    date TEXT NOT NULL,
    slot TEXT NOT NULL,
    title TEXT NOT NULL,
    by_email TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_reservations_room_date ON room_reservations(room_id, date);

-- 5. Room Metadata Table (Visibility & availability states)
CREATE TABLE IF NOT EXISTS room_meta (
    room_id TEXT PRIMARY KEY,
    visible INTEGER DEFAULT 1,           -- Boolean (0=false, 1=true)
    available INTEGER DEFAULT 1          -- Boolean (0=false, 1=true)
);

-- 6. Settings Table (Global key-value options)
CREATE TABLE IF NOT EXISTS settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

-- ====================================================================
-- SEED DATA
-- ====================================================================

-- Seed Super Admin and Aarambam Admin
INSERT INTO accounts (id, name, email, password, role, verified, profile_complete, status) 
VALUES 
('admin-super', 'Super Admin', 'admin@admin.com', 'adminpassword', 'admin', 1, 1, 'active'),
('admin-aarambam', 'Aarambam Admin', 'admin@aarambam.in', 'adminpassword', 'admin', 1, 1, 'active')
ON CONFLICT (id) DO NOTHING;

-- Seed Default Settings
INSERT INTO settings (key, value)
VALUES 
('upiId', 'aarambam@upi'),
('upiName', 'Aarambam'),
('defaultFee', '500')
ON CONFLICT (key) DO NOTHING;

-- Seed Default Room Visibility
INSERT INTO room_meta (room_id, visible, available)
VALUES 
('hall-a', 1, 1),
('hall-b', 1, 1),
('class-1', 1, 1),
('class-2', 1, 1)
ON CONFLICT (room_id) DO NOTHING;
