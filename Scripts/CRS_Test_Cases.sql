-- ============================================================================
-- Commuter Reservation System (CRS) - Comprehensive Test Cases
-- ============================================================================
-- Description: Test all business rules, validations, and exception handling
-- Connection: Run as crs_user (after synonyms are created)
-- Duration: ~3-5 minutes
-- ============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET LINESIZE 200;

PROMPT '============================================================================'
PROMPT 'CRS TEST SUITE - STARTING'
PROMPT '============================================================================'
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
        p_email => 'john.smith@email.com',
        p_phone => '6171234567',
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
        p_email => 'emma.johnson@email.com',
        p_phone => '6179876543',
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
        p_email => 'robert.williams@email.com',
        p_phone => '6175551234',
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
BEGIN
    crs_booking_pkg.register_passenger(
        p_first_name => 'Jane',
        p_middle_name => NULL,
        p_last_name => 'Doe',
        p_dob => TO_DATE('1985-07-25', 'YYYY-MM-DD'),
        p_address_line1 => '321 Elm Street',
        p_address_city => 'Boston',
        p_address_state => 'MA',
        p_address_zip => '02115',
        p_email => 'john.smith@email.com',  -- Duplicate email
        p_phone => '6175559999',
        p_passenger_id => v_passenger_id
    );
    DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Should have raised duplicate email error');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20004 THEN
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
BEGIN
    crs_booking_pkg.register_passenger(
        p_first_name => 'Sarah',
        p_middle_name => NULL,
        p_last_name => 'Brown',
        p_dob => TO_DATE('1992-11-30', 'YYYY-MM-DD'),
        p_address_line1 => '555 Maple Drive',
        p_address_city => 'Boston',
        p_address_state => 'MA',
        p_address_zip => '02118',
        p_email => 'sarah.brown@email.com',
        p_phone => '6171234567',  -- Duplicate phone
        p_passenger_id => v_passenger_id
    );
    DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Should have raised duplicate phone error');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20004 THEN
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
        p_email => 'future.baby@email.com',
        p_phone => '6175558888',
        p_passenger_id => v_passenger_id
    );
    DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Should have raised future DOB error');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20004 THEN
            DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED: Future date of birth correctly rejected');
            DBMS_OUTPUT.PUT_LINE('  Error Message: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Unexpected error - ' || SQLERRM);
        END IF;
END;
/

PROMPT ''

-- Register additional valid passengers for booking tests
PROMPT 'Setting up additional test passengers...'
DECLARE
    v_passenger_id NUMBER;
BEGIN
    -- Passenger for booking tests
    crs_booking_pkg.register_passenger(
        p_first_name => 'Alice', p_middle_name => NULL, p_last_name => 'Davis',
        p_dob => TO_DATE('1988-06-12', 'YYYY-MM-DD'),
        p_address_line1 => '234 River Street', p_address_city => 'Boston',
        p_address_state => 'MA', p_address_zip => '02125',
        p_email => 'alice.davis@email.com', p_phone => '6175552345',
        p_passenger_id => v_passenger_id
    );
    
    crs_booking_pkg.register_passenger(
        p_first_name => 'Michael', p_middle_name => 'Peter', p_last_name => 'Taylor',
        p_dob => TO_DATE('1975-09-18', 'YYYY-MM-DD'),
        p_address_line1 => '567 Harbor Drive', p_address_city => 'Boston',
        p_address_state => 'MA', p_address_zip => '02127',
        p_email => 'michael.taylor@email.com', p_phone => '6175553456',
        p_passenger_id => v_passenger_id
    );
    
    DBMS_OUTPUT.PUT_LINE('Additional test passengers created');
END;
/

PROMPT ''
PROMPT '============================================================================'
PROMPT 'SECTION 2: TICKET BOOKING TEST CASES'
PROMPT '============================================================================'
PROMPT ''

