-- ============================================================
-- db.sql — Database Schema for Hotel Booking System
-- This schema is used by the Java JDBC backend
-- ============================================================

-- Drop tables if they exist (for clean setup)
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS rooms;
DROP TABLE IF EXISTS users;

-- ============================================================
-- Users table — stores both regular users and admin accounts
-- ============================================================
CREATE TABLE users (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(60)   NOT NULL,
    email         VARCHAR(255)  NOT NULL UNIQUE,
    password_hash VARCHAR(255)  NOT NULL,     -- bcrypt hashed password
    role          ENUM('user', 'admin') NOT NULL DEFAULT 'user',
    created_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- Rooms table — hotel room inventory
-- ============================================================
CREATE TABLE rooms (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    name         VARCHAR(80)   NOT NULL,
    type         ENUM('Standard', 'Deluxe', 'Suite', 'Penthouse') NOT NULL,
    price        DECIMAL(10,2) NOT NULL CHECK (price > 0),
    capacity     INT           NOT NULL CHECK (capacity >= 1),
    amenities    TEXT,                        -- JSON array stored as text
    image_url    VARCHAR(500),
    available    BOOLEAN       NOT NULL DEFAULT TRUE,
    description  TEXT,
    
    INDEX idx_rooms_type (type),
    INDEX idx_rooms_available (available),
    INDEX idx_rooms_price (price)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- Bookings table — reservation records
-- ============================================================
CREATE TABLE bookings (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT            NOT NULL,
    room_id      INT            NOT NULL,
    check_in     DATE           NOT NULL,
    check_out    DATE           NOT NULL,
    guests       INT            NOT NULL CHECK (guests >= 1),
    total_price  DECIMAL(10,2)  NOT NULL,
    status       ENUM('confirmed', 'cancelled', 'completed') NOT NULL DEFAULT 'confirmed',
    created_at   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE,
    
    INDEX idx_bookings_user (user_id),
    INDEX idx_bookings_room (room_id),
    INDEX idx_bookings_status (status),
    INDEX idx_bookings_dates (check_in, check_out),
    
    CONSTRAINT chk_dates CHECK (check_out > check_in)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- Seed Data
-- ============================================================

-- Admin user (password: Admin123)
INSERT INTO users (name, email, password_hash, role) VALUES
    ('Admin User', 'admin@hotel.com', '$2a$10$dummyhash_admin', 'admin');

-- Regular user (password: John1234)
INSERT INTO users (name, email, password_hash, role) VALUES
    ('John Doe', 'john@example.com', '$2a$10$dummyhash_john', 'user');

-- Sample Rooms
INSERT INTO rooms (name, type, price, capacity, amenities, image_url, available, description) VALUES
    ('Garden View Standard', 'Standard', 99.00, 2,
     '["WiFi","TV","Air Conditioning","Mini Bar"]',
     'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=600&h=400&fit=crop',
     TRUE,
     'A comfortable standard room with a beautiful garden view, perfect for couples or solo travelers.'),
    
    ('Ocean Breeze Deluxe', 'Deluxe', 179.00, 2,
     '["WiFi","TV","Air Conditioning","Mini Bar","Balcony","Room Service"]',
     'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=600&h=400&fit=crop',
     TRUE,
     'A spacious deluxe room with stunning ocean views and a private balcony.'),
    
    ('Royal Executive Suite', 'Suite', 299.00, 4,
     '["WiFi","TV","Air Conditioning","Mini Bar","Balcony","Room Service","Jacuzzi","Kitchenette"]',
     'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=600&h=400&fit=crop',
     TRUE,
     'An elegant executive suite featuring a separate living area and jacuzzi.'),
    
    ('Skyline Penthouse', 'Penthouse', 599.00, 6,
     '["WiFi","TV","Air Conditioning","Mini Bar","Balcony","Room Service","Jacuzzi","Kitchenette","Private Terrace","Butler Service"]',
     'https://images.unsplash.com/photo-1591088398332-8a7791972843?w=600&h=400&fit=crop',
     TRUE,
     'The ultimate luxury experience — a full penthouse with panoramic city views.');

-- Sample Bookings
INSERT INTO bookings (user_id, room_id, check_in, check_out, guests, total_price, status) VALUES
    (2, 2, '2025-02-10', '2025-02-14', 2, 716.00, 'confirmed'),
    (2, 3, '2025-03-01', '2025-03-05', 3, 1196.00, 'confirmed');
