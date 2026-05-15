package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.request.CancelContractRequest;
import sdu.database.piedpiper.dto.request.CompleteJobRequest;
import sdu.database.piedpiper.dto.request.ContractRequest;
import sdu.database.piedpiper.dto.response.ContractDetailsDTO;
import sdu.database.piedpiper.exception.ForbiddenOperationException;
import sdu.database.piedpiper.exception.NotFoundException;
import sdu.database.piedpiper.model.Account;
import sdu.database.piedpiper.model.Contract;
import sdu.database.piedpiper.model.Job;
import sdu.database.piedpiper.model.Profile;
import sdu.database.piedpiper.repository.AccountRepository;
import sdu.database.piedpiper.repository.ContractRepository;
import sdu.database.piedpiper.repository.JobRepository;
import sdu.database.piedpiper.repository.ProfileRepository;
import sdu.database.piedpiper.security.SecurityUtils;

import java.util.List;
import java.util.Optional;

@Service
public class ContractService {

    private static final Logger log = LoggerFactory.getLogger(ContractService.class);
    private final ContractRepository contractRepository;
    private final AccountRepository accountRepository;
    private final ProfileRepository profileRepository;
    private final JobRepository jobRepository;

    public ContractService(ContractRepository contractRepository,
                           AccountRepository accountRepository,
                           ProfileRepository profileRepository,
                           JobRepository jobRepository) {
        this.contractRepository = contractRepository;
        this.accountRepository = accountRepository;
        this.profileRepository = profileRepository;
        this.jobRepository = jobRepository;
    }

    public List<Contract> getAllContracts() {
        log.info("Fetching all contracts");
        return contractRepository.findAll();
    }

    public Optional<Contract> getContractById(Long id) {
        log.info("Fetching contract by id: {}", id);
        return contractRepository.findById(id);
    }

    public Contract createContract(ContractRequest request) {
        log.info("Creating new contract");
        if (!SecurityUtils.isClient()) {
            throw new ForbiddenOperationException("Only clients can create contracts");
        }
        Profile current = getCurrentProfile();
        Job job = jobRepository.findById(request.getJobId())
                .orElseThrow(() -> new NotFoundException("Job not found with id: " + request.getJobId()));
        if (!current.getId().equals(job.getClientId())) {
            throw new ForbiddenOperationException("You can only create contracts for your own jobs");
        }

        Contract contract = new Contract();
        contract.setJobId(request.getJobId());
        contract.setFreelancerId(request.getFreelancerId());
        contract.setTotalAmount(request.getTotalAmount());
        contract.setStatus(request.getStatus());
        return contractRepository.save(contract);
    }

    public Contract updateContract(Long id, ContractRequest request) {
        log.info("Updating contract {}", id);
        Optional<Contract> existingContract = contractRepository.findById(id);
        if (existingContract.isEmpty()) {
            throw new NotFoundException("Contract not found with id: " + id);
        }

        ensureCurrentUserOwnsContract(existingContract.get());

        Contract contract = existingContract.get();
        contract.setJobId(request.getJobId());
        contract.setFreelancerId(request.getFreelancerId());
        contract.setTotalAmount(request.getTotalAmount());
        contract.setStatus(request.getStatus());
        return contractRepository.update(id, contract);
    }

    public void deleteContract(Long id) {
        log.info("Deleting contract {}", id);
        Optional<Contract> existingContract = contractRepository.findById(id);
        if (existingContract.isEmpty()) {
            throw new NotFoundException("Contract not found with id: " + id);
        }
        ensureCurrentUserOwnsContract(existingContract.get());
        contractRepository.deleteById(id);
    }

    public void completeJobAndRate(CompleteJobRequest request) {
        log.info("Client is attempting to complete contract ID: {} with rating: {}",
                 request.getContractId(), request.getRating());

        Contract contract = contractRepository.findById(request.getContractId())
                .orElseThrow(() -> new NotFoundException("Contract not found with id: " + request.getContractId()));
        ensureCurrentUserOwnsContract(contract);

        contractRepository.completeJobAndRate(
                request.getContractId(),
                request.getRating(),
                request.getFeedback()
        );
    }

    public List<Contract> getMyContracts() {
        String username = SecurityUtils.getCurrentUsername();
        Account account = accountRepository.findByEmail(username);
        if (account == null) {
            throw new NotFoundException("Account not found for authenticated user");
        }
        Profile profile = profileRepository.findByAccountId(account.getId())
                .orElseThrow(() -> new NotFoundException("Profile not found for authenticated user"));

         if (account.getRoleId() == 1) {
             return contractRepository.findByClientId(profile.getId());
         } else {
             return contractRepository.findByFreelancerId(profile.getId());
         }
    }

    public java.math.BigDecimal getLastTransactionAmount(Long contractId) {
        log.info("Getting last transaction amount for contract {}", contractId);
        Contract contract = contractRepository.findById(contractId)
                .orElseThrow(() -> new NotFoundException("Contract not found with id: " + contractId));
        ensureCurrentUserOwnsContract(contract);
        return contractRepository.getLastTransactionAmount(contractId);
    }

    public String requestCancellation(Long contractId, CancelContractRequest request) {
        log.info("Requesting cancellation for contract {}", contractId);
        Profile currentProfile = getCurrentProfile();
        
        Contract contract = contractRepository.findById(contractId)
                .orElseThrow(() -> new NotFoundException("Contract not found with id: " + contractId));
        ensureCurrentUserOwnsContract(contract);
        
        return contractRepository.requestCancellation(contractId, currentProfile.getId(), request.getReason());
    }

    public String confirmCancellation(Long contractId) {
        log.info("Confirming cancellation for contract {}", contractId);
        Profile currentProfile = getCurrentProfile();
        
        Contract contract = contractRepository.findById(contractId)
                .orElseThrow(() -> new NotFoundException("Contract not found with id: " + contractId));
        ensureCurrentUserOwnsContract(contract);
        
        return contractRepository.confirmCancellation(contractId, currentProfile.getId());
    }

    public String rejectCancellationRequest(Long contractId) {
        log.info("Rejecting cancellation request for contract {}", contractId);
        Profile currentProfile = getCurrentProfile();
        
        Contract contract = contractRepository.findById(contractId)
                .orElseThrow(() -> new NotFoundException("Contract not found with id: " + contractId));
        ensureCurrentUserOwnsContract(contract);
        
        return contractRepository.rejectCancellationRequest(contractId, currentProfile.getId());
    }

    public ContractDetailsDTO getContractDetails(Long contractId) {
        log.info("Getting contract details for contract {}", contractId);
        Profile currentProfile = getCurrentProfile();
        
        return contractRepository.getContractDetails(contractId, currentProfile.getId())
                .orElseThrow(() -> new NotFoundException("Contract not found with id: " + contractId));
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

    private void ensureCurrentUserOwnsContract(Contract contract) {
        Profile current = getCurrentProfile();
        if (current.getId().equals(contract.getFreelancerId())) {
            return;
        }

        Job job = jobRepository.findById(contract.getJobId())
                .orElseThrow(() -> new NotFoundException("Job not found for contract " + contract.getId()));
        if (!current.getId().equals(job.getClientId())) {
            throw new ForbiddenOperationException("You can only access your own contracts");
        }
    }
}
