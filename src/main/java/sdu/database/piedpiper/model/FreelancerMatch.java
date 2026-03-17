package sdu.database.piedpiper.model;

import java.math.BigDecimal;

public class FreelancerMatch {
    private Long       profileId;
    private String     fullName;
    private BigDecimal hourlyRate;
    private String     email;
    private Double     matchPct;
    private Double     rating;
    private BigDecimal totalEarnings;
    private Integer    activeJobs;
    private Boolean    isAvailable;

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

    public Double getRating() { return rating; }
    public void setRating(Double rating) { this.rating = rating; }

    public BigDecimal getTotalEarnings() { return totalEarnings; }
    public void setTotalEarnings(BigDecimal totalEarnings) { this.totalEarnings = totalEarnings; }

    public Integer getActiveJobs() { return activeJobs; }
    public void setActiveJobs(Integer activeJobs) { this.activeJobs = activeJobs; }

    public Boolean getIsAvailable() { return isAvailable; }
    public void setIsAvailable(Boolean isAvailable) { this.isAvailable = isAvailable; }
}

