package model;

import java.math.BigDecimal;

public class BankSetup {

    private String bankName;
    private String bankBranch;
    private String accountName;
    private String accountNumber;
    private String accountType;
    private BigDecimal feeMaintenance;
    private BigDecimal feeService;
    private BigDecimal feeOther;

    public BankSetup() {
        // default empty values so JSP EL doesn't hit nulls
        this.feeMaintenance = BigDecimal.ZERO;
        this.feeService     = BigDecimal.ZERO;
        this.feeOther       = BigDecimal.ZERO;
    }

    public String getBankName() { return bankName; }
    public void setBankName(String bankName) { this.bankName = bankName; }

    public String getBankBranch() { return bankBranch; }
    public void setBankBranch(String bankBranch) { this.bankBranch = bankBranch; }

    public String getAccountName() { return accountName; }
    public void setAccountName(String accountName) { this.accountName = accountName; }

    public String getAccountNumber() { return accountNumber; }
    public void setAccountNumber(String accountNumber) { this.accountNumber = accountNumber; }

    public String getAccountType() { return accountType; }
    public void setAccountType(String accountType) { this.accountType = accountType; }

    public BigDecimal getFeeMaintenance() { return feeMaintenance; }
    public void setFeeMaintenance(BigDecimal feeMaintenance) {
        this.feeMaintenance = (feeMaintenance == null) ? BigDecimal.ZERO : feeMaintenance;
    }

    public BigDecimal getFeeService() { return feeService; }
    public void setFeeService(BigDecimal feeService) {
        this.feeService = (feeService == null) ? BigDecimal.ZERO : feeService;
    }

    public BigDecimal getFeeOther() { return feeOther; }
    public void setFeeOther(BigDecimal feeOther) {
        this.feeOther = (feeOther == null) ? BigDecimal.ZERO : feeOther;
    }
}