-- ============================================================================
-- TEST CASE 2.1: Valid Booking - Confirmed Seat
-- Expected: SUCCESS - First booking should be confirmed
-- ============================================================================
PROMPT 'TEST CASE 2.1: Valid Booking - Confirmed Seat'
PROMPT '--------------------------------------------'
DECLARE
    v_booking_id NUMBER;
    v_seat_status VARCHAR2(20);
    v_waitlist_pos NUMBER;
    v_travel_date DATE;
BEGIN
    -- Book for next Monday
    v_travel_date := NEXT_DAY(TRUNC(SYSDATE), 'MONDAY');
    
    crs_booking_pkg.book_ticket(
        p_passenger_id => 1000,  -- John Smith
        p_train_id => 1,         -- NE-101 (Boston to NY)
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
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Expected CONFIRMED status');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT ''

-- ============================================================================
-- TEST CASE 2.2: Invalid Train ID
-- Expected: FAIL - Train does not exist
-- ============================================================================
PROMPT 'TEST CASE 2.2: Invalid Train ID (Should Fail)'
PROMPT '--------------------------------------------'
DECLARE
    v_booking_id NUMBER;
    v_seat_status VARCHAR2(20);
    v_waitlist_pos NUMBER;
    v_travel_date DATE;
BEGIN
    v_travel_date := NEXT_DAY(TRUNC(SYSDATE), 'MONDAY');
    
    crs_booking_pkg.book_ticket(
        p_passenger_id => 1000,
        p_train_id => 9999,  -- Invalid train
        p_travel_date => v_travel_date,
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
/

PROMPT ''

-- ============================================================================
-- TEST CASE 2.3: Past Travel Date
-- Expected: FAIL - Cannot book for past dates
-- ============================================================================
PROMPT 'TEST CASE 2.3: Past Travel Date (Should Fail)'
PROMPT '--------------------------------------------'
DECLARE
    v_booking_id NUMBER;
    v_seat_status VARCHAR2(20);
    v_waitlist_pos NUMBER;
BEGIN
    crs_booking_pkg.book_ticket(
        p_passenger_id => 1000,
        p_train_id => 1,
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
/

PROMPT ''

-- ============================================================================
-- TEST CASE 2.4: Advance Booking Limit Exceeded
-- Expected: FAIL - Cannot book more than 7 days in advance
-- ============================================================================
PROMPT 'TEST CASE 2.4: Advance Booking Limit Exceeded (Should Fail)'
PROMPT '--------------------------------------------'
DECLARE
    v_booking_id NUMBER;
    v_seat_status VARCHAR2(20);
    v_waitlist_pos NUMBER;
BEGIN
    crs_booking_pkg.book_ticket(
        p_passenger_id => 1000,
        p_train_id => 1,
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
/

PROMPT ''

-- ============================================================================
-- TEST CASE 2.5: Train Not Operating on Selected Day
-- Expected: FAIL - Train NE-101 operates only on weekdays
-- ============================================================================
PROMPT 'TEST CASE 2.5: Train Not Operating on Selected Day (Should Fail)'
PROMPT '--------------------------------------------'
DECLARE
    v_booking_id NUMBER;
    v_seat_status VARCHAR2(20);
    v_waitlist_pos NUMBER;
    v_travel_date DATE;
BEGIN
    -- Try to book on Saturday (NE-101 is weekdays only)
    v_travel_date := NEXT_DAY(TRUNC(SYSDATE), 'SATURDAY');
    
    crs_booking_pkg.book_ticket(
        p_passenger_id => 1000,
        p_train_id => 1,  -- NE-101 (weekdays only)
        p_travel_date => v_travel_date,
        p_seat_class => 'ECON',
        p_booking_id => v_booking_id,
        p_seat_status => v_seat_status,
        p_waitlist_pos => v_waitlist_pos
    );
    DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Should have raised train not available error');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20001 THEN
            DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED: Train availability correctly validated');
            DBMS_OUTPUT.PUT_LINE('  Error Message: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: Unexpected error - ' || SQLERRM);
        END IF;
END;
/

PROMPT ''

-- ============================================================================
-- TEST CASE 2.6: Duplicate Booking
-- Expected: FAIL - Passenger already has booking for same train/date/class
-- ============================================================================
PROMPT 'TEST CASE 2.6: Duplicate Booking (Should Fail)'
PROMPT '--------------------------------------------'
DECLARE
    v_booking_id NUMBER;
    v_seat_status VARCHAR2(20);
    v_waitlist_pos NUMBER;
    v_travel_date DATE;
BEGIN
    v_travel_date := NEXT_DAY(TRUNC(SYSDATE), 'MONDAY');
    
    -- Try to book same train/date/class again
    crs_booking_pkg.book_ticket(
        p_passenger_id => 1000,  -- Already has booking
        p_train_id => 1,
        p_travel_date => v_travel_date,
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
/

PROMPT ''
PROMPT '============================================================================'
PROMPT 'SECTION 3: TICKET CANCELLATION TEST CASES'
PROMPT '============================================================================'
PROMPT ''

-- ============================================================================
-- TEST CASE 3.1: Valid Cancellation
-- Expected: SUCCESS - Ticket cancelled
-- ============================================================================
PROMPT 'TEST CASE 3.1: Valid Cancellation'
PROMPT '--------------------------------------------'
DECLARE
    v_message VARCHAR2(500);
BEGIN
    crs_booking_pkg.cancel_ticket(
        p_booking_id => 10000,  -- First booking
        p_message => v_message
    );
    DBMS_OUTPUT.PUT_LINE('✓ TEST PASSED: Ticket cancelled successfully');
    DBMS_OUTPUT.PUT_LINE('  ' || v_message);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ TEST FAILED: ' || SQLERRM);
END;
/

PROMPT ''

-- ============================================================================
-- TEST CASE 3.2: Invalid Booking ID
-- Expected: FAIL - Booking does not exist
-- ============================================================================
PROMPT 'TEST CASE 3.2: Cancel Invalid Booking ID (Should Fail)'
PROMPT '--------------------------------------------'
DECLARE
    v_message VARCHAR2(500);
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
/

PROMPT ''

-- ============================================================================
-- TEST CASE 3.3: Double Cancellation
-- Expected: FAIL - Booking already cancelled
-- ============================================================================
PROMPT 'TEST CASE 3.3: Cancel Already Cancelled Booking (Should Fail)'
PROMPT '--------------------------------------------'
DECLARE
    v_message VARCHAR2(500);
BEGIN
    -- Try to cancel the same booking again
    crs_booking_pkg.cancel_ticket(
        p_booking_id => 10000,  -- Already cancelled
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
/

PROMPT ''
PROMPT '============================================================================'
PROMPT 'SECTION 4: VIEW REPORTS - DATA VALIDATION'
PROMPT '============================================================================'
PROMPT ''

PROMPT 'Report 1: Train Availability'
PROMPT '--------------------------------------------'
SELECT * FROM v_train_availability;

PROMPT ''
PROMPT 'Report 2: Passenger Booking History'
PROMPT '--------------------------------------------'
SELECT passenger_id, passenger_name, booking_id, train_number, travel_date, seat_status
FROM v_passenger_bookings
WHERE ROWNUM <= 10
ORDER BY booking_date DESC;

PROMPT ''
PROMPT 'Report 3: Daily Booking Summary'
PROMPT '--------------------------------------------'
SELECT * FROM v_daily_booking_summary
WHERE ROWNUM <= 10;

PROMPT ''
PROMPT 'Report 4: Passenger Demographics'
PROMPT '--------------------------------------------'
SELECT * FROM v_passenger_demographics;

PROMPT ''
PROMPT '============================================================================'
PROMPT 'TEST SUITE COMPLETE'
PROMPT '============================================================================'
PROMPT 'Summary:'
PROMPT '- Passenger Registration: 6 test cases'
PROMPT '- Ticket Booking: 6 test cases'
PROMPT '- Ticket Cancellation: 3 test cases'
PROMPT '- Report Views: 4 views validated'
PROMPT ''
PROMPT 'Total: 19 test cases executed'
PROMPT 'All critical business rules and exception scenarios tested!'
PROMPT '============================================================================'
PROMPT ''