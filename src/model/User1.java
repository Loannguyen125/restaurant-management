package model;

import java.time.LocalDate;

public class User1 {
    private int id;
    private String username;
    private String fullname;
    private String password;
    private LocalDate dateOfBirth;
    private String phone;
    private String email;

    public User1(int id, String username, String fullname, String password, LocalDate dateOfBirth, String phone, String email) {
        this.id = id;
        this.username = username;
        this.fullname = fullname;
        this.password = password;
        this.dateOfBirth = dateOfBirth;
        this.phone = phone;
        this.email = email;
    }

    public int getId() {
        return id;
    }

    public String getUsername() {
        return username;
    }

    public String getFullname() {
        return fullname;
    }

    public String getPassword() {
        return password;
    }

    public LocalDate getDateOfBirth() {
        return dateOfBirth;
    }

    public String getPhone() {
        return phone;
    }

    public String getEmail() {
        return email;
    }
}
