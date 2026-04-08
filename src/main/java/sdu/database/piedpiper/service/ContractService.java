package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.request.CompleteJobRequest;
import sdu.database.piedpiper.model.Account;
import sdu.database.piedpiper.model.Contract;
import sdu.database.piedpiper.model.Profile;
import sdu.database.piedpiper.repository.AccountRepository;
import sdu.database.piedpiper.repository.ContractRepository;
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

    public ContractService(ContractRepository contractRepository, AccountRepository accountRepository, ProfileRepository profileRepository) {
        this.contractRepository = contractRepository;
        this.accountRepository = accountRepository;
        this.profileRepository = profileRepository;
    }

    public List<Contract> getAllContracts() {
        log.info("Fetching all contracts");
        return contractRepository.findAll();
    }

    public Optional<Contract> getContractById(Long id) {
        log.info("Fetching contract by id: {}", id);
        return contractRepository.findById(id);
    }

    public Contract createContract(Contract contract) {
        log.info("Creating new contract");
        return contractRepository.save(contract);
    }

    public Contract updateContract(Long id, Contract contract) {
        log.info("Updating contract {}", id);
        Optional<Contract> existingContract = contractRepository.findById(id);
        if (existingContract.isEmpty()) {
            throw new RuntimeException("Contract not found with id: " + id);
        }
        return contractRepository.update(id, contract);
    }

    public void deleteContract(Long id) {
        log.info("Deleting contract {}", id);
        Optional<Contract> existingContract = contractRepository.findById(id);
        if (existingContract.isEmpty()) {
            throw new RuntimeException("Contract not found with id: " + id);
        }
        contractRepository.deleteById(id);
    }

    public void completeJobAndRate(CompleteJobRequest request) {
        log.info("Client is attempting to complete contract ID: {} with rating: {}",
                 request.getContractId(), request.getRating());

        contractRepository.completeJobAndRate(
                request.getContractId(),
                request.getRating(),
                request.getFeedback()
        );
    }

    public List<Contract> getMyContracts() {
        String username = SecurityUtils.getCurrentUsername();
        Account account = accountRepository.findByEmail(username);
        if (account == null) return null;
        Profile profile = profileRepository.findByAccountId(account.getId()).orElse(null);
        if (profile == null) return null;

         if (account.getRoleId() == 1) {
             return contractRepository.findByClientId(profile.getId());
         } else {
             return contractRepository.findByFreelancerId(profile.getId());
         }
    }

    public java.math.BigDecimal getLastTransactionAmount(Long contractId) {
        log.info("Getting last transaction amount for contract {}", contractId);
        return contractRepository.getLastTransactionAmount(contractId);
    }
}
