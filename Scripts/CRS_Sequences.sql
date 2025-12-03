--CREATE SEQUENCES

-- Sequence for train_id
CREATE SEQUENCE crs_train_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Sequence for passenger_id
CREATE SEQUENCE crs_passenger_seq
START WITH 1000
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Sequence for booking_id
CREATE SEQUENCE crs_booking_seq
START WITH 10000
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Sequence for schedule_id
CREATE SEQUENCE crs_schedule_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Sequence for train_schedule_id
CREATE SEQUENCE crs_train_sch_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;