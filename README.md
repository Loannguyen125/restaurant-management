# Restaurant Management System

Ứng dụng Java JSP để nhân viên quản lý chỉnh sửa thông tin món ăn và tạo combo. Dự án sử dụng Maven, Tomcat 9 và MySQL.

1. Cài JDK 17 trở lên, Tomcat 9 và MySQL.
2. Dùng tài khoản quản trị MySQL để chạy `database/schema.sql` rồi `database/seed.sql`. Sao chép `database/demo-user.sql` ra ngoài repo, thay `CHANGE_ME_BEFORE_RUNNING` bằng mật khẩu riêng rồi chạy bản sao để tạo tài khoản ứng dụng.
3. Đặt biến môi trường `RMS_DB_PASSWORD` bằng mật khẩu vừa chọn trước khi chạy Tomcat. Có thể đặt thêm `RMS_DB_USER` và `RMS_DB_URL`; mặc định là `rms_app` và `jdbc:mysql://127.0.0.1:3306/restaurant_management`.
4. Chạy `./mvnw package`, triển khai `target/restaurant-management.war` lên Tomcat rồi mở `http://localhost:8080/restaurant-management/`.

Dữ liệu mẫu có tài khoản quản lý `manager` để chạy thử cục bộ. Mật khẩu demo là `Manager123!`.

Nguồn ảnh mẫu: [credits.md](WebContent/assets/food/credits.md).
