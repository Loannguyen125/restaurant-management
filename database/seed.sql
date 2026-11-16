USE restaurant_management;
SET NAMES utf8mb4;
START TRANSACTION;
INSERT INTO tblUser1 (id, username, fullname, password, dateOfBirth, phone, email) VALUES
(1, 'manager', 'Nhân viên quản lý', 'MOZZbXWTLJZhG8YM+jVlSg==:+eap1PdH1bkLjY5/46CE9itmPXjDHuwi4dE850MxohU=', NULL, NULL, 'manager@example.test')
ON DUPLICATE KEY UPDATE id = tblUser1.id;
INSERT INTO tblStaff1 (tblUser1id, position) VALUES (1, 'MANAGER')
ON DUPLICATE KEY UPDATE tblUser1id = tblStaff1.tblUser1id;
INSERT INTO tblCategory1 (id, name, description) VALUES
(1, 'Đồ uống', 'Đồ uống dùng kèm'), (2, 'Khai vị', 'Món dùng trước bữa chính'),
(3, 'Món chính', 'Món dùng trong bữa chính'), (4, 'Tráng miệng', 'Món dùng cuối bữa')
ON DUPLICATE KEY UPDATE id = tblCategory1.id;
INSERT INTO tblDish1 (id, name, price, unit, tblCategory1id, image) VALUES
(1, 'Coca Cola', 15000, 'lon', 1, '/assets/food/cola.jpg'),
(2, 'Trà đào cam sả', 35000, 'ly', 1, NULL),
(3, 'Nước suối', 10000, 'chai', 1, NULL),
(4, 'Gỏi cuốn', 45000, 'đĩa', 2, '/assets/food/goi-cuon.jpg'),
(5, 'Đậu tẩm hành', 50000, 'đĩa', 3, '/assets/food/dau-tam-hanh.jpg'),
(6, 'Phở bò', 65000, 'tô', 3, '/assets/food/pho-bo.jpg'),
(7, 'Cơm tấm sườn', 75000, 'đĩa', 3, NULL),
(8, 'Chè đậu xanh', 23000, 'ly', 4, NULL)
ON DUPLICATE KEY UPDATE id = tblDish1.id;
INSERT INTO tblComboMenu1 (id, name, price, description, image) VALUES
(1, 'Combo A', 200000, 'Các món dùng chung cho hai người', '/assets/food/combo-a.jpg'),
(2, 'Combo Phở', 72000, 'Phở bò và nước suối', '/assets/food/pho-bo.jpg'),
(3, 'Combo Cơm tấm', 98000, 'Cơm tấm và trà đào', NULL),
(4, 'Combo Chay', 78000, 'Đậu tẩm hành và nước uống', '/assets/food/dau-tam-hanh.jpg')
ON DUPLICATE KEY UPDATE id = tblComboMenu1.id;
INSERT INTO tblComboDetail1 (id, quantity, tblComboMenu1id, tblDish1id) VALUES
(1,2,1,1),(2,2,1,4),(3,1,1,5),(4,1,2,6),(5,1,2,3),
(6,1,3,7),(7,1,3,2),(8,1,4,5),(9,1,4,2)
ON DUPLICATE KEY UPDATE id = tblComboDetail1.id;

-- Bổ sung 18 món, 3 combo và 9 dòng chi tiết combo.
-- Món có cùng tên trong cùng nhóm được giữ lại khi chạy seed lần nữa.
INSERT INTO tblDish1 (name, price, unit, tblCategory1id, image)
WITH extra_dishes (name, price, unit, category_name) AS (
    SELECT 'Cà phê sữa đá', 29000, 'ly', 'Đồ uống'
    UNION ALL SELECT 'Trà sen vàng', 39000, 'ly', 'Đồ uống'
    UNION ALL SELECT 'Nước ép cam', 42000, 'ly', 'Đồ uống'
    UNION ALL SELECT 'Sữa đậu nành', 18000, 'ly', 'Đồ uống'
    UNION ALL SELECT 'Chả giò tôm thịt', 55000, 'đĩa', 'Khai vị'
    UNION ALL SELECT 'Gỏi ngó sen tôm thịt', 69000, 'đĩa', 'Khai vị'
    UNION ALL SELECT 'Súp cua', 45000, 'chén', 'Khai vị'
    UNION ALL SELECT 'Đậu hũ chiên sả', 39000, 'đĩa', 'Khai vị'
    UNION ALL SELECT 'Bún thịt nướng', 62000, 'tô', 'Món chính'
    UNION ALL SELECT 'Cơm gà xối mỡ', 69000, 'đĩa', 'Món chính'
    UNION ALL SELECT 'Hủ tiếu Nam Vang', 68000, 'tô', 'Món chính'
    UNION ALL SELECT 'Cơm chiên hải sản', 89000, 'đĩa', 'Món chính'
    UNION ALL SELECT 'Bò lúc lắc', 109000, 'đĩa', 'Món chính'
    UNION ALL SELECT 'Mì xào rau củ', 59000, 'đĩa', 'Món chính'
    UNION ALL SELECT 'Bánh flan', 22000, 'phần', 'Tráng miệng'
    UNION ALL SELECT 'Chè khúc bạch', 32000, 'ly', 'Tráng miệng'
    UNION ALL SELECT 'Sữa chua nếp cẩm', 29000, 'ly', 'Tráng miệng'
    UNION ALL SELECT 'Trái cây theo mùa', 39000, 'đĩa', 'Tráng miệng'
)
SELECT dish.name, dish.price, dish.unit, category.id, NULL
FROM extra_dishes AS dish
JOIN (
    SELECT name, MIN(id) AS id FROM tblCategory1 GROUP BY name
) AS category ON category.name = dish.category_name
WHERE NOT EXISTS (
    SELECT 1 FROM tblDish1 AS existing
    WHERE existing.name = dish.name AND existing.tblCategory1id = category.id
);

