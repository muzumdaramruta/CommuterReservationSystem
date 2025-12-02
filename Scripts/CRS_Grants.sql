-- ============================================================================
-- SECTION 11: GRANT EXECUTE PERMISSIONS TO CRS_USER
-- ============================================================================

-- Grant execute on package to crs_user
GRANT EXECUTE ON crs_booking_pkg TO crs_user;

-- Grant select on views to crs_user
GRANT SELECT ON v_passenger_bookings TO crs_user;
GRANT SELECT ON v_train_availability TO crs_user;
GRANT SELECT ON v_daily_booking_summary TO crs_user;
GRANT SELECT ON v_waitlist_status TO crs_user;
GRANT SELECT ON v_revenue_report TO crs_user;
GRANT SELECT ON v_passenger_demographics TO crs_user;
