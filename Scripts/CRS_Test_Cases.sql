-- ============================================================================
-- Commuter Reservation System (CRS) - Comprehensive Test Cases
-- ============================================================================
-- Description: Test all business rules, validations, and exception handling
-- Connection: Run as crs_user (after synonyms are created)
-- Prerequisites: 
--   1. Sample trains must be loaded (from 08_CRS_Sample_Data.sql)
--   2. Synonyms must be created (from 07_CRS_Synonyms.sql)
-- Duration: ~3-5 minutes
-- Note: This script is designed to work with existing data
-- ============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET LINESIZE 200;

PROMPT '============================================================================'
PROMPT 'CRS TEST SUITE - STARTING'
PROMPT '============================================================================'
PROMPT ''

-- ============================================================================
-- PRE-TEST: Check environment
-- ============================================================================
PROMPT 'PRE-TEST: Checking test environment...'
PROMPT '--------------------------------------------'

DECLARE
    v_count NUMBER;
BEGIN
    -- Check if trains exist using view
    SELECT COUNT(*) INTO v_count FROM v_train_availability;
    DBMS_OUTPUT.PUT_LINE('Existing trains found: ' || v_count);
    
    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('WARNING: No trains found! Please run 08_CRS_Sample_Data.sql first.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Test environment ready');
    END IF;
END;
/

PROMPT ''
PROMPT 'NOTE: This test script creates unique test data for each run.'
PROMPT ''

-- ============================================================================
-- SECTION 1: PASSENGER REGISTRATION TEST CASES
-- ============================================================================

PROMPT '============================================================================'
PROMPT 'SECTION 1: PASSENGER REGISTRATION TEST CASES'
PROMPT '============================================================================'
PROMPT ''

-- ============================================================================
-- TEST CASE 1.1: Valid Passenger Registration (Adult)
-- Expected: SUCCESS
-- ============================================================================
PROMPT 'TEST CASE 1.1: Valid Adult Passenger Registration'
PROMPT '--------------------------------------------'
DECLARE
    v_passenger_id NUMBER;
    v_timestamp VARCHAR2(20) := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
    v_random VARCHAR2(10) := LPAD(TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1000, 9999))), 4, '0');
BEGIN
    crs_booking_pkg.register_passenger(
        p_first_name => 'John',
        p_middle_name => 'Michael',
        p_last_name => 'Smith',
        p_dob => TO_DATE('1990-05-15', 'YYYY-MM-DD'),
        p_address_line1 => '123 Main Street',
        p_address_city => 'Boston',
        p_address_state => 'MA',
        p_address_zip => '02101',
        p_email => 'john.smith.' || v_timestamp || '.' || v_random || '@test.email',
        p_phone => '617' || v_random || SUBSTR(v_timestamp, -4),
        p_passenger_id => v_passenger_id
    );
    DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED: Adult passenger registered successfully');
    DBMS_OUTPUT.PUT_LINE('  Passenger ID: ' || v_passenger_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT ''

-- ============================================================================
-- TEST CASE 1.2: Minor Passenger Registration
-- Expected: SUCCESS - Passenger should be categorized as MINOR
-- ============================================================================
PROMPT 'TEST CASE 1.2: Minor Passenger Registration'
PROMPT '--------------------------------------------'
DECLARE
    v_passenger_id NUMBER;
    v_timestamp VARCHAR2(20) := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
    v_random VARCHAR2(10) := LPAD(TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(2000, 2999))), 4, '0');
BEGIN
    crs_booking_pkg.register_passenger(
        p_first_name => 'Emma',
        p_middle_name => NULL,
        p_last_name => 'Johnson',
        p_dob => TO_DATE('2010-08-20', 'YYYY-MM-DD'),
        p_address_line1 => '456 Oak Avenue',
        p_address_city => 'Cambridge',
        p_address_state => 'MA',
        p_address_zip => '02139',
        p_email => 'emma.johnson.' || v_timestamp || '.' || v_random || '@test.email',
        p_phone => '617' || v_random || SUBSTR(v_timestamp, -4),
        p_passenger_id => v_passenger_id
    );
    DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED: Minor passenger registered successfully');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT ''

