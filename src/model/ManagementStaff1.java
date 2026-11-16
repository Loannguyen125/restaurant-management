package model;

import java.time.LocalDate;

public class ManagementStaff1 extends Staff1 {
    public ManagementStaff1(int id, String username, String fullname,
                            LocalDate dateOfBirth, String phone, String email, String position) {
        super(id, username, fullname, null, dateOfBirth, phone, email, position);
    }
}
