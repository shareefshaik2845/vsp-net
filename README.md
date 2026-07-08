# VSP Nest Portal

A high-fidelity hybrid Flutter & Dart portal app using Clean Architecture and Riverpod for VSP Nest.

This portal contains multiple roles including Customer, Operational Admin, staff Concierge Desk, Accountant Ledger, and Super Admin.

## Setup & Running Locally

### Prerequisites

- Flutter SDK (version `>=3.0.0 <4.0.0`) configured on your system.
- Web browser (Chrome/Edge) or a simulator/device.

### Run Instructions

1. **Resolve dependencies:**
   ```bash
   flutter pub get
   ```

2. **Launch the application on Chrome:**
   ```bash
   flutter run -d chrome
   ```

3. **Build the production bundle for web:**
   ```bash
   flutter build web
   ```

## Backend Setup

The app requires the Spring Boot backend at `D:\VSP\backend`.

### Prerequisites

- Java 17+
- PostgreSQL (create database `vsp_nest`)
- Maven 3.8+

### Run Instructions

1. **Create the database:**
   ```bash
   psql -U postgres -c "CREATE DATABASE vsp_nest;"
   ```

2. **Start the backend (applies Flyway migrations automatically):**
   ```bash
   cd D:\VSP\backend
   mvn spring-boot:run
   ```
   The API starts at `http://localhost:8080`.

3. **Seed data:** Flyway V1–V9 run on startup, seeding schema + comprehensive demo data for all roles (Super Admin, Admin, Staff, Accountant, Customer).

### Default Credentials

| Role | Email | Password |
|------|-------|----------|
| Super Admin | `superadmin@vspnest.com` | `admin123` |
| Admin | `admin@vspnest.com` | `admin123` |
| Staff | `housekeeping.staff@vspnest.com` | `staff123` |
| Accountant | `accountant@vspnest.com` | `accountant123` |
| Customer | `ananya@rediff.com` | `customer123` |
