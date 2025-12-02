-- ============================================================================
-- CRS Sample Data - Test Data for Development
-- ============================================================================
-- Connection: CONN crs_admin/Admin#2024
-- ============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

-- Clear existing data (make script re-runnable)
DELETE FROM crs_reservation;
DELETE FROM crs_passenger;
DELETE FROM crs_train_schedule;
DELETE FROM crs_train_info;

-- Add sample trains
DECLARE
    v_train_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Loading sample trains...');
    
    -- Train 1: Weekday commuter
    crs_booking_pkg.add_train(
        p_train_number => 'NE-101',
        p_source_station => 'Boston South Station',
        p_dest_station => 'New York Penn Station',
        p_fc_fare => 150.00,
        p_econ_fare => 75.00,
        p_train_id => v_train_id
    );
    crs_booking_pkg.add_train_schedule(v_train_id, 
        'MONDAY,TUESDAY,WEDNESDAY,THURSDAY,FRIDAY');
    
    -- Train 2: Daily express
    crs_booking_pkg.add_train(
        p_train_number => 'NE-202',
        p_source_station => 'Boston South Station',
        p_dest_station => 'Washington Union Station',
        p_fc_fare => 200.00,
        p_econ_fare => 100.00,
        p_train_id => v_train_id
    );
    crs_booking_pkg.add_train_schedule(v_train_id,
        'MONDAY,TUESDAY,WEDNESDAY,THURSDAY,FRIDAY,SATURDAY,SUNDAY');
    
    -- Train 3: Weekend service
    crs_booking_pkg.add_train(
        p_train_number => 'NE-303',
        p_source_station => 'Philadelphia 30th Street',
        p_dest_station => 'Boston South Station',
        p_fc_fare => 120.00,
        p_econ_fare => 60.00,
        p_train_id => v_train_id
    );
    crs_booking_pkg.add_train_schedule(v_train_id, 'SATURDAY,SUNDAY');
    
    DBMS_OUTPUT.PUT_LINE('Sample trains loaded successfully!');
END;
/

-- Add sample passengers and bookings
DECLARE
    v_pid NUMBER;
    v_bid NUMBER;
    v_status VARCHAR2(20);
    v_waitlist NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Loading sample passengers...');
    
    -- Sample passengers
    crs_booking_pkg.register_passenger('John', 'M', 'Smith',
        TO_DATE('1990-05-15', 'YYYY-MM-DD'),
        '123 Main St', 'Boston', 'MA', '02101',
        'john.smith@example.com', '6171234567', v_pid);
    
    crs_booking_pkg.register_passenger('Emma', NULL, 'Johnson',
        TO_DATE('2010-08-20', 'YYYY-MM-DD'),
        '456 Oak Ave', 'Cambridge', 'MA', '02139',
        'emma.johnson@example.com', '6179876543', v_pid);
    
    -- Add more passengers...
    
    DBMS_OUTPUT.PUT_LINE('Sample passengers loaded!');
    DBMS_OUTPUT.PUT_LINE('Creating sample bookings...');
    
    -- Sample bookings
    crs_booking_pkg.book_ticket(1000, 1, 
        NEXT_DAY(SYSDATE, 'MONDAY'), 'ECON',
        v_bid, v_status, v_waitlist);
    
    DBMS_OUTPUT.PUT_LINE('Sample data loaded successfully!');
END;
/

-- Verify data
SELECT * FROM v_train_availability;
SELECT * FROM v_passenger_bookings WHERE ROWNUM <= 10;