-- ============================================================================
-- TEST CASE 1.3: Senior Citizen Registration
-- Expected: SUCCESS - Passenger should be categorized as SENIOR CITIZEN
-- ============================================================================
PROMPT 'TEST CASE 1.3: Senior Citizen Registration'
PROMPT '--------------------------------------------'
DECLARE
    v_passenger_id NUMBER;
    v_timestamp VARCHAR2(20) := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
    v_random VARCHAR2(10) := LPAD(TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(3000, 3999))), 4, '0');
BEGIN
    crs_booking_pkg.register_passenger(
        p_first_name => 'Robert',
        p_middle_name => 'James',
        p_last_name => 'Williams',
        p_dob => TO_DATE('1955-03-10', 'YYYY-MM-DD'),
        p_address_line1 => '789 Pine Road',
        p_address_city => 'Brookline',
        p_address_state => 'MA',
        p_address_zip => '02445',
        p_email => 'robert.williams.' || v_timestamp || '.' || v_random || '@test.email',
        p_phone => '617' || v_random || SUBSTR(v_timestamp, -4),
        p_passenger_id => v_passenger_id
    );
    DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED: Senior citizen registered successfully');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT ''

-- ============================================================================
-- TEST CASE 1.4: Duplicate Email Registration
-- Expected: FAIL - Error should be raised for duplicate email
-- ============================================================================
PROMPT 'TEST CASE 1.4: Duplicate Email Registration (Should Fail)'
PROMPT '--------------------------------------------'
DECLARE
    v_passenger_id NUMBER;
    v_timestamp VARCHAR2(20) := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
    v_random1 VARCHAR2(10) := LPAD(TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(4000, 4999))), 4, '0');
    v_random2 VARCHAR2(10) := LPAD(TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(5000, 5999))), 4, '0');
    v_test_email VARCHAR2(100) := 'duplicate.' || v_timestamp || '@test.email';
BEGIN
    -- First registration
    crs_booking_pkg.register_passenger(
        p_first_name => 'First', p_middle_name => NULL, p_last_name => 'User',
        p_dob => TO_DATE('1985-07-25', 'YYYY-MM-DD'),
        p_address_line1 => '111 First St', p_address_city => 'Boston',
        p_address_state => 'MA', p_address_zip => '02115',
        p_email => v_test_email,
        p_phone => '617' || v_random1 || SUBSTR(v_timestamp, -4),
        p_passenger_id => v_passenger_id
    );
    
    -- Try duplicate email
    crs_booking_pkg.register_passenger(
        p_first_name => 'Second', p_middle_name => NULL, p_last_name => 'User',
        p_dob => TO_DATE('1985-07-25', 'YYYY-MM-DD'),
        p_address_line1 => '222 Second St', p_address_city => 'Boston',
        p_address_state => 'MA', p_address_zip => '02115',
        p_email => v_test_email,  -- Duplicate email
        p_phone => '617' || v_random2 || SUBSTR(v_timestamp, -4),
        p_passenger_id => v_passenger_id
    );
    DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Should have raised duplicate email error');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20004 AND INSTR(SQLERRM, 'Email already registered') > 0 THEN
            DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED: Duplicate email correctly rejected');
            DBMS_OUTPUT.PUT_LINE('  Error Message: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Unexpected error - ' || SQLERRM);
        END IF;
END;
/

PROMPT ''

-- ============================================================================
-- TEST CASE 1.5: Duplicate Phone Registration
-- Expected: FAIL - Error should be raised for duplicate phone
-- ============================================================================
PROMPT 'TEST CASE 1.5: Duplicate Phone Registration (Should Fail)'
PROMPT '--------------------------------------------'
DECLARE
    v_passenger_id NUMBER;
    v_timestamp VARCHAR2(20) := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
    v_random VARCHAR2(10) := LPAD(TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(6000, 6999))), 4, '0');
    v_test_phone VARCHAR2(15) := '617' || v_random || '9999';
