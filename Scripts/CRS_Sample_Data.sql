-- ============================================================================
-- CRS Sample Data - Complete Reset and Reload
-- ============================================================================
-- Description: Clears all data and loads fresh sample trains and passengers
-- Connection: Run as crs_admin
-- Purpose: Creates clean base data for the CRS system
-- Note: This script is re-runnable - clears old data before loading new
-- ============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

-- ============================================================================
-- SECTION 1: Clear Existing Data
-- ============================================================================

PROMPT 'STEP 1: Clearing existing data...'
PROMPT ''

DECLARE
    v_res_count NUMBER;
    v_pass_count NUMBER;
    v_tsch_count NUMBER;
    v_train_count NUMBER;
BEGIN
    -- Show current counts
    SELECT COUNT(*) INTO v_res_count FROM crs_reservation;
    SELECT COUNT(*) INTO v_pass_count FROM crs_passenger;
    SELECT COUNT(*) INTO v_tsch_count FROM crs_train_schedule;
    SELECT COUNT(*) INTO v_train_count FROM crs_train_info;
    
    DBMS_OUTPUT.PUT_LINE('Current data:');
    DBMS_OUTPUT.PUT_LINE('  Reservations: ' || v_res_count);
    DBMS_OUTPUT.PUT_LINE('  Passengers: ' || v_pass_count);
    DBMS_OUTPUT.PUT_LINE('  Train schedules: ' || v_tsch_count);
    DBMS_OUTPUT.PUT_LINE('  Trains: ' || v_train_count);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Delete in correct order
    DELETE FROM crs_reservation;
    DBMS_OUTPUT.PUT_LINE('✓ Deleted ' || SQL%ROWCOUNT || ' reservations');
    
    DELETE FROM crs_passenger;
    DBMS_OUTPUT.PUT_LINE('✓ Deleted ' || SQL%ROWCOUNT || ' passengers');
    
    DELETE FROM crs_train_schedule;
    DBMS_OUTPUT.PUT_LINE('✓ Deleted ' || SQL%ROWCOUNT || ' train schedules');
    
    DELETE FROM crs_train_info;
    DBMS_OUTPUT.PUT_LINE('✓ Deleted ' || SQL%ROWCOUNT || ' trains');
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('All data cleared successfully!');
END;
/

PROMPT ''

-- ============================================================================
-- SECTION 2: Load Sample Trains
-- ============================================================================

PROMPT '============================================================================'
PROMPT 'STEP 2: Loading sample trains...'
PROMPT '============================================================================'
PROMPT ''

DECLARE
    v_train_id NUMBER;
BEGIN
    -- Train 1: Boston to New York (Weekdays only)
    crs_booking_pkg.add_train(
        p_train_number => 'NE-101',
        p_source_station => 'Boston South Station',
        p_dest_station => 'New York Penn Station',
        p_fc_fare => 150.00,
        p_econ_fare => 75.00,
        p_train_id => v_train_id
    );
    
    crs_booking_pkg.add_train_schedule(
        p_train_id => v_train_id,
        p_days => 'MONDAY,TUESDAY,WEDNESDAY,THURSDAY,FRIDAY'
    );
    
    DBMS_OUTPUT.PUT_LINE('✓ Train 1 created: NE-101 (Weekdays, ID: ' || v_train_id || ')');
    
    -- Train 2: Boston to Washington DC (All days)
    crs_booking_pkg.add_train(
        p_train_number => 'NE-202',
        p_source_station => 'Boston South Station',
        p_dest_station => 'Washington Union Station',
        p_fc_fare => 200.00,
        p_econ_fare => 100.00,
        p_train_id => v_train_id
    );
    
    crs_booking_pkg.add_train_schedule(
        p_train_id => v_train_id,
        p_days => 'MONDAY,TUESDAY,WEDNESDAY,THURSDAY,FRIDAY,SATURDAY,SUNDAY'
    );
    
    DBMS_OUTPUT.PUT_LINE('✓ Train 2 created: NE-202 (All days, ID: ' || v_train_id || ')');
    
    -- Train 3: Philadelphia to Boston (Weekends only)
    crs_booking_pkg.add_train(
        p_train_number => 'NE-303',
        p_source_station => 'Philadelphia 30th Street',
        p_dest_station => 'Boston South Station',
        p_fc_fare => 120.00,
        p_econ_fare => 60.00,
        p_train_id => v_train_id
    );
    
    crs_booking_pkg.add_train_schedule(
        p_train_id => v_train_id,
        p_days => 'SATURDAY,SUNDAY'
    );
    
    DBMS_OUTPUT.PUT_LINE('✓ Train 3 created: NE-303 (Weekends, ID: ' || v_train_id || ')');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('All trains loaded successfully!');
