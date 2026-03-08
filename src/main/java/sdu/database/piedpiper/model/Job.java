package sdu.database.piedpiper.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Job {
    private Long          id;
    private Long          clientId;
    private String        title;
    private String        description;
    private String        budgetType;
    private BigDecimal    minBudget;
    private BigDecimal    maxBudget;
    private String        statusName;
    private LocalDateTime createdAt;


    public Long getId()                    { return id; }
    public void setId(Long id)             { this.id = id; }

    public Long getClientId()              { return clientId; }
    public void setClientId(Long v)        { this.clientId = v; }

    public String getTitle()               { return title; }
    public void setTitle(String v)         { this.title = v; }

    public String getDescription()         { return description; }
    public void setDescription(String v)   { this.description = v; }

    public String getBudgetType()          { return budgetType; }
    public void setBudgetType(String v)    { this.budgetType = v; }

    public BigDecimal getMinBudget()       { return minBudget; }
    public void setMinBudget(BigDecimal v) { this.minBudget = v; }

    public BigDecimal getMaxBudget()       { return maxBudget; }
    public void setMaxBudget(BigDecimal v) { this.maxBudget = v; }

    public String getStatusName()          { return statusName; }
    public void setStatusName(String v)    { this.statusName = v; }

    public LocalDateTime getCreatedAt()    { return createdAt; }
    public void setCreatedAt(LocalDateTime v) { this.createdAt = v; }
}
