
-- Drop tables (cascading constraints)
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE crs_reservation CASCADE CONSTRAINTS';
   DBMS_OUTPUT.PUT_LINE('Table crs_reservation dropped');
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE crs_passenger CASCADE CONSTRAINTS';
   DBMS_OUTPUT.PUT_LINE('Table crs_passenger dropped');
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE crs_train_schedule CASCADE CONSTRAINTS';
   DBMS_OUTPUT.PUT_LINE('Table crs_train_schedule dropped');
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE crs_train_info CASCADE CONSTRAINTS';
   DBMS_OUTPUT.PUT_LINE('Table crs_train_info dropped');
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE crs_day_schedule CASCADE CONSTRAINTS';
   DBMS_OUTPUT.PUT_LINE('Table crs_day_schedule dropped');
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

-- Drop sequences
BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE crs_train_seq';
   DBMS_OUTPUT.PUT_LINE('Sequence crs_train_seq dropped');
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -2289 THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE crs_passenger_seq';
   DBMS_OUTPUT.PUT_LINE('Sequence crs_passenger_seq dropped');
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -2289 THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE crs_booking_seq';
   DBMS_OUTPUT.PUT_LINE('Sequence crs_booking_seq dropped');
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -2289 THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE crs_schedule_seq';
   DBMS_OUTPUT.PUT_LINE('Sequence crs_schedule_seq dropped');
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -2289 THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE crs_train_sch_seq';
   DBMS_OUTPUT.PUT_LINE('Sequence crs_train_sch_seq dropped');
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -2289 THEN
         RAISE;
      END IF;
END;
/

-- CREATE TABLES WITH CONSTRAINTS

-- Table 1: CRS_TRAIN_INFO - Stores train details and route information
CREATE TABLE crs_train_info (
    train_id         NUMBER PRIMARY KEY,
    train_number     VARCHAR2(20) NOT NULL UNIQUE,
    source_station   VARCHAR2(100) NOT NULL,
    dest_station     VARCHAR2(100) NOT NULL,
    total_fc_seats   NUMBER DEFAULT 40 NOT NULL,
    total_econ_seats NUMBER DEFAULT 40 NOT NULL,
    fc_seat_fare     NUMBER(10,2) NOT NULL,
    econ_seat_fare   NUMBER(10,2) NOT NULL,
    created_date     DATE DEFAULT SYSDATE,
    updated_date     DATE DEFAULT SYSDATE,
    CONSTRAINT chk_train_seats_fc CHECK (total_fc_seats > 0 AND total_fc_seats <= 100),
    CONSTRAINT chk_train_seats_econ CHECK (total_econ_seats > 0 AND total_econ_seats <= 100),
    CONSTRAINT chk_train_fare_fc CHECK (fc_seat_fare > 0),
    CONSTRAINT chk_train_fare_econ CHECK (econ_seat_fare > 0),
    CONSTRAINT chk_train_stations CHECK (source_station != dest_station)
);

-- Table 2: CRS_DAY_SCHEDULE - Reference table for days of week
CREATE TABLE crs_day_schedule (
    sch_id       NUMBER PRIMARY KEY,
    day_of_week  VARCHAR2(10) NOT NULL UNIQUE,
    is_week_end  CHAR(1) DEFAULT 'N' NOT NULL,
    CONSTRAINT chk_day_weekend CHECK (is_week_end IN ('Y', 'N')),
    CONSTRAINT chk_day_valid CHECK (day_of_week IN ('MONDAY', 'TUESDAY', 'WEDNESDAY', 
                                                     'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'))
);

-- Table 3: CRS_TRAIN_SCHEDULE - Bridge table for train and day relationship
CREATE TABLE crs_train_schedule (
    tsch_id       NUMBER PRIMARY KEY,
    sch_id        NUMBER NOT NULL,
    train_id      NUMBER NOT NULL,
    is_in_service CHAR(1) DEFAULT 'Y' NOT NULL,
    CONSTRAINT fk_tsch_schedule FOREIGN KEY (sch_id) REFERENCES crs_day_schedule(sch_id),
    CONSTRAINT fk_tsch_train FOREIGN KEY (train_id) REFERENCES crs_train_info(train_id),
    CONSTRAINT chk_tsch_service CHECK (is_in_service IN ('Y', 'N')),
    CONSTRAINT uk_tsch_train_day UNIQUE (train_id, sch_id)
);

-- Table 4: CRS_PASSENGER - Stores passenger information
CREATE TABLE crs_passenger (
    passenger_id   NUMBER PRIMARY KEY,
    first_name     VARCHAR2(50) NOT NULL,
    middle_name    VARCHAR2(50),
    last_name      VARCHAR2(50) NOT NULL,
    date_of_birth  DATE NOT NULL,
    address_line1  VARCHAR2(200) NOT NULL,
    address_city   VARCHAR2(50) NOT NULL,
    address_state  VARCHAR2(50) NOT NULL,
    address_zip    VARCHAR2(10) NOT NULL,
    email          VARCHAR2(100) NOT NULL UNIQUE,
    phone          VARCHAR2(15) NOT NULL UNIQUE,
    created_date   DATE DEFAULT SYSDATE,
    updated_date   DATE DEFAULT SYSDATE,
    CONSTRAINT chk_pass_email CHECK (REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')),
    CONSTRAINT chk_pass_phone CHECK (REGEXP_LIKE(phone, '^\d{10,15}$'))
);

-- Table 5: CRS_RESERVATION - Stores booking information
CREATE TABLE crs_reservation (
    booking_id        NUMBER PRIMARY KEY,
    passenger_id      NUMBER NOT NULL,
    train_id          NUMBER NOT NULL,
    travel_date       DATE NOT NULL,
    booking_date      DATE DEFAULT SYSDATE NOT NULL,
    seat_class        VARCHAR2(10) NOT NULL,
    seat_status       VARCHAR2(20) DEFAULT 'CONFIRMED' NOT NULL,
    waitlist_position NUMBER,
    created_date      DATE DEFAULT SYSDATE,
    updated_date      DATE DEFAULT SYSDATE,
    CONSTRAINT fk_res_passenger FOREIGN KEY (passenger_id) REFERENCES crs_passenger(passenger_id),
    CONSTRAINT fk_res_train FOREIGN KEY (train_id) REFERENCES crs_train_info(train_id),
    CONSTRAINT chk_res_class CHECK (seat_class IN ('FC', 'ECON')),
    CONSTRAINT chk_res_status CHECK (seat_status IN ('CONFIRMED', 'WAITLISTED', 'CANCELLED')),
    CONSTRAINT chk_res_waitlist CHECK (
        (seat_status = 'WAITLISTED' AND waitlist_position IS NOT NULL) OR
        (seat_status != 'WAITLISTED' AND waitlist_position IS NULL)
    )
);

-- CREATE INDEXES FOR PERFORMANCE

CREATE INDEX idx_reservation_passenger ON crs_reservation(passenger_id);
CREATE INDEX idx_reservation_train ON crs_reservation(train_id);
CREATE INDEX idx_reservation_travel_date ON crs_reservation(travel_date);
CREATE INDEX idx_reservation_status ON crs_reservation(seat_status);
CREATE INDEX idx_train_schedule_train ON crs_train_schedule(train_id);