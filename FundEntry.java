package model;

import java.math.BigDecimal;
import java.time.LocalDate;

public class FundEntry {

    private int id;
    private String transactionType;   // 'ALLOCATION' | 'LOAN_OUT' | 'REPAYMENT'
    private BigDecimal amount;
    private String phoneNumber;
    private String note;
    private LocalDate createdOn;

    public FundEntry() {
    }

    public FundEntry(int id, String transactionType, BigDecimal amount,
                     String phoneNumber, String note, LocalDate createdOn) {
        this.id = id;
        this.transactionType = transactionType;
        this.amount = amount;
        this.phoneNumber = phoneNumber;
        this.note = note;
        this.createdOn = createdOn;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public LocalDate getCreatedOn() {
        return createdOn;
    }

    public void setCreatedOn(LocalDate createdOn) {
        this.createdOn = createdOn;
    }

    @Override
    public String toString() {
        return "FundEntry{" +
                "id=" + id +
                ", transactionType='" + transactionType + '\'' +
                ", amount=" + amount +
                ", phoneNumber='" + phoneNumber + '\'' +
                ", note='" + note + '\'' +
                ", createdOn=" + createdOn +
                '}';
    }
}