END;
/

PROMPT ''

-- ============================================================================
-- SECTION 3: Load Sample Passengers
-- ============================================================================

PROMPT '============================================================================'
PROMPT 'STEP 3: Loading sample passengers...'
PROMPT '============================================================================'
PROMPT ''

DECLARE
    v_passenger_id NUMBER;
BEGIN
    -- Passenger 1: Adult
    crs_booking_pkg.register_passenger(
        p_first_name => 'John',
        p_middle_name => 'Michael',
        p_last_name => 'Smith',
        p_dob => TO_DATE('1990-05-15', 'YYYY-MM-DD'),
        p_address_line1 => '123 Main Street',
        p_address_city => 'Boston',
        p_address_state => 'MA',
        p_address_zip => '02101',
        p_email => 'john.smith@example.com',
        p_phone => '6171234567',
        p_passenger_id => v_passenger_id
    );
    
    DBMS_OUTPUT.PUT_LINE('✓ Adult passenger created: John Smith (ID: ' || v_passenger_id || ')');
    
    -- Passenger 2: Minor
    crs_booking_pkg.register_passenger(
        p_first_name => 'Emma',
        p_middle_name => NULL,
        p_last_name => 'Johnson',
        p_dob => TO_DATE('2010-08-20', 'YYYY-MM-DD'),
        p_address_line1 => '456 Oak Avenue',
        p_address_city => 'Cambridge',
        p_address_state => 'MA',
        p_address_zip => '02139',
        p_email => 'emma.johnson@example.com',
        p_phone => '6179876543',
        p_passenger_id => v_passenger_id
    );
    
    DBMS_OUTPUT.PUT_LINE('✓ Minor passenger created: Emma Johnson (ID: ' || v_passenger_id || ')');
    
    -- Passenger 3: Senior Citizen
    crs_booking_pkg.register_passenger(
        p_first_name => 'Robert',
        p_middle_name => 'James',
        p_last_name => 'Williams',
        p_dob => TO_DATE('1955-03-10', 'YYYY-MM-DD'),
        p_address_line1 => '789 Pine Road',
        p_address_city => 'Brookline',
        p_address_state => 'MA',
        p_address_zip => '02445',
        p_email => 'robert.williams@example.com',
        p_phone => '6175551234',
        p_passenger_id => v_passenger_id
    );
    
    DBMS_OUTPUT.PUT_LINE('✓ Senior passenger created: Robert Williams (ID: ' || v_passenger_id || ')');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('All sample passengers loaded!');
END;
/

PROMPT ''

-- ============================================================================
-- SECTION 4: Create Sample Bookings
-- ============================================================================

PROMPT '============================================================================'
PROMPT 'STEP 4: Creating sample bookings...'
PROMPT '============================================================================'
PROMPT ''

DECLARE
    v_booking_id NUMBER;
    v_seat_status VARCHAR2(20);
    v_waitlist_pos NUMBER;
    v_first_train NUMBER;
    v_first_passenger NUMBER;
    v_second_passenger NUMBER;
    v_travel_date DATE;
