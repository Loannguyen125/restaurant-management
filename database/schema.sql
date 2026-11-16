CREATE DATABASE IF NOT EXISTS restaurant_management CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE restaurant_management;
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS tblUser1 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    fullname VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    dateOfBirth DATE,
    phone VARCHAR(255),
    email VARCHAR(255)
);
CREATE TABLE IF NOT EXISTS tblStaff1 (
    tblUser1id INT PRIMARY KEY,
    position VARCHAR(255) NOT NULL,
    FOREIGN KEY (tblUser1id) REFERENCES tblUser1(id)
);
CREATE TABLE IF NOT EXISTS tblCategory1 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255)
);
CREATE TABLE IF NOT EXISTS tblDish1 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    unit VARCHAR(255) NOT NULL,
    price INT NOT NULL CHECK (price > 0),
    image MEDIUMTEXT NULL,
    tblCategory1id INT NOT NULL,
    FOREIGN KEY (tblCategory1id) REFERENCES tblCategory1(id)
);
CREATE TABLE IF NOT EXISTS tblComboMenu1 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    price INT NOT NULL CHECK (price > 0),
    description VARCHAR(255),
    image MEDIUMTEXT NULL
);
CREATE TABLE IF NOT EXISTS tblComboDetail1 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    quantity INT NOT NULL CHECK (quantity > 0),
    tblComboMenu1id INT NOT NULL,
    tblDish1id INT NOT NULL,
    UNIQUE (tblComboMenu1id, tblDish1id),
    FOREIGN KEY (tblComboMenu1id) REFERENCES tblComboMenu1(id) ON DELETE CASCADE,
    FOREIGN KEY (tblDish1id) REFERENCES tblDish1(id)
);

CREATE TABLE IF NOT EXISTS tblCustomer1 (
    tblUser1id INT PRIMARY KEY,
    address VARCHAR(255) NOT NULL,
    FOREIGN KEY (tblUser1id) REFERENCES tblUser1(id)
);
CREATE TABLE IF NOT EXISTS tblMembershipCard1 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cardNumber VARCHAR(255) NOT NULL,
    points INT NOT NULL,
    issueDate DATE NOT NULL,
    `rank` VARCHAR(255) NOT NULL,
    tblCustomer1id INT NOT NULL UNIQUE,
    FOREIGN KEY (tblCustomer1id) REFERENCES tblCustomer1(tblUser1id)
);

CREATE TABLE IF NOT EXISTS tblTable1 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tableNumber INT NOT NULL,
    capacity INT NOT NULL,
    description VARCHAR(255)
);
CREATE TABLE IF NOT EXISTS tblTableReservation1 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reservationTime DATE NOT NULL,
    numberOfPeople INT NOT NULL,
    note VARCHAR(255),
    status VARCHAR(255) NOT NULL,
    tblCustomer1id INT NOT NULL,
    tblTable1id INT NOT NULL,
    FOREIGN KEY (tblCustomer1id) REFERENCES tblCustomer1(tblUser1id),
    FOREIGN KEY (tblTable1id) REFERENCES tblTable1(id)
);
CREATE TABLE IF NOT EXISTS tblOrder1 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    orderTime DATE NOT NULL,
    orderType VARCHAR(255) NOT NULL,
    status VARCHAR(255) NOT NULL,
    tblTable1id INT NULL,
    FOREIGN KEY (tblTable1id) REFERENCES tblTable1(id)
);
CREATE TABLE IF NOT EXISTS tblOrderDetail1 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    quantity INT NOT NULL,
    amount INT NOT NULL,
    tblOrder1id INT NOT NULL,
    tblDish1id INT NOT NULL,
    UNIQUE (tblOrder1id, tblDish1id),
    FOREIGN KEY (tblOrder1id) REFERENCES tblOrder1(id),
    FOREIGN KEY (tblDish1id) REFERENCES tblDish1(id)
);
CREATE TABLE IF NOT EXISTS tblOrderComboDetail1 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    quantity INT NOT NULL,
    amount INT NOT NULL,
    tblOrder1id INT NOT NULL,
    tblComboMenu1id INT NOT NULL,
    UNIQUE (tblOrder1id, tblComboMenu1id),
    FOREIGN KEY (tblOrder1id) REFERENCES tblOrder1(id),
    FOREIGN KEY (tblComboMenu1id) REFERENCES tblComboMenu1(id)
);
CREATE TABLE IF NOT EXISTS tblInvoice1 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    paymentTime DATE NOT NULL,
    amount BIGINT NOT NULL,
    paymentMethod VARCHAR(255) NOT NULL,
    tblCustomer1id INT NOT NULL,
    tblOrder1id INT NOT NULL UNIQUE,
    tblStaff1id INT NOT NULL,
    FOREIGN KEY (tblCustomer1id) REFERENCES tblCustomer1(tblUser1id),
    FOREIGN KEY (tblOrder1id) REFERENCES tblOrder1(id),
    FOREIGN KEY (tblStaff1id) REFERENCES tblStaff1(tblUser1id)
);

CREATE TABLE IF NOT EXISTS tblSupplier1 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contactPerson VARCHAR(255) NOT NULL,
    phone VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL
);
CREATE TABLE IF NOT EXISTS tblIngredient1 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    unit VARCHAR(255) NOT NULL,
    description VARCHAR(255)
);
CREATE TABLE IF NOT EXISTS tblImportInvoice1 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    importDate DATE NOT NULL,
    note VARCHAR(255),
    tblSupplier1id INT NOT NULL,
    tblStaff1id INT NOT NULL,
    FOREIGN KEY (tblSupplier1id) REFERENCES tblSupplier1(id),
    FOREIGN KEY (tblStaff1id) REFERENCES tblStaff1(tblUser1id)
);
CREATE TABLE IF NOT EXISTS tblImportDetail1 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    quantity INT NOT NULL,
    importPrice INT NOT NULL,
    tblImportInvoice1id INT NOT NULL,
    tblIngredient1id INT NOT NULL,
    FOREIGN KEY (tblImportInvoice1id) REFERENCES tblImportInvoice1(id),
    FOREIGN KEY (tblIngredient1id) REFERENCES tblIngredient1(id)
);
