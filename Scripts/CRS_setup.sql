-- Drop users if they already exist
BEGIN
    EXECUTE IMMEDIATE 'DROP USER crs_admin CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -01918 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP USER crs_user CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -01918 THEN RAISE; END IF;
END;
/

--Create ADMIN user with full access
CREATE USER crs_admin IDENTIFIED BY CrsAdmin#2025
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON users;

-- Grant necessary privileges to admin
GRANT CREATE SESSION TO crs_admin;
GRANT CREATE TABLE TO crs_admin;
GRANT CREATE VIEW TO crs_admin;
GRANT CREATE SEQUENCE TO crs_admin;
GRANT CREATE PROCEDURE TO crs_admin;
GRANT CREATE TRIGGER TO crs_admin;

-- Create application user schema (for data operations)
CREATE USER crs_user IDENTIFIED BY CrsUser#2025
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA 0 ON users;  -- No direct table access

-- Grant only session privilege to user
GRANT CREATE SESSION TO crs_user;
GRANT CREATE SYNONYM TO crs_user;