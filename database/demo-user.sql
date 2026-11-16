-- Replace CHANGE_ME_BEFORE_RUNNING in a local copy before running this script.
CREATE USER IF NOT EXISTS 'rms_app'@'localhost' IDENTIFIED BY 'CHANGE_ME_BEFORE_RUNNING';
GRANT SELECT, INSERT, UPDATE ON restaurant_management.* TO 'rms_app'@'localhost';
