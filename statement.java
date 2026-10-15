package model;

import java.math.BigDecimal;
import java.util.Date;

public class statement {

    private int id;
    private String phoneNumber;
    private BigDecimal amount;
    private Date paidOn;
    private int groupId;
    private String groupName;

    public statement() {
    }

    public statement(int id, String phoneNumber, BigDecimal amount, Date paidOn) {
        this.id = id;
        this.phoneNumber = phoneNumber;
        this.amount = amount;
        this.paidOn = paidOn;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public Date getPaidOn() { return paidOn; }
    public void setPaidOn(Date paidOn) { this.paidOn = paidOn; }

    public int getGroupId() { return groupId; }
    public void setGroupId(int groupId) { this.groupId = groupId; }

    public String getGroupName() { return groupName; }
    public void setGroupName(String groupName) { this.groupName = groupName; }

    @Override
    public String toString() {
        return "statement{" +
                "id=" + id +
                ", phoneNumber='" + phoneNumber + '\'' +
                ", amount=" + amount +
                ", paidOn=" + paidOn +
                ", groupId=" + groupId +
                ", groupName='" + groupName + '\'' +
                '}';
    }
}