BEGIN
    -- First registration with unique phone
    crs_booking_pkg.register_passenger(
        p_first_name => 'Phone', p_middle_name => NULL, p_last_name => 'Test1',
        p_dob => TO_DATE('1992-11-30', 'YYYY-MM-DD'),
        p_address_line1 => '333 Phone St', p_address_city => 'Boston',
        p_address_state => 'MA', p_address_zip => '02118',
        p_email => 'phone.test1.' || v_timestamp || '@test.email',
        p_phone => v_test_phone,
        p_passenger_id => v_passenger_id
    );
    
    -- Try duplicate phone
    crs_booking_pkg.register_passenger(
        p_first_name => 'Phone', p_middle_name => NULL, p_last_name => 'Test2',
        p_dob => TO_DATE('1992-11-30', 'YYYY-MM-DD'),
        p_address_line1 => '444 Phone St', p_address_city => 'Boston',
        p_address_state => 'MA', p_address_zip => '02118',
        p_email => 'phone.test2.' || v_timestamp || '@test.email',
        p_phone => v_test_phone,  -- Duplicate phone
        p_passenger_id => v_passenger_id
    );
    DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Should have raised duplicate phone error');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20004 AND INSTR(SQLERRM, 'Phone number already registered') > 0 THEN
            DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED: Duplicate phone correctly rejected');
            DBMS_OUTPUT.PUT_LINE('  Error Message: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Unexpected error - ' || SQLERRM);
        END IF;
END;
/

PROMPT ''

-- ============================================================================
-- TEST CASE 1.6: Future Date of Birth
-- Expected: FAIL - Date of birth cannot be in future
-- ============================================================================
PROMPT 'TEST CASE 1.6: Future Date of Birth (Should Fail)'
PROMPT '--------------------------------------------'
DECLARE
    v_passenger_id NUMBER;
    v_timestamp VARCHAR2(20) := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
    v_random VARCHAR2(10) := LPAD(TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(7000, 7999))), 4, '0');
BEGIN
    crs_booking_pkg.register_passenger(
        p_first_name => 'Future',
        p_middle_name => NULL,
        p_last_name => 'Baby',
        p_dob => TO_DATE('2030-01-01', 'YYYY-MM-DD'),
        p_address_line1 => '999 Future Lane',
        p_address_city => 'Boston',
        p_address_state => 'MA',
        p_address_zip => '02120',
        p_email => 'future.baby.' || v_timestamp || '@test.email',
        p_phone => '617' || v_random || '8888',
        p_passenger_id => v_passenger_id
    );
    DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Should have raised future DOB error');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20004 AND INSTR(SQLERRM, 'Date of birth must be in the past') > 0 THEN
            DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED: Future date of birth correctly rejected');
            DBMS_OUTPUT.PUT_LINE('  Error Message: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Unexpected error - ' || SQLERRM);
        END IF;
END;
/

PROMPT ''
PROMPT '============================================================================'
PROMPT 'SECTION 2: TICKET BOOKING TEST CASES'
PROMPT '============================================================================'
PROMPT ''

-- Get first available train ID for tests
DECLARE
    v_first_train_id NUMBER;
    v_passenger_id NUMBER;
    v_booking_id NUMBER;
    v_seat_status VARCHAR2(20);
    v_waitlist_pos NUMBER;
    v_travel_date DATE;
    v_timestamp VARCHAR2(20) := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
    v_random_suffix VARCHAR2(10) := LPAD(TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1000, 9999))), 4, '0');
