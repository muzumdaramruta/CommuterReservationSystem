# CRS - Commuter Reservation System

This project demonstrates a comprehensive train ticket booking system built using Oracle PL/SQL. It implements advanced features including waitlist management, seat allocation, fare discounts based on passenger category, and robust business rule validation. The system follows industry best practices in database design, security, exception handling, and modular architecture.

## Execution Flow

All SQL scripts are stored in the `scripts/` directory.

**Run scripts in the following order:**

### Step 1: Run User Setup (as SYSTEM/DBA)

```sql
Run: 01_CRS_Setup.sql
```

This script creates two users:
- `crs_admin`: Application owner with full privileges to create and manage all database objects.
- `crs_user`: Application user with execute-only access to stored procedures and select access to views (no direct table access).

---

### Step 2: Create Database Objects (as `crs_admin`)

```sql
Run: 02_CRS_Schema.sql
Run: 03_CRS_Reference_Data.sql
Run: 04_CRS_Package.sql
Run: 05_CRS_Views.sql
Run: 06_CRS_Grants.sql
```

**Creates:**
- 5 normalized tables with constraints and foreign keys
- 5 sequences for auto-generated IDs
- 1 comprehensive package (`crs_booking_pkg`) with 8 procedures and functions
- 6 views for business intelligence and reporting
- Performance indexes for optimized queries
- Grants execute and select permissions to `crs_user`

---

### Step 3: Create Synonyms (as `crs_user`)

Login as:
```
Username: crs_user
Password: ******
```

Run:
```sql
Run: 07_CRS_Synonyms.sql
```

This allows `crs_user` to reference objects without the `crs_admin.` prefix.

---

### Step 4: Load Sample Data (as `crs_admin`)

```sql
Run: 08_CRS_Sample_Data.sql
```

Populates the system with:
- 3 sample trains with different operating schedules (weekdays, all days, weekends)
- 3 sample passengers (adult, minor, senior citizen)
- 2 sample bookings demonstrating fare discounts

This script is **re-runnable** and clears old data automatically before loading fresh data.

---

### Step 5: Run Test Cases (as `crs_user`)

```sql
Run: 09_CRS_Test_Cases.sql
```

Executes comprehensive test suite including:
- 6 passenger registration tests (positive and negative scenarios)
- 5 ticket booking tests (validation and business rules)
- 3 cancellation tests (including waitlist promotion)
- Validation of all 6 reporting views

---

### Step 6: Optional - Clear and Reset Data

```sql
Run: Clear_Sample_Data.sql (as crs_admin)
```

Removes all data while preserving database structure. Useful for fresh demo runs.

---

## Features Demonstrated

### Security Model
- **Two-schema architecture**: Separation of object ownership and data operations
- **crs_user cannot**:
  - Query tables directly
  - Insert/Update/Delete data directly
  - Bypass business logic validation
- **crs_user can only**:
  - Execute stored procedures (with full validation)
  - Query views for reporting
  - Access data through controlled interfaces

### Business Logic & Validation
- **Passenger Registration**:
  - Unique email and phone number validation
  - Date of birth validation (must be in past, age ≤ 120 years)
  - Email format validation (regex)
  - Phone format validation (10-15 digits)
  - Automatic age categorization (Minor/Adult/Senior Citizen)

- **Ticket Booking**:
  - 7-day advance booking limit
  - Train schedule validation (operates on selected day)
  - Seat capacity management (40 confirmed + 5 waitlist per class)
  - Duplicate booking prevention (same passenger/train/date/class)
  - Automatic waitlist assignment when seats full
  - Fare discount application:
    - **Minors (under 18)**: 50% discount
    - **Senior Citizens (60+)**: 30% discount
    - **Adults (18-59)**: Full fare

- **Ticket Cancellation**:
  - Automatic waitlist promotion when confirmed ticket cancelled
  - Waitlist position re-sequencing
  - Prevention of double cancellation

### Exception Handling
All procedures include comprehensive exception handling:
- User-defined exceptions with meaningful error messages
- Error codes: -20001 to -20007 for different business rule violations
- Proper transaction management (COMMIT/ROLLBACK)
- Graceful error recovery

### Reporting Views

1. **v_train_availability**: Train schedules, capacity, fares, and operating days
2. **v_passenger_bookings**: Complete booking history with passenger details and calculated fares
3. **v_daily_booking_summary**: Daily seat utilization and availability by train and class
4. **v_waitlist_status**: Current waitlisted passengers for customer service
5. **v_revenue_report**: Monthly revenue analysis by train and seat class
6. **v_passenger_demographics**: Age distribution for marketing insights

### Performance Optimization

Performance indexes created for:
```sql
CREATE INDEX idx_reservation_passenger ON crs_reservation(passenger_id);
CREATE INDEX idx_reservation_train ON crs_reservation(train_id);
CREATE INDEX idx_reservation_travel_date ON crs_reservation(travel_date);
CREATE INDEX idx_reservation_status ON crs_reservation(seat_status);
CREATE INDEX idx_train_schedule_train ON crs_train_schedule(train_id);
```

---

## Package Functions Reference

### `crs_booking_pkg` Package

#### Procedures:
1. **register_passenger**: Register new passenger with complete validation
2. **book_ticket**: Book train ticket with seat allocation and fare calculation
3. **cancel_ticket**: Cancel booking with automatic waitlist promotion
4. **add_train**: Add new train to the system
5. **add_train_schedule**: Configure train operating days

#### Functions:
1. **check_seat_availability**: Returns available seats (confirmed + waitlist)
2. **get_passenger_category**: Returns age category (MINOR/ADULT/SENIOR CITIZEN)
3. **calculate_fare**: Calculates fare with applicable discounts
4. **is_train_available**: Checks if train operates on given date

