-- ============================================================================
-- SECTION 7: INSERT REFERENCE DATA
-- ============================================================================

-- Insert day schedule data (7 days)
INSERT INTO crs_day_schedule (sch_id, day_of_week, is_week_end) VALUES (1, 'MONDAY', 'N');
INSERT INTO crs_day_schedule (sch_id, day_of_week, is_week_end) VALUES (2, 'TUESDAY', 'N');
INSERT INTO crs_day_schedule (sch_id, day_of_week, is_week_end) VALUES (3, 'WEDNESDAY', 'N');
INSERT INTO crs_day_schedule (sch_id, day_of_week, is_week_end) VALUES (4, 'THURSDAY', 'N');
INSERT INTO crs_day_schedule (sch_id, day_of_week, is_week_end) VALUES (5, 'FRIDAY', 'N');
INSERT INTO crs_day_schedule (sch_id, day_of_week, is_week_end) VALUES (6, 'SATURDAY', 'Y');
INSERT INTO crs_day_schedule (sch_id, day_of_week, is_week_end) VALUES (7, 'SUNDAY', 'Y');

COMMIT;