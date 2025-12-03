-- ============================================================================
-- SECTION 12: CREATE SYNONYMS FOR CRS_USER
-- ============================================================================
-- Connect as crs_user and create synonyms
-- CONN crs_user/User#2024

-- Create synonyms (run these as crs_user after connecting)

CREATE SYNONYM crs_booking_pkg FOR crs_admin.crs_booking_pkg;
CREATE SYNONYM v_passenger_bookings FOR crs_admin.v_passenger_bookings;
CREATE SYNONYM v_train_availability FOR crs_admin.v_train_availability;
CREATE SYNONYM v_daily_booking_summary FOR crs_admin.v_daily_booking_summary;
CREATE SYNONYM v_waitlist_status FOR crs_admin.v_waitlist_status;
CREATE SYNONYM v_revenue_report FOR crs_admin.v_revenue_report;
CREATE SYNONYM v_passenger_demographics FOR crs_admin.v_passenger_demographics;