---

## Database Schema

### Tables (5):
- **crs_train_info**: Train details, routes, capacity, and fares
- **crs_day_schedule**: Reference table for days of week (7 rows)
- **crs_train_schedule**: Bridge table linking trains to operating days
- **crs_passenger**: Passenger information and contact details
- **crs_reservation**: Booking records with status tracking

### Key Relationships:
- Train → Train Schedule (1:M)
- Day Schedule → Train Schedule (1:M)
- Train → Reservation (1:M)
- Passenger → Reservation (1:M)

---

## Normalization Justification

- **1NF – First Normal Form**: All attributes are atomic, no repeating groups, clear primary keys
- **2NF – Second Normal Form**: No partial dependencies; all non-key attributes fully depend on primary key
- **3NF – Third Normal Form**: No transitive dependencies; all attributes directly depend on primary key only

✅ All entities conform to 1NF, 2NF, and 3NF.

---

## Business Rules Enforced

| Rule | Implementation | Error Code |
|------|---------------|------------|
| Unique email per passenger | UNIQUE constraint + procedure validation | -20004 |
| Unique phone per passenger | UNIQUE constraint + procedure validation | -20004 |
| DOB must be in past | Procedure validation | -20004 |
| Travel date must be future | Procedure validation | -20002 |
| Only 7 days advance booking | Procedure validation | -20006 |
| Train operates on selected day | Function validation | -20001 |
| 40 confirmed seats per class | Procedure logic | -20003 |
| 5 waitlist positions per class | Procedure logic | -20003 |
| No duplicate bookings | Procedure validation | -20007 |
| Auto-promote waitlist on cancel | Procedure logic | N/A |

---

## Test Cases Coverage

### Positive Tests (Should Succeed):
- Register passengers (adult, minor, senior)
- Book tickets with fare discounts
- Cancel tickets
- Query all 6 views

### Negative Tests (Should Fail):
- Duplicate email registration
- Duplicate phone registration
- Future date of birth
- Invalid train ID
- Past travel date
- Advance booking limit exceeded
- Train not operating on selected day
- Duplicate booking
- Invalid booking ID
- Double cancellation

**Total: 18+ comprehensive test cases**

---

## Usage Examples

### Register Passenger (as `crs_user`):
```sql
DECLARE v_pid NUMBER;
BEGIN
    crs_booking_pkg.register_passenger(
        'John', 'M', 'Smith', TO_DATE('1990-05-15', 'YYYY-MM-DD'),
        '123 Main St', 'Boston', 'MA', '02101',
        'john.smith@email.com', '6171234567', v_pid);
    DBMS_OUTPUT.PUT_LINE('Passenger ID: ' || v_pid);
END;
/
```

### Book Ticket (as `crs_user`):
```sql
DECLARE 
    v_bid NUMBER; v_status VARCHAR2(20); v_waitlist NUMBER;
BEGIN
    crs_booking_pkg.book_ticket(
        1000, 1, NEXT_DAY(SYSDATE, 'MONDAY'), 'ECON',
        v_bid, v_status, v_waitlist);
    DBMS_OUTPUT.PUT_LINE('Booking: ' || v_bid || ', Status: ' || v_status);
END;
/
```

### Cancel Ticket (as `crs_user`):
```sql
DECLARE v_msg VARCHAR2(500);
BEGIN
    crs_booking_pkg.cancel_ticket(10000, v_msg);
    DBMS_OUTPUT.PUT_LINE(v_msg);
END;
/
```

### Query Reports (as `crs_user`):
```sql
SELECT * FROM v_train_availability;
SELECT * FROM v_passenger_bookings;
SELECT * FROM v_daily_booking_summary;
SELECT * FROM v_waitlist_status;
SELECT * FROM v_revenue_report;
SELECT * FROM v_passenger_demographics;
```

---

## File Structure

```
CRS_Project/
├── README.md
├── documentation/
│   ├── CRS_ERD.png
│   ├── Business_Rules.pdf
│   └── Installation_Guide.pdf
└── scripts/
    ├── 01_CRS_Setup.sql                 # Schema and user creation
    ├── 02_CRS_Schema.sql                # Tables and constraints
    ├── 03_CRS_Reference_Data.sql        # Day schedule data
    ├── 04_CRS_Package.sql               # Package with business logic
    ├── 05_CRS_Views.sql                 # 6 reporting views
    ├── 06_CRS_Grants.sql                # Permissions
    ├── 07_CRS_Synonyms.sql              # Synonyms for crs_user
    ├── 08_CRS_Sample_Data.sql           # Sample trains and passengers
    ├── 09_CRS_Test_Cases.sql            # Comprehensive test suite
```

---

## Technologies Used

- Oracle Database 11g+
- PL/SQL for stored procedures, functions, and packages
- SQL for schema definition and queries
- Oracle SQL Developer for development and testing

---

## Project Team

**Course**: Database Management & Database Design  
**Institution**: Northeastern University  
**Date**: November 2024

---

## Key Achievements

✅ Complete two-schema security model  
✅ Comprehensive business logic validation  
✅ Automated fare discount calculation  
✅ Waitlist management with auto-promotion  
✅ 6 comprehensive reporting views  
✅ 18+ test cases covering all scenarios  
✅ Exception handling with meaningful error messages  
✅ Performance-optimized with strategic indexes  
✅ Re-runnable scripts for easy demonstration  

---

## Notes

- All scripts are designed to be **re-runnable** without errors
- The system enforces business rules through stored procedures, not direct data manipulation
- Security is demonstrated through the two-schema model where `crs_user` cannot bypass validation logic
- Fare discounts are automatically calculated based on passenger age at booking time
- The waitlist system automatically promotes passengers when confirmed tickets are cancelled