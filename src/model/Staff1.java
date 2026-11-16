package model;

import java.time.LocalDate;

public class Staff1 extends User1 {
    private String position;

    public Staff1(int id, String username, String fullname, String password,
                  LocalDate dateOfBirth, String phone, String email, String position) {
        super(id, username, fullname, password, dateOfBirth, phone, email);
        this.position = position;
    }

    public String getPosition() {
        return position;
    }
}
