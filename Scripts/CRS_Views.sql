-- ============================================================================
-- SECTION 10: CREATE VIEWS FOR REPORTING
-- ============================================================================

-- View 1: Passenger Booking History
CREATE OR REPLACE VIEW v_passenger_bookings AS
SELECT 
    p.passenger_id,
    p.first_name || ' ' || NVL(p.middle_name || ' ', '') || p.last_name AS passenger_name,
    p.email,
    p.phone,
    FLOOR(MONTHS_BETWEEN(SYSDATE, p.date_of_birth) / 12) AS age,
    CASE 
        WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, p.date_of_birth) / 12) < 18 THEN 'MINOR'
        WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, p.date_of_birth) / 12) >= 60 THEN 'SENIOR CITIZEN'
        ELSE 'ADULT'
    END AS passenger_category,
    r.booking_id,
    t.train_number,
    t.source_station || ' to ' || t.dest_station AS route,
    r.travel_date,
    r.booking_date,
    r.seat_class,
    r.seat_status,
    r.waitlist_position,
    CASE r.seat_class
        WHEN 'FC' THEN t.fc_seat_fare
        ELSE t.econ_seat_fare
    END AS fare_amount
FROM crs_passenger p
LEFT JOIN crs_reservation r ON p.passenger_id = r.passenger_id
LEFT JOIN crs_train_info t ON r.train_id = t.train_id;

-- View 2: Train Availability Summary
CREATE OR REPLACE VIEW v_train_availability AS
SELECT 
    t.train_id,
    t.train_number,
    t.source_station,
    t.dest_station,
    t.total_fc_seats,
    t.total_econ_seats,
    t.fc_seat_fare,
    t.econ_seat_fare,
    LISTAGG(ds.day_of_week, ', ') WITHIN GROUP (ORDER BY ds.sch_id) AS operating_days
FROM crs_train_info t
LEFT JOIN crs_train_schedule ts ON t.train_id = ts.train_id AND ts.is_in_service = 'Y'
LEFT JOIN crs_day_schedule ds ON ts.sch_id = ds.sch_id
GROUP BY t.train_id, t.train_number, t.source_station, t.dest_station,
         t.total_fc_seats, t.total_econ_seats, t.fc_seat_fare, t.econ_seat_fare;

-- View 3: Daily Booking Summary
CREATE OR REPLACE VIEW v_daily_booking_summary AS
SELECT 
    r.travel_date,
    t.train_number,
    t.source_station || ' to ' || t.dest_station AS route,
    r.seat_class,
    COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) AS confirmed_bookings,
    COUNT(CASE WHEN r.seat_status = 'WAITLISTED' THEN 1 END) AS waitlisted_bookings,
    COUNT(CASE WHEN r.seat_status = 'CANCELLED' THEN 1 END) AS cancelled_bookings,
    COUNT(*) AS total_bookings,
    CASE r.seat_class
        WHEN 'FC' THEN t.total_fc_seats
        ELSE t.total_econ_seats
    END AS total_seats,
    CASE r.seat_class
        WHEN 'FC' THEN t.total_fc_seats - COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END)
        ELSE t.total_econ_seats - COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END)
    END AS available_seats
FROM crs_reservation r
JOIN crs_train_info t ON r.train_id = t.train_id
GROUP BY r.travel_date, t.train_number, t.source_station, t.dest_station, 
         r.seat_class, t.total_fc_seats, t.total_econ_seats
ORDER BY r.travel_date DESC, t.train_number, r.seat_class;

-- View 4: Waitlist Status
CREATE OR REPLACE VIEW v_waitlist_status AS
SELECT 
    r.booking_id,
    p.first_name || ' ' || p.last_name AS passenger_name,
    p.email,
    p.phone,
    t.train_number,
    t.source_station || ' to ' || t.dest_station AS route,
    r.travel_date,
    r.seat_class,
    r.waitlist_position,
    r.booking_date
FROM crs_reservation r
JOIN crs_passenger p ON r.passenger_id = p.passenger_id
JOIN crs_train_info t ON r.train_id = t.train_id
WHERE r.seat_status = 'WAITLISTED'
ORDER BY r.travel_date, t.train_number, r.seat_class, r.waitlist_position;

-- View 5: Revenue Report
CREATE OR REPLACE VIEW v_revenue_report AS
SELECT 
    TO_CHAR(r.booking_date, 'YYYY-MM') AS booking_month,
    t.train_number,
    t.source_station || ' to ' || t.dest_station AS route,
    r.seat_class,
    COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) AS tickets_sold,
    CASE r.seat_class
        WHEN 'FC' THEN t.fc_seat_fare
        ELSE t.econ_seat_fare
    END AS fare_per_ticket,
    COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) * 
    CASE r.seat_class
        WHEN 'FC' THEN t.fc_seat_fare
        ELSE t.econ_seat_fare
    END AS total_revenue
FROM crs_reservation r
JOIN crs_train_info t ON r.train_id = t.train_id
WHERE r.seat_status = 'CONFIRMED'
GROUP BY TO_CHAR(r.booking_date, 'YYYY-MM'), t.train_number, 
         t.source_station, t.dest_station, r.seat_class,
         t.fc_seat_fare, t.econ_seat_fare
ORDER BY booking_month DESC, t.train_number, r.seat_class;

-- View 6: Passenger Demographics
CREATE OR REPLACE VIEW v_passenger_demographics AS
SELECT 
    CASE 
        WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, date_of_birth) / 12) < 18 THEN 'MINOR (0-17)'
        WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, date_of_birth) / 12) BETWEEN 18 AND 29 THEN 'YOUNG ADULT (18-29)'
        WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, date_of_birth) / 12) BETWEEN 30 AND 59 THEN 'ADULT (30-59)'
        ELSE 'SENIOR CITIZEN (60+)'
    END AS age_group,
    COUNT(*) AS passenger_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM crs_passenger), 2) AS percentage
FROM crs_passenger
GROUP BY CASE 
        WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, date_of_birth) / 12) < 18 THEN 'MINOR (0-17)'
        WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, date_of_birth) / 12) BETWEEN 18 AND 29 THEN 'YOUNG ADULT (18-29)'
        WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, date_of_birth) / 12) BETWEEN 30 AND 59 THEN 'ADULT (30-59)'
        ELSE 'SENIOR CITIZEN (60+)'
    END
ORDER BY age_group;