UPDATE tblDish1 AS dish
JOIN tblCategory1 AS category ON category.id = dish.tblCategory1id
SET dish.image = '/assets/food/sua-dau-nanh.jpg'
WHERE dish.name = 'Sữa đậu nành' AND category.name = 'Đồ uống'
  AND (dish.image IS NULL OR dish.image = '');

-- Chỉ gắn món cho các combo được tạo trong lần chạy này.
CREATE TEMPORARY TABLE seed_extra_combos (
    name VARCHAR(255) PRIMARY KEY,
    price INT NOT NULL,
    description VARCHAR(255) NOT NULL
);

INSERT INTO seed_extra_combos (name, price, description) VALUES
('Combo Bữa trưa Việt', 115000, 'Bún thịt nướng, chả giò tôm thịt và trà sen vàng'),
('Combo Gà giòn', 109000, 'Cơm gà xối mỡ, súp cua và bánh flan'),
('Combo Rau củ thanh nhẹ', 95000, 'Mì xào rau củ, đậu hũ chiên sả và sữa đậu nành');

DELETE seed_combo FROM seed_extra_combos AS seed_combo
JOIN tblComboMenu1 AS existing ON existing.name = seed_combo.name;

INSERT INTO tblComboMenu1 (name, price, description, image)
SELECT name, price, description, NULL FROM seed_extra_combos;

INSERT INTO tblComboDetail1 (quantity, tblComboMenu1id, tblDish1id)
WITH extra_combo_dishes (combo_name, dish_name, category_name) AS (
    SELECT 'Combo Bữa trưa Việt', 'Bún thịt nướng', 'Món chính'
    UNION ALL SELECT 'Combo Bữa trưa Việt', 'Chả giò tôm thịt', 'Khai vị'
    UNION ALL SELECT 'Combo Bữa trưa Việt', 'Trà sen vàng', 'Đồ uống'
    UNION ALL SELECT 'Combo Gà giòn', 'Cơm gà xối mỡ', 'Món chính'
    UNION ALL SELECT 'Combo Gà giòn', 'Súp cua', 'Khai vị'
    UNION ALL SELECT 'Combo Gà giòn', 'Bánh flan', 'Tráng miệng'
    UNION ALL SELECT 'Combo Rau củ thanh nhẹ', 'Mì xào rau củ', 'Món chính'
    UNION ALL SELECT 'Combo Rau củ thanh nhẹ', 'Đậu hũ chiên sả', 'Khai vị'
    UNION ALL SELECT 'Combo Rau củ thanh nhẹ', 'Sữa đậu nành', 'Đồ uống'
),
dish_ids AS (
    SELECT dish.name, category.name AS category_name, MIN(dish.id) AS id
    FROM tblDish1 AS dish
    JOIN tblCategory1 AS category ON category.id = dish.tblCategory1id
    GROUP BY dish.name, category.name
)
SELECT 1, combo.id, dish.id
FROM extra_combo_dishes AS item
JOIN seed_extra_combos AS seed_combo ON seed_combo.name = item.combo_name
JOIN tblComboMenu1 AS combo ON combo.name = seed_combo.name
JOIN dish_ids AS dish ON dish.name = item.dish_name AND dish.category_name = item.category_name;

DROP TEMPORARY TABLE seed_extra_combos;

COMMIT;
