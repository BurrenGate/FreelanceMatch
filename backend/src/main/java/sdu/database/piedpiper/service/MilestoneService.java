package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.request.CreateMilestoneRequest;
import sdu.database.piedpiper.dto.response.MilestoneDTO;
import sdu.database.piedpiper.dto.response.PaymentSummaryDTO;
import sdu.database.piedpiper.exception.ForbiddenOperationException;
import sdu.database.piedpiper.exception.NotFoundException;
import sdu.database.piedpiper.model.Account;
import sdu.database.piedpiper.model.Profile;
import sdu.database.piedpiper.repository.AccountRepository;
import sdu.database.piedpiper.repository.MilestoneRepository;
import sdu.database.piedpiper.repository.ProfileRepository;
import sdu.database.piedpiper.security.SecurityUtils;

import java.util.List;

@Service
public class MilestoneService {

    private static final Logger log = LoggerFactory.getLogger(MilestoneService.class);
    private final MilestoneRepository milestoneRepository;
    private final AccountRepository accountRepository;
    private final ProfileRepository profileRepository;

    public MilestoneService(MilestoneRepository milestoneRepository,
                           AccountRepository accountRepository,
                           ProfileRepository profileRepository) {
        this.milestoneRepository = milestoneRepository;
        this.accountRepository = accountRepository;
        this.profileRepository = profileRepository;
    }

    public Long createMilestone(Long contractId, CreateMilestoneRequest request) {
        log.info("Creating milestone for contract {}", contractId);
        Profile currentProfile = getCurrentProfile();
        
        if (request.getTitle() == null || request.getTitle().trim().isEmpty()) {
            throw new IllegalArgumentException("Milestone title is required");
        }
        
        if (request.getAmount() == null || request.getAmount().signum() <= 0) {
            throw new IllegalArgumentException("Milestone amount must be greater than zero");
        }
        
        return milestoneRepository.createMilestone(
            contractId,
            request.getTitle(),
            request.getDescription(),
            request.getAmount(),
            request.getDueDate()
        );
    }

    public String updateMilestoneStatus(Long milestoneId, String status) {
        log.info("Updating milestone {} status to {}", milestoneId, status);
        getCurrentProfile(); // Verify authentication
        
        return milestoneRepository.updateMilestoneStatus(milestoneId, status);
    }

    public Long payMilestone(Long milestoneId) {
        log.info("Paying milestone {}", milestoneId);
        Profile currentProfile = getCurrentProfile();
        
        return milestoneRepository.payMilestone(milestoneId, currentProfile.getId());
    }

    public List<MilestoneDTO> getContractMilestones(Long contractId) {
        log.info("Getting milestones for contract {}", contractId);
        Profile currentProfile = getCurrentProfile();
        
        return milestoneRepository.getContractMilestones(contractId, currentProfile.getId());
    }

    public PaymentSummaryDTO getPaymentSummary(Long contractId) {
        log.info("Getting payment summary for contract {}", contractId);
        Profile currentProfile = getCurrentProfile();
        
        return milestoneRepository.getPaymentSummary(contractId, currentProfile.getId())
            .orElseThrow(() -> new NotFoundException("Payment summary not found for contract " + contractId));
    }

    private Profile getCurrentProfile() {
        String username = SecurityUtils.getCurrentUsername();
        if (username == null) {
            throw new ForbiddenOperationException("User is not authenticated");
        }
        Account account = accountRepository.findByEmail(username);
        if (account == null) {
            throw new NotFoundException("Account not found for authenticated user");
        }
        return profileRepository.findByAccountId(account.getId())
                .orElseThrow(() -> new NotFoundException("Profile not found for authenticated user"));
    }
}
