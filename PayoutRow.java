package model;

import java.math.BigDecimal;
import java.sql.Date;

public class PayoutRow {

    private String username;
    private String phoneNumber;
    private double contribution;
    private double interestShare;
    private double amountDue;
    private Date maturityDate;
    private boolean paid;
    private Date paidOn;

    // NEW
    private int groupId;
    private String groupName;

    public PayoutRow() {}

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public double getContribution() { return contribution; }
    public void setContribution(double contribution) { this.contribution = contribution; }

    public double getInterestShare() { return interestShare; }
    public void setInterestShare(double interestShare) { this.interestShare = interestShare; }

    public double getAmountDue() { return amountDue; }
    public void setAmountDue(double amountDue) { this.amountDue = amountDue; }

    public Date getMaturityDate() { return maturityDate; }
    public void setMaturityDate(Date maturityDate) { this.maturityDate = maturityDate; }

    public boolean isPaid() { return paid; }
    public void setPaid(boolean paid) { this.paid = paid; }

    public Date getPaidOn() { return paidOn; }
    public void setPaidOn(Date paidOn) { this.paidOn = paidOn; }

    public int getGroupId() { return groupId; }
    public void setGroupId(int groupId) { this.groupId = groupId; }

    public String getGroupName() { return groupName; }
    public void setGroupName(String groupName) { this.groupName = groupName; }

    @Override
    public String toString() {
        return "PayoutRow{" +
                "username='" + username + '\'' +
                ", phoneNumber='" + phoneNumber + '\'' +
                ", contribution=" + contribution +
                ", interestShare=" + interestShare +
                ", amountDue=" + amountDue +
                ", maturityDate=" + maturityDate +
                ", paid=" + paid +
                ", paidOn=" + paidOn +
                ", groupId=" + groupId +
                ", groupName='" + groupName + '\'' +
                '}';
    }
}