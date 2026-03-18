package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.request.SubmitProposalRequest;
import sdu.database.piedpiper.model.Proposal;
import sdu.database.piedpiper.repository.ProposalRepository;

import java.util.List;

@Service
public class ProposalService {

    private static final Logger log = LoggerFactory.getLogger(ProposalService.class);
    private final ProposalRepository proposalRepository;

    public ProposalService(ProposalRepository proposalRepository) {
        this.proposalRepository = proposalRepository;
    }

    public void submitProposal(SubmitProposalRequest request) {
        log.info("Freelancer ID: {} is submitting a proposal for Job ID: {}", 
                 request.getFreelancerId(), request.getJobId());

        proposalRepository.submitProposal(
                request.getJobId(),
                request.getFreelancerId(),
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
}