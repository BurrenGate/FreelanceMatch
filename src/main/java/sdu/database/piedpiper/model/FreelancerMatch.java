package sdu.database.piedpiper.model;

import java.math.BigDecimal;

public class FreelancerMatch {
    private Long       profileId;
    private String     fullName;
    private BigDecimal hourlyRate;
    private String     email;
    private Double     matchPct;

    public Long getProfileId()             { return profileId; }
    public void setProfileId(Long v)       { this.profileId = v; }

    public String getFullName()            { return fullName; }
    public void setFullName(String v)      { this.fullName = v; }

    public BigDecimal getHourlyRate()      { return hourlyRate; }
    public void setHourlyRate(BigDecimal v){ this.hourlyRate = v; }

    public String getEmail()               { return email; }
    public void setEmail(String v)         { this.email = v; }

    public Double getMatchPct()            { return matchPct; }
    public void setMatchPct(Double v)      { this.matchPct = v; }
}

