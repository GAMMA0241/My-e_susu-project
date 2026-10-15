package model;

import java.time.LocalDate;

public class member {
    private int id;
    private String fullName;
    private String phoneNumber;
    private String ghanaCardNumber;
    private String emergencyContact;
    private LocalDate joinDate;
    private LocalDate maturityDate;
    private boolean active;
    private boolean leftEarly;
    private LocalDate exitDate;
    private int groupId;


    private String momoNumber;
    private String bankAccount;

    // getters and setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getGhanaCardNumber() { return ghanaCardNumber; }
    public void setGhanaCardNumber(String ghanaCardNumber) { this.ghanaCardNumber = ghanaCardNumber; }

    public String getEmergencyContact() { return emergencyContact; }
    public void setEmergencyContact(String emergencyContact) { this.emergencyContact = emergencyContact; }

    public LocalDate getJoinDate() { return joinDate; }
    public void setJoinDate(LocalDate joinDate) { this.joinDate = joinDate; }

    public LocalDate getMaturityDate() { return maturityDate; }
    public void setMaturityDate(LocalDate maturityDate) { this.maturityDate = maturityDate; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public boolean isLeftEarly() { return leftEarly; }
    public void setLeftEarly(boolean leftEarly) { this.leftEarly = leftEarly; }

    public LocalDate getExitDate() { return exitDate; }
    public void setExitDate(LocalDate exitDate) { this.exitDate = exitDate; }

    public int getGroupId() { return groupId; }
    public void setGroupId(int groupId) { this.groupId = groupId; }

    public String getMomoNumber() { return momoNumber; }
    public void setMomoNumber(String momoNumber) { this.momoNumber = momoNumber; }

    public String getBankAccount() { return bankAccount; }
    public void setBankAccount(String bankAccount) { this.bankAccount = bankAccount; }
}