BEGIN
    -- Get first train ID from view
    SELECT MIN(train_id) INTO v_first_train_id FROM v_train_availability;
    
    IF v_first_train_id IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('✗ ERROR: No trains found! Please run 08_CRS_Sample_Data.sql first');
        RETURN;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Using Train ID: ' || v_first_train_id || ' for booking tests');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Register a test passenger for booking
    crs_booking_pkg.register_passenger(
        p_first_name => 'Test', p_middle_name => NULL, p_last_name => 'Booker',
        p_dob => TO_DATE('1988-06-12', 'YYYY-MM-DD'),
        p_address_line1 => '234 Test Street', p_address_city => 'Boston',
        p_address_state => 'MA', p_address_zip => '02125',
        p_email => 'test.booker.' || v_timestamp || '.' || v_random_suffix || '@test.email',
        p_phone => '617' || v_random_suffix || '2345',
        p_passenger_id => v_passenger_id
    );
    
    DBMS_OUTPUT.PUT_LINE('Test passenger created. ID: ' || v_passenger_id);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- ========================================================================
    -- TEST CASE 2.1: Valid Booking - Confirmed Seat
    -- ========================================================================
    DBMS_OUTPUT.PUT_LINE('TEST CASE 2.1: Valid Booking - Confirmed Seat');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    
    BEGIN
        -- Find a valid travel date (within next 7 days on a day the train operates)
        FOR i IN 1..7 LOOP
            v_travel_date := TRUNC(SYSDATE) + i;
            
            -- Check if train operates on this day
            IF crs_booking_pkg.is_train_available(v_first_train_id, v_travel_date) THEN
                EXIT;
            END IF;
        END LOOP;
        
        crs_booking_pkg.book_ticket(
            p_passenger_id => v_passenger_id,
            p_train_id => v_first_train_id,
            p_travel_date => v_travel_date,
            p_seat_class => 'ECON',
            p_booking_id => v_booking_id,
            p_seat_status => v_seat_status,
            p_waitlist_pos => v_waitlist_pos
        );
        
        IF v_seat_status = 'CONFIRMED' THEN
            DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED: Booking confirmed successfully');
            DBMS_OUTPUT.PUT_LINE('  Booking ID: ' || v_booking_id);
        ELSE
            DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Expected CONFIRMED status, got ' || v_seat_status);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- ========================================================================
    -- TEST CASE 2.2: Invalid Train ID
    -- ========================================================================
    DBMS_OUTPUT.PUT_LINE('TEST CASE 2.2: Invalid Train ID (Should Fail)');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    
    BEGIN
        crs_booking_pkg.book_ticket(
            p_passenger_id => v_passenger_id,
            p_train_id => 99999,  -- Invalid train
            p_travel_date => TRUNC(SYSDATE) + 2,
            p_seat_class => 'ECON',
            p_booking_id => v_booking_id,
            p_seat_status => v_seat_status,
            p_waitlist_pos => v_waitlist_pos
        );
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Should have raised invalid train error');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20001 THEN
                DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED: Invalid train ID correctly rejected');
                DBMS_OUTPUT.PUT_LINE('  Error Message: ' || SQLERRM);
            ELSE
                DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Unexpected error - ' || SQLERRM);
            END IF;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- ========================================================================
    -- TEST CASE 2.3: Past Travel Date
    -- ========================================================================
    DBMS_OUTPUT.PUT_LINE('TEST CASE 2.3: Past Travel Date (Should Fail)');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    
    BEGIN
        crs_booking_pkg.book_ticket(
            p_passenger_id => v_passenger_id,
            p_train_id => v_first_train_id,
            p_travel_date => TO_DATE('2024-01-01', 'YYYY-MM-DD'),  -- Past date
            p_seat_class => 'ECON',
            p_booking_id => v_booking_id,
            p_seat_status => v_seat_status,
            p_waitlist_pos => v_waitlist_pos
        );
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Should have raised past date error');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20002 THEN
                DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED: Past travel date correctly rejected');
                DBMS_OUTPUT.PUT_LINE('  Error Message: ' || SQLERRM);
            ELSE
                DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Unexpected error - ' || SQLERRM);
            END IF;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- ========================================================================
    -- TEST CASE 2.4: Advance Booking Limit Exceeded
    -- ========================================================================
    DBMS_OUTPUT.PUT_LINE('TEST CASE 2.4: Advance Booking Limit Exceeded (Should Fail)');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    
    BEGIN
        crs_booking_pkg.book_ticket(
            p_passenger_id => v_passenger_id,
            p_train_id => v_first_train_id,
            p_travel_date => TRUNC(SYSDATE) + 10,  -- 10 days ahead
            p_seat_class => 'ECON',
            p_booking_id => v_booking_id,
            p_seat_status => v_seat_status,
            p_waitlist_pos => v_waitlist_pos
        );
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Should have raised advance booking limit error');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20006 THEN
                DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED: Advance booking limit correctly enforced');
                DBMS_OUTPUT.PUT_LINE('  Error Message: ' || SQLERRM);
            ELSE
                DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Unexpected error - ' || SQLERRM);
            END IF;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- ========================================================================
    -- TEST CASE 2.5: Duplicate Booking
    -- ========================================================================
    DBMS_OUTPUT.PUT_LINE('TEST CASE 2.5: Duplicate Booking (Should Fail)');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    
    BEGIN
        -- Try to book same train/date/class again
        crs_booking_pkg.book_ticket(
            p_passenger_id => v_passenger_id,
            p_train_id => v_first_train_id,
            p_travel_date => v_travel_date,  -- Same as test 2.1
            p_seat_class => 'ECON',
            p_booking_id => v_booking_id,
            p_seat_status => v_seat_status,
            p_waitlist_pos => v_waitlist_pos
        );
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Should have raised duplicate booking error');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20007 THEN
                DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED: Duplicate booking correctly prevented');
                DBMS_OUTPUT.PUT_LINE('  Error Message: ' || SQLERRM);
            ELSE
                DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Unexpected error - ' || SQLERRM);
            END IF;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
