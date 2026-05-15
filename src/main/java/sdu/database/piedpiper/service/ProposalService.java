package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.request.SubmitProposalRequest;
import sdu.database.piedpiper.dto.request.ProposalUpdateRequest;
import sdu.database.piedpiper.dto.response.ProposalWithFreelancerDTO;
import sdu.database.piedpiper.exception.ForbiddenOperationException;
import sdu.database.piedpiper.exception.NotFoundException;
import sdu.database.piedpiper.model.Account;
import sdu.database.piedpiper.model.Profile;
import sdu.database.piedpiper.model.Proposal;
import sdu.database.piedpiper.repository.AccountRepository;
import sdu.database.piedpiper.repository.ProfileRepository;
import sdu.database.piedpiper.repository.ProposalRepository;
import sdu.database.piedpiper.security.SecurityUtils;

import java.util.List;
import java.util.Optional;

@Service
public class ProposalService {

    private static final Logger log = LoggerFactory.getLogger(ProposalService.class);
    private final ProposalRepository proposalRepository;
    private final AccountRepository accountRepository;
    private final ProfileRepository profileRepository;

    public ProposalService(ProposalRepository proposalRepository,
                           AccountRepository accountRepository,
                           ProfileRepository profileRepository) {
        this.proposalRepository = proposalRepository;
        this.accountRepository = accountRepository;
        this.profileRepository = profileRepository;
    }

    public List<Proposal> getAllProposals() {
        log.info("Fetching all proposals");
        return proposalRepository.findAll();
    }

    public Optional<Proposal> getProposalById(Long id) {
        log.info("Fetching proposal by id: {}", id);
        return proposalRepository.findById(id);
    }

    public Proposal updateProposal(Long id, ProposalUpdateRequest request) {
        log.info("Updating proposal {}", id);
        Optional<Proposal> existingProposal = proposalRepository.findById(id);
        if (existingProposal.isEmpty()) {
            throw new NotFoundException("Proposal not found with id: " + id);
        }
        Proposal proposal = existingProposal.get();
        ensureProposalOwner(proposal);
        proposal.setBidAmount(request.getBidAmount());
        proposal.setCoverLetter(request.getCoverLetter());
        return proposalRepository.update(id, proposal);
    }

    public void deleteProposal(Long id) {
        log.info("Deleting proposal {}", id);
        Optional<Proposal> existingProposal = proposalRepository.findById(id);
        if (existingProposal.isEmpty()) {
            throw new NotFoundException("Proposal not found with id: " + id);
        }
        ensureProposalOwner(existingProposal.get());
        proposalRepository.deleteById(id);
    }

    public void submitProposal(SubmitProposalRequest request) {
        String email = SecurityUtils.getCurrentUsername();
        if (email == null) {
            throw new ForbiddenOperationException("User is not authenticated");
        }

        Account account = accountRepository.findByEmail(email);
        if (account == null) {
            throw new NotFoundException("Account not found for authenticated user");
        }

        Profile profile = profileRepository.findByAccountId(account.getId())
                .orElseThrow(() -> new NotFoundException("Profile not found for authenticated user"));

        Long pId = profile.getId();
        log.info("Freelancer ID: {} (email: {}) is submitting a proposal for Job ID: {}",
                pId, email, request.getJobId());

        proposalRepository.submitProposal(
                request.getJobId(),
                pId,
                request.getBidAmount(),
                request.getCoverLetter()
        );
    }

    public List<Proposal> getProposalsForJob(Long jobId) {
        log.info("Fetching proposals for Job ID: {}", jobId);
        return proposalRepository.findByJobId(jobId);
    }

    public void acceptProposal(Long proposalId) {
        log.info("Client is accepting proposal ID: {}", proposalId);
        proposalRepository.acceptProposalAndCreateContract(proposalId);
    }

    public void rejectProposal(Long proposalId) {
        log.info("Client is rejecting proposal ID: {}", proposalId);
        proposalRepository.rejectProposal(proposalId);
    }

    public List<ProposalWithFreelancerDTO> getProposalsWithFreelancerDetails(Long jobId) {
        log.info("Fetching proposals with freelancer details for Job ID: {}", jobId);
        return proposalRepository.findProposalsWithFreelancerDetails(jobId);
    }

    private void ensureProposalOwner(Proposal proposal) {
        String email = SecurityUtils.getCurrentUsername();
        Account account = accountRepository.findByEmail(email);
        if (account == null) {
            throw new NotFoundException("Account not found for authenticated user");
        }
        Profile current = profileRepository.findByAccountId(account.getId())
                .orElseThrow(() -> new NotFoundException("Profile not found for authenticated user"));

        if (!current.getId().equals(proposal.getFreelancerId())) {
            throw new ForbiddenOperationException("You can only modify your own proposals");
        }
    }
}