BEGIN
    -- Get actual train and passenger IDs from database
    SELECT MIN(train_id) INTO v_first_train FROM crs_train_info;
    SELECT MIN(passenger_id) INTO v_first_passenger FROM crs_passenger;
    SELECT MIN(passenger_id) INTO v_second_passenger 
    FROM crs_passenger WHERE passenger_id > v_first_passenger;
    
    -- Get valid travel date (next Monday)
    v_travel_date := NEXT_DAY(TRUNC(SYSDATE), 'MONDAY');
    
    DBMS_OUTPUT.PUT_LINE('Using Train ID: ' || v_first_train);
    DBMS_OUTPUT.PUT_LINE('Travel Date: ' || TO_CHAR(v_travel_date, 'DD-MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Booking 1: For first passenger (Adult - shows full fare)
    crs_booking_pkg.book_ticket(
        p_passenger_id => v_first_passenger,
        p_train_id => v_first_train,
        p_travel_date => v_travel_date,
        p_seat_class => 'ECON',
        p_booking_id => v_booking_id,
        p_seat_status => v_seat_status,
        p_waitlist_pos => v_waitlist_pos
    );
    
    DBMS_OUTPUT.PUT_LINE('✓ Booking 1 created: ID ' || v_booking_id);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Booking 2: For second passenger (Minor - shows 50% discount)
    crs_booking_pkg.book_ticket(
        p_passenger_id => v_second_passenger,
        p_train_id => v_first_train,
        p_travel_date => NEXT_DAY(v_travel_date, 'TUESDAY'),
        p_seat_class => 'FC',
        p_booking_id => v_booking_id,
        p_seat_status => v_seat_status,
        p_waitlist_pos => v_waitlist_pos
    );
    
    DBMS_OUTPUT.PUT_LINE('✓ Booking 2 created: ID ' || v_booking_id);
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Sample bookings created successfully!');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('⚠ Error creating bookings: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('  (You can create bookings manually later)');
END;
/

PROMPT ''

-- ============================================================================
-- SECTION 5: Verification
-- ============================================================================

PROMPT '============================================================================'
PROMPT 'SAMPLE DATA VERIFICATION'
PROMPT '============================================================================'
PROMPT ''

PROMPT 'Trains Loaded:'
PROMPT '--------------'
SELECT train_id, train_number, source_station, dest_station, 
       fc_seat_fare, econ_seat_fare
FROM crs_train_info
ORDER BY train_id;

PROMPT ''
PROMPT 'Passengers Loaded:'
PROMPT '------------------'
SELECT passenger_id, 
       first_name || ' ' || last_name AS name,
       email,
       FLOOR(MONTHS_BETWEEN(SYSDATE, date_of_birth) / 12) AS age,
       CASE 
           WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, date_of_birth) / 12) < 18 THEN 'MINOR'
           WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, date_of_birth) / 12) >= 60 THEN 'SENIOR'
           ELSE 'ADULT'
       END AS category
FROM crs_passenger
ORDER BY passenger_id;

PROMPT ''
PROMPT 'Bookings Created:'
PROMPT '-----------------'
SELECT booking_id, passenger_id, train_id, travel_date, 
       seat_class, seat_status
FROM crs_reservation
ORDER BY booking_id;

PROMPT ''

-- ============================================================================
-- SECTION 6: Summary
-- ============================================================================

DECLARE
    v_trains NUMBER;
    v_passengers NUMBER;
    v_bookings NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_trains FROM crs_train_info;
    SELECT COUNT(*) INTO v_passengers FROM crs_passenger;
    SELECT COUNT(*) INTO v_bookings FROM crs_reservation;
    
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('SAMPLE DATA LOADING COMPLETE');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Summary:');
    DBMS_OUTPUT.PUT_LINE('  - Trains: ' || v_trains);
    DBMS_OUTPUT.PUT_LINE('  - Passengers: ' || v_passengers);
    DBMS_OUTPUT.PUT_LINE('  - Bookings: ' || v_bookings);
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('System is ready!');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Next Steps:');
    DBMS_OUTPUT.PUT_LINE('  1. Add more passengers manually (optional)');
    DBMS_OUTPUT.PUT_LINE('  2. Create additional bookings (optional)');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
END;
/

PROMPT ''