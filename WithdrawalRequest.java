package model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class WithdrawalRequest {

    private int        id;
    private int        groupId;
    private String     phoneNumber;
    private String     memberName;
    private String     requestType;      // MATURITY, TERMINATION, TRANSFER
    private BigDecimal contribution;
    private BigDecimal interestShare;
    private BigDecimal penalty;
    private BigDecimal amountPayable;
    private String     targetGroupName;
    private String     targetBankAccount;
    private String     momoNumber;
    private String     status;           // PENDING, APPROVED, PAID, CANCELLED
    private Timestamp  requestedOn;
    private Date       processedOn;
    private String     processedBy;
    private String     notes;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getGroupId() { return groupId; }
    public void setGroupId(int groupId) { this.groupId = groupId; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getMemberName() { return memberName; }
    public void setMemberName(String memberName) { this.memberName = memberName; }

    public String getRequestType() { return requestType; }
    public void setRequestType(String requestType) { this.requestType = requestType; }

    public BigDecimal getContribution() { return contribution; }
    public void setContribution(BigDecimal contribution) { this.contribution = contribution; }

    public BigDecimal getInterestShare() { return interestShare; }
    public void setInterestShare(BigDecimal interestShare) { this.interestShare = interestShare; }

    public BigDecimal getPenalty() { return penalty; }
    public void setPenalty(BigDecimal penalty) { this.penalty = penalty; }

    public BigDecimal getAmountPayable() { return amountPayable; }
    public void setAmountPayable(BigDecimal amountPayable) { this.amountPayable = amountPayable; }

    public String getTargetGroupName() { return targetGroupName; }
    public void setTargetGroupName(String targetGroupName) { this.targetGroupName = targetGroupName; }

    public String getTargetBankAccount() { return targetBankAccount; }
    public void setTargetBankAccount(String targetBankAccount) { this.targetBankAccount = targetBankAccount; }

    public String getMomoNumber() { return momoNumber; }
    public void setMomoNumber(String momoNumber) { this.momoNumber = momoNumber; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getRequestedOn() { return requestedOn; }
    public void setRequestedOn(Timestamp requestedOn) { this.requestedOn = requestedOn; }

    public Date getProcessedOn() { return processedOn; }
    public void setProcessedOn(Date processedOn) { this.processedOn = processedOn; }

    public String getProcessedBy() { return processedBy; }
    public void setProcessedBy(String processedBy) { this.processedBy = processedBy; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}