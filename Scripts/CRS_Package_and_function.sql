-- CREATE PACKAGE SPECIFICATION

CREATE OR REPLACE PACKAGE crs_booking_pkg AS
    -- Custom Exceptions
    e_invalid_train EXCEPTION;
    e_invalid_date EXCEPTION;
    e_no_seats_available EXCEPTION;
    e_invalid_passenger EXCEPTION;
    e_invalid_booking EXCEPTION;
    e_advance_booking_limit EXCEPTION;
    e_duplicate_booking EXCEPTION;
    
    PRAGMA EXCEPTION_INIT(e_invalid_train, -20001);
    PRAGMA EXCEPTION_INIT(e_invalid_date, -20002);
    PRAGMA EXCEPTION_INIT(e_no_seats_available, -20003);
    PRAGMA EXCEPTION_INIT(e_invalid_passenger, -20004);
    PRAGMA EXCEPTION_INIT(e_invalid_booking, -20005);
    PRAGMA EXCEPTION_INIT(e_advance_booking_limit, -20006);
    PRAGMA EXCEPTION_INIT(e_duplicate_booking, -20007);
    
    -- Procedure to register a new passenger
    PROCEDURE register_passenger(
        p_first_name    IN VARCHAR2,
        p_middle_name   IN VARCHAR2,
        p_last_name     IN VARCHAR2,
        p_dob           IN DATE,
        p_address_line1 IN VARCHAR2,
        p_address_city  IN VARCHAR2,
        p_address_state IN VARCHAR2,
        p_address_zip   IN VARCHAR2,
        p_email         IN VARCHAR2,
        p_phone         IN VARCHAR2,
        p_passenger_id  OUT NUMBER
    );
    
    -- Function to check seat availability
    FUNCTION check_seat_availability(
        p_train_id     IN NUMBER,
        p_travel_date  IN DATE,
        p_seat_class   IN VARCHAR2
    ) RETURN NUMBER;
    
    -- Procedure to book a ticket
    PROCEDURE book_ticket(
        p_passenger_id IN NUMBER,
        p_train_id     IN NUMBER,
        p_travel_date  IN DATE,
        p_seat_class   IN VARCHAR2,
        p_booking_id   OUT NUMBER,
        p_seat_status  OUT VARCHAR2,
        p_waitlist_pos OUT NUMBER
    );
    
    -- Procedure to cancel a ticket
    PROCEDURE cancel_ticket(
        p_booking_id IN NUMBER,
        p_message    OUT VARCHAR2
    );
    
    -- Function to get passenger age category
    FUNCTION get_passenger_category(
        p_dob IN DATE
    ) RETURN VARCHAR2;
    
    -- Function to check if train operates on given date
    FUNCTION is_train_available(
        p_train_id    IN NUMBER,
        p_travel_date IN DATE
    ) RETURN BOOLEAN;
    
    -- Procedure to add a new train
    PROCEDURE add_train(
        p_train_number   IN VARCHAR2,
        p_source_station IN VARCHAR2,
        p_dest_station   IN VARCHAR2,
        p_fc_fare        IN NUMBER,
        p_econ_fare      IN NUMBER,
        p_train_id       OUT NUMBER
    );
    
    -- Procedure to add train schedule
    PROCEDURE add_train_schedule(
        p_train_id IN NUMBER,
        p_days     IN VARCHAR2  -- Comma separated day names
    );
    
END crs_booking_pkg;
/


-- CREATE PACKAGE BODY

CREATE OR REPLACE PACKAGE BODY crs_booking_pkg AS

    -- ========================================================================
    -- Procedure: register_passenger
    -- Description: Registers a new passenger with validation
    -- ========================================================================
    PROCEDURE register_passenger(
        p_first_name    IN VARCHAR2,
        p_middle_name   IN VARCHAR2,
        p_last_name     IN VARCHAR2,
        p_dob           IN DATE,
        p_address_line1 IN VARCHAR2,
        p_address_city  IN VARCHAR2,
        p_address_state IN VARCHAR2,
        p_address_zip   IN VARCHAR2,
        p_email         IN VARCHAR2,
        p_phone         IN VARCHAR2,
        p_passenger_id  OUT NUMBER
    ) IS
        v_count NUMBER;
    BEGIN
        -- Validate required fields
        IF p_first_name IS NULL OR p_last_name IS NULL THEN
            RAISE_APPLICATION_ERROR(-20004, 'First name and last name are required');
        END IF;
        
        -- Validate date of birth (must be in the past and realistic)
        IF p_dob >= SYSDATE THEN
            RAISE_APPLICATION_ERROR(-20004, 'Date of birth must be in the past');
        END IF;
        
        IF p_dob < ADD_MONTHS(SYSDATE, -120*12) THEN
            RAISE_APPLICATION_ERROR(-20004, 'Invalid date of birth - passenger age cannot exceed 120 years');
        END IF;
        
        -- Check for duplicate email
        SELECT COUNT(*) INTO v_count 
        FROM crs_passenger 
        WHERE email = p_email;
        
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'Email already registered. Please use a different email.');
        END IF;
        
        -- Check for duplicate phone
        SELECT COUNT(*) INTO v_count 
        FROM crs_passenger 
        WHERE phone = p_phone;
        
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'Phone number already registered. Please use a different phone number.');
        END IF;
        
        -- Generate new passenger ID
        SELECT crs_passenger_seq.NEXTVAL INTO p_passenger_id FROM DUAL;
        
        -- Insert passenger record
        INSERT INTO crs_passenger (
            passenger_id, first_name, middle_name, last_name, date_of_birth,
            address_line1, address_city, address_state, address_zip, email, phone
        ) VALUES (
            p_passenger_id, p_first_name, p_middle_name, p_last_name, p_dob,
            p_address_line1, p_address_city, p_address_state, p_address_zip, p_email, p_phone
        );
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Passenger registered successfully. Passenger ID: ' || p_passenger_id);
        DBMS_OUTPUT.PUT_LINE('Category: ' || get_passenger_category(p_dob));
        
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20004, 'Duplicate email or phone number detected');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20004, 'Error registering passenger: ' || SQLERRM);
    END register_passenger;

    -- ========================================================================
    -- Function: get_passenger_category
    -- Description: Returns passenger category based on age
    -- ========================================================================
    FUNCTION get_passenger_category(p_dob IN DATE) RETURN VARCHAR2 IS
        v_age NUMBER;
    BEGIN
        v_age := FLOOR(MONTHS_BETWEEN(SYSDATE, p_dob) / 12);
        
        IF v_age < 18 THEN
            RETURN 'MINOR';
        ELSIF v_age >= 60 THEN
            RETURN 'SENIOR CITIZEN';
        ELSE
            RETURN 'ADULT';
        END IF;
    END get_passenger_category;

    -- ========================================================================
    -- Function: is_train_available
    -- Description: Checks if train operates on the given date
    -- ========================================================================
    FUNCTION is_train_available(
        p_train_id    IN NUMBER,
        p_travel_date IN DATE
    ) RETURN BOOLEAN IS
        v_day_name VARCHAR2(10);
        v_count NUMBER;
    BEGIN
        -- Get day name for the travel date
        v_day_name := UPPER(TO_CHAR(p_travel_date, 'DAY'));
        v_day_name := TRIM(v_day_name);
        
        -- Check if train operates on this day
        SELECT COUNT(*) INTO v_count
        FROM crs_train_schedule ts
        JOIN crs_day_schedule ds ON ts.sch_id = ds.sch_id
        WHERE ts.train_id = p_train_id
          AND ds.day_of_week = v_day_name
          AND ts.is_in_service = 'Y';
        
        RETURN v_count > 0;
    END is_train_available;

    -- ========================================================================
    -- Function: check_seat_availability
    -- Description: Returns available seats for a train on a specific date
    -- ========================================================================
    FUNCTION check_seat_availability(
        p_train_id     IN NUMBER,
        p_travel_date  IN DATE,
        p_seat_class   IN VARCHAR2
    ) RETURN NUMBER IS
        v_total_seats    NUMBER;
        v_booked_seats   NUMBER;
        v_available      NUMBER;
    BEGIN
        -- Get total seats for the class
        IF p_seat_class = 'FC' THEN
            SELECT total_fc_seats INTO v_total_seats
            FROM crs_train_info
            WHERE train_id = p_train_id;
        ELSE
            SELECT total_econ_seats INTO v_total_seats
            FROM crs_train_info
            WHERE train_id = p_train_id;
        END IF;
        
        -- Count confirmed and waitlisted bookings
        SELECT COUNT(*) INTO v_booked_seats
        FROM crs_reservation
        WHERE train_id = p_train_id
          AND travel_date = p_travel_date
          AND seat_class = p_seat_class
          AND seat_status IN ('CONFIRMED', 'WAITLISTED');
        
        -- Calculate available seats (40 confirmed + 5 waitlist = 45 max)
        v_available := (v_total_seats + 5) - v_booked_seats;
        
        RETURN v_available;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'Invalid train ID');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20999, 'Error checking availability: ' || SQLERRM);
    END check_seat_availability;

    -- ========================================================================
    -- Procedure: book_ticket
    -- Description: Books a ticket with validations and waitlist management
    -- ========================================================================
    PROCEDURE book_ticket(
        p_passenger_id IN NUMBER,
        p_train_id     IN NUMBER,
        p_travel_date  IN DATE,
        p_seat_class   IN VARCHAR2,
        p_booking_id   OUT NUMBER,
        p_seat_status  OUT VARCHAR2,
        p_waitlist_pos OUT NUMBER
    ) IS
        v_train_exists   NUMBER;
        v_passenger_exists NUMBER;
        v_available_seats NUMBER;
        v_confirmed_seats NUMBER;
        v_total_seats    NUMBER;
        v_days_advance   NUMBER;
        v_duplicate_count NUMBER;
    BEGIN
        -- Validate train exists
        SELECT COUNT(*) INTO v_train_exists
        FROM crs_train_info
        WHERE train_id = p_train_id;
        
        IF v_train_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Invalid train ID. Train does not exist.');
        END IF;
        
        -- Validate passenger exists
        SELECT COUNT(*) INTO v_passenger_exists
        FROM crs_passenger
        WHERE passenger_id = p_passenger_id;
        
        IF v_passenger_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'Invalid passenger ID. Please register first.');
        END IF;
        
        -- Validate seat class
        IF p_seat_class NOT IN ('FC', 'ECON') THEN
            RAISE_APPLICATION_ERROR(-20002, 'Invalid seat class. Must be FC or ECON.');
        END IF;
        
        -- Validate travel date (must be future date)
        IF p_travel_date < TRUNC(SYSDATE) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Travel date cannot be in the past');
        END IF;
        
        -- Check advance booking limit (7 days)
        v_days_advance := p_travel_date - TRUNC(SYSDATE);
        IF v_days_advance > 7 THEN
            RAISE_APPLICATION_ERROR(-20006, 'Advance booking allowed only for 7 days. Your booking is ' || v_days_advance || ' days in advance.');
        END IF;
        
        -- Check if train operates on the travel date
        IF NOT is_train_available(p_train_id, p_travel_date) THEN
            RAISE_APPLICATION_ERROR(-20001, 'Train does not operate on ' || TO_CHAR(p_travel_date, 'Day, DD-MON-YYYY'));
        END IF;
        
        -- Check for duplicate booking (same passenger, train, date, class)
        SELECT COUNT(*) INTO v_duplicate_count
        FROM crs_reservation
        WHERE passenger_id = p_passenger_id
          AND train_id = p_train_id
          AND travel_date = p_travel_date
          AND seat_class = p_seat_class
          AND seat_status IN ('CONFIRMED', 'WAITLISTED');
        
        IF v_duplicate_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20007, 'Duplicate booking detected. You already have a booking for this train on this date.');
        END IF;
        
        -- Get total seats for the class
        IF p_seat_class = 'FC' THEN
            SELECT total_fc_seats INTO v_total_seats
            FROM crs_train_info
            WHERE train_id = p_train_id;
        ELSE
            SELECT total_econ_seats INTO v_total_seats
            FROM crs_train_info
            WHERE train_id = p_train_id;
        END IF;
        
        -- Count confirmed bookings
        SELECT COUNT(*) INTO v_confirmed_seats
        FROM crs_reservation
        WHERE train_id = p_train_id
          AND travel_date = p_travel_date
          AND seat_class = p_seat_class
          AND seat_status = 'CONFIRMED';
        
        -- Check seat availability
        v_available_seats := check_seat_availability(p_train_id, p_travel_date, p_seat_class);
        
        IF v_available_seats <= 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'No seats available. All seats and waitlist positions are full.');
        END IF;
        
        -- Generate booking ID
        SELECT crs_booking_seq.NEXTVAL INTO p_booking_id FROM DUAL;
        
        -- Determine seat status and waitlist position
        IF v_confirmed_seats < v_total_seats THEN
            -- Seats available - confirm booking
            p_seat_status := 'CONFIRMED';
            p_waitlist_pos := NULL;
        ELSE
            -- Seats full - add to waitlist
            p_seat_status := 'WAITLISTED';
            SELECT NVL(MAX(waitlist_position), 0) + 1 INTO p_waitlist_pos
            FROM crs_reservation
            WHERE train_id = p_train_id
              AND travel_date = p_travel_date
              AND seat_class = p_seat_class
              AND seat_status = 'WAITLISTED';
        END IF;
        
        -- Insert booking
        INSERT INTO crs_reservation (
            booking_id, passenger_id, train_id, travel_date, 
            booking_date, seat_class, seat_status, waitlist_position
        ) VALUES (
            p_booking_id, p_passenger_id, p_train_id, p_travel_date,
            SYSDATE, p_seat_class, p_seat_status, p_waitlist_pos
        );
        
        COMMIT;
        
        -- Display confirmation
        DBMS_OUTPUT.PUT_LINE('==============================================');
        DBMS_OUTPUT.PUT_LINE('Booking ' || p_seat_status);
        DBMS_OUTPUT.PUT_LINE('==============================================');
        DBMS_OUTPUT.PUT_LINE('Booking ID: ' || p_booking_id);
        DBMS_OUTPUT.PUT_LINE('Passenger ID: ' || p_passenger_id);
        DBMS_OUTPUT.PUT_LINE('Train ID: ' || p_train_id);
        DBMS_OUTPUT.PUT_LINE('Travel Date: ' || TO_CHAR(p_travel_date, 'DD-MON-YYYY'));
        DBMS_OUTPUT.PUT_LINE('Class: ' || p_seat_class);
        DBMS_OUTPUT.PUT_LINE('Status: ' || p_seat_status);
        IF p_waitlist_pos IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('Waitlist Position: ' || p_waitlist_pos);
        END IF;
        DBMS_OUTPUT.PUT_LINE('==============================================');
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END book_ticket;

    -- ========================================================================
    -- Procedure: cancel_ticket
    -- Description: Cancels a ticket and promotes waitlisted passenger
    -- ========================================================================
    PROCEDURE cancel_ticket(
        p_booking_id IN NUMBER,
        p_message    OUT VARCHAR2
    ) IS
        v_booking_exists NUMBER;
        v_current_status VARCHAR2(20);
        v_train_id       NUMBER;
        v_travel_date    DATE;
        v_seat_class     VARCHAR2(10);
        v_waitlist_booking NUMBER;
        v_train_number   VARCHAR2(20);
        v_passenger_name VARCHAR2(150);
    BEGIN
        -- Check if booking exists
        SELECT COUNT(*) INTO v_booking_exists
        FROM crs_reservation
        WHERE booking_id = p_booking_id;
        
        IF v_booking_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20005, 'Invalid booking ID. Booking not found.');
        END IF;
        
        -- Get booking details
        SELECT seat_status, train_id, travel_date, seat_class
        INTO v_current_status, v_train_id, v_travel_date, v_seat_class
        FROM crs_reservation
        WHERE booking_id = p_booking_id;
        
        -- Check if already cancelled
        IF v_current_status = 'CANCELLED' THEN
            RAISE_APPLICATION_ERROR(-20005, 'Booking already cancelled');
        END IF;
        
        -- Cancel the booking
        UPDATE crs_reservation
        SET seat_status = 'CANCELLED',
            waitlist_position = NULL,
            updated_date = SYSDATE
        WHERE booking_id = p_booking_id;
        
        p_message := 'Booking ID ' || p_booking_id || ' cancelled successfully.';
        
        -- If cancelled booking was CONFIRMED, promote first waitlisted passenger
        IF v_current_status = 'CONFIRMED' THEN
            -- Find first waitlisted booking for same train, date, class
            BEGIN
                SELECT booking_id INTO v_waitlist_booking
                FROM crs_reservation
                WHERE train_id = v_train_id
                  AND travel_date = v_travel_date
                  AND seat_class = v_seat_class
                  AND seat_status = 'WAITLISTED'
                  AND waitlist_position = 1;
                
                -- Promote waitlisted booking to confirmed
                UPDATE crs_reservation
                SET seat_status = 'CONFIRMED',
                    waitlist_position = NULL,
                    updated_date = SYSDATE
                WHERE booking_id = v_waitlist_booking;
                
                -- Update waitlist positions for remaining passengers
                UPDATE crs_reservation
                SET waitlist_position = waitlist_position - 1,
                    updated_date = SYSDATE
                WHERE train_id = v_train_id
                  AND travel_date = v_travel_date
                  AND seat_class = v_seat_class
                  AND seat_status = 'WAITLISTED'
                  AND waitlist_position > 1;
                
                p_message := p_message || ' Waitlisted booking ID ' || v_waitlist_booking || ' has been confirmed.';
                
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    -- No waitlisted passengers to promote
                    NULL;
            END;
        END IF;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE(p_message);
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END cancel_ticket;

    -- ========================================================================
    -- Procedure: add_train
    -- Description: Adds a new train to the system
    -- ========================================================================
    PROCEDURE add_train(
        p_train_number   IN VARCHAR2,
        p_source_station IN VARCHAR2,
        p_dest_station   IN VARCHAR2,
        p_fc_fare        IN NUMBER,
        p_econ_fare      IN NUMBER,
        p_train_id       OUT NUMBER
    ) IS
        v_count NUMBER;
    BEGIN
        -- Validate train number uniqueness
        SELECT COUNT(*) INTO v_count
        FROM crs_train_info
        WHERE train_number = p_train_number;
        
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Train number already exists');
        END IF;
        
        -- Validate stations are different
        IF UPPER(p_source_station) = UPPER(p_dest_station) THEN
            RAISE_APPLICATION_ERROR(-20001, 'Source and destination stations must be different');
        END IF;
        
        -- Validate fares
        IF p_fc_fare <= 0 OR p_econ_fare <= 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Fares must be positive values');
        END IF;
        
        -- Generate train ID
        SELECT crs_train_seq.NEXTVAL INTO p_train_id FROM DUAL;
        
        -- Insert train
        INSERT INTO crs_train_info (
            train_id, train_number, source_station, dest_station,
            total_fc_seats, total_econ_seats, fc_seat_fare, econ_seat_fare
        ) VALUES (
            p_train_id, p_train_number, p_source_station, p_dest_station,
            40, 40, p_fc_fare, p_econ_fare
        );
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Train added successfully. Train ID: ' || p_train_id);
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END add_train;

    -- ========================================================================
    -- Procedure: add_train_schedule
    -- Description: Adds train schedule for specified days
    -- ========================================================================
    PROCEDURE add_train_schedule(
        p_train_id IN NUMBER,
        p_days     IN VARCHAR2  -- Comma separated: 'MONDAY,TUESDAY,WEDNESDAY'
    ) IS
        v_day VARCHAR2(50);
        v_sch_id NUMBER;
        v_remaining VARCHAR2(500);
        v_pos NUMBER;
    BEGIN
        v_remaining := p_days;
        
        LOOP
            -- Find position of comma
            v_pos := INSTR(v_remaining, ',');
            
            IF v_pos > 0 THEN
                -- Extract day before comma
                v_day := TRIM(SUBSTR(v_remaining, 1, v_pos - 1));
                v_remaining := SUBSTR(v_remaining, v_pos + 1);
            ELSE
                -- Last day in list
                v_day := TRIM(v_remaining);
            END IF;
            
            -- Get schedule ID for the day
            BEGIN
                SELECT sch_id INTO v_sch_id
                FROM crs_day_schedule
                WHERE day_of_week = UPPER(v_day);
                
                -- Insert train schedule
                INSERT INTO crs_train_schedule (tsch_id, sch_id, train_id, is_in_service)
                VALUES (crs_train_sch_seq.NEXTVAL, v_sch_id, p_train_id, 'Y');
                
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    DBMS_OUTPUT.PUT_LINE('Warning: Invalid day name: ' || v_day);
                WHEN DUP_VAL_ON_INDEX THEN
                    DBMS_OUTPUT.PUT_LINE('Warning: Schedule already exists for ' || v_day);
            END;
            
            EXIT WHEN v_pos = 0;
        END LOOP;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Train schedule added successfully');
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END add_train_schedule;

END crs_booking_pkg;
/