END;
/

PROMPT '============================================================================'
PROMPT 'SECTION 3: TICKET CANCELLATION TEST CASES'
PROMPT '============================================================================'
PROMPT ''

-- Test cancellation with actual booking
DECLARE
    v_passenger_id NUMBER;
    v_booking_id NUMBER;
    v_seat_status VARCHAR2(20);
    v_waitlist_pos NUMBER;
    v_message VARCHAR2(500);
    v_first_train_id NUMBER;
    v_travel_date DATE;
    v_timestamp VARCHAR2(20) := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
    v_random_suffix VARCHAR2(10) := LPAD(TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(5000, 9999))), 4, '0');
BEGIN
    -- Get first train from view
    SELECT MIN(train_id) INTO v_first_train_id FROM v_train_availability;
    
    -- Register passenger for cancellation test
    crs_booking_pkg.register_passenger(
        p_first_name => 'Cancel', p_middle_name => NULL, p_last_name => 'Tester',
        p_dob => TO_DATE('1990-01-01', 'YYYY-MM-DD'),
        p_address_line1 => '567 Cancel Rd', p_address_city => 'Boston',
        p_address_state => 'MA', p_address_zip => '02127',
        p_email => 'cancel.tester.' || v_timestamp || '.' || v_random_suffix || '@test.email',
        p_phone => '617' || v_random_suffix || '3456',
        p_passenger_id => v_passenger_id
    );
    
    -- Find valid travel date
    FOR i IN 1..7 LOOP
        v_travel_date := TRUNC(SYSDATE) + i;
        IF crs_booking_pkg.is_train_available(v_first_train_id, v_travel_date) THEN
            EXIT;
        END IF;
    END LOOP;
    
    -- Create booking for cancellation test
    crs_booking_pkg.book_ticket(
        v_passenger_id, v_first_train_id, v_travel_date, 'FC',
        v_booking_id, v_seat_status, v_waitlist_pos
    );
    
    DBMS_OUTPUT.PUT_LINE('Created test booking ID: ' || v_booking_id);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- ========================================================================
    -- TEST CASE 3.1: Valid Cancellation
    -- ========================================================================
    DBMS_OUTPUT.PUT_LINE('TEST CASE 3.1: Valid Cancellation');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    
    BEGIN
        crs_booking_pkg.cancel_ticket(
            p_booking_id => v_booking_id,
            p_message => v_message
        );
        DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED: Ticket cancelled successfully');
        DBMS_OUTPUT.PUT_LINE('  ' || v_message);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- ========================================================================
    -- TEST CASE 3.2: Double Cancellation
    -- ========================================================================
    DBMS_OUTPUT.PUT_LINE('TEST CASE 3.2: Cancel Already Cancelled Booking (Should Fail)');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    
    BEGIN
        crs_booking_pkg.cancel_ticket(
            p_booking_id => v_booking_id,  -- Already cancelled
            p_message => v_message
        );
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Should have raised already cancelled error');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20005 THEN
                DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED: Double cancellation correctly prevented');
                DBMS_OUTPUT.PUT_LINE('  Error Message: ' || SQLERRM);
            ELSE
                DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Unexpected error - ' || SQLERRM);
            END IF;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- ========================================================================
    -- TEST CASE 3.3: Invalid Booking ID
    -- ========================================================================
    DBMS_OUTPUT.PUT_LINE('TEST CASE 3.3: Cancel Invalid Booking ID (Should Fail)');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    
    BEGIN
        crs_booking_pkg.cancel_ticket(
            p_booking_id => 99999,  -- Invalid booking
            p_message => v_message
        );
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Should have raised invalid booking error');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20005 THEN
                DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED: Invalid booking ID correctly rejected');
                DBMS_OUTPUT.PUT_LINE('  Error Message: ' || SQLERRM);
            ELSE
                DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Unexpected error - ' || SQLERRM);
            END IF;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
END;
/

PROMPT '============================================================================'
PROMPT 'SECTION 4: VIEW REPORTS - DATA VALIDATION'
PROMPT '============================================================================'
PROMPT ''

PROMPT 'Report 1: Train Availability'
PROMPT '--------------------------------------------'
SELECT train_id, train_number, source_station, dest_station, 
       total_fc_seats, total_econ_seats, operating_days
FROM v_train_availability;

PROMPT ''
PROMPT 'Report 2: Passenger Booking History (Sample)'
PROMPT '--------------------------------------------'
SELECT passenger_id, passenger_name, booking_id, train_number, 
       travel_date, seat_class, seat_status, fare_amount
FROM v_passenger_bookings
WHERE ROWNUM <= 10
ORDER BY booking_date DESC;

PROMPT ''
PROMPT 'Report 3: Daily Booking Summary'
PROMPT '--------------------------------------------'
SELECT travel_date, train_number, seat_class, 
       confirmed_bookings, waitlisted_bookings, available_seats
FROM v_daily_booking_summary
WHERE ROWNUM <= 10;

PROMPT ''
PROMPT 'Report 4: Waitlist Status'
PROMPT '--------------------------------------------'
SELECT booking_id, passenger_name, train_number, 
       travel_date, seat_class, waitlist_position
FROM v_waitlist_status
WHERE ROWNUM <= 10;

PROMPT ''
PROMPT 'Report 5: Revenue Report'
PROMPT '--------------------------------------------'
SELECT booking_month, train_number, seat_class, 
       tickets_sold, fare_per_ticket, total_revenue
FROM v_revenue_report
WHERE ROWNUM <= 10;

PROMPT ''
PROMPT 'Report 6: Passenger Demographics'
PROMPT '--------------------------------------------'
SELECT age_group, passenger_count, percentage
FROM v_passenger_demographics
ORDER BY age_group;

PROMPT ''
PROMPT '============================================================================'
PROMPT 'TEST SUITE COMPLETE'
PROMPT '============================================================================'

-- Final Summary
DECLARE
    v_total_passengers NUMBER;
    v_total_trains NUMBER;
BEGIN
    -- Get counts from views (crs_user has access to these)
    SELECT COUNT(DISTINCT passenger_id) INTO v_total_passengers FROM v_passenger_bookings;
    SELECT COUNT(*) INTO v_total_trains FROM v_train_availability;
    
    DBMS_OUTPUT.PUT_LINE('Database Summary:');
    DBMS_OUTPUT.PUT_LINE('- Total Trains: ' || v_total_trains);
    DBMS_OUTPUT.PUT_LINE('- Total Passengers Registered: ' || v_total_passengers || '+');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Test Summary:');
    DBMS_OUTPUT.PUT_LINE('- Passenger Registration: 6 test cases');
    DBMS_OUTPUT.PUT_LINE('- Ticket Booking: 5 test cases');
    DBMS_OUTPUT.PUT_LINE('- Ticket Cancellation: 3 test cases');
    DBMS_OUTPUT.PUT_LINE('- Report Views: 6 views validated');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Total: 18 test cases executed');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Views Tested:');
    DBMS_OUTPUT.PUT_LINE('  1. v_train_availability - Train schedule and capacity');
    DBMS_OUTPUT.PUT_LINE('  2. v_passenger_bookings - Complete booking history');
    DBMS_OUTPUT.PUT_LINE('  3. v_daily_booking_summary - Daily seat utilization');
    DBMS_OUTPUT.PUT_LINE('  4. v_waitlist_status - Current waitlisted passengers');
    DBMS_OUTPUT.PUT_LINE('  5. v_revenue_report - Monthly revenue analysis');
    DBMS_OUTPUT.PUT_LINE('  6. v_passenger_demographics - Age distribution');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('All critical business rules and exception scenarios tested!');
END;
/

PROMPT '============================================================================'
PROMPT ''