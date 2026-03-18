package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.request.CompleteJobRequest;
import sdu.database.piedpiper.repository.ContractRepository;

@Service
public class ContractService {

    private static final Logger log = LoggerFactory.getLogger(ContractService.class);
    private final ContractRepository contractRepository;

    public ContractService(ContractRepository contractRepository) {
        this.contractRepository = contractRepository;
    }

    public void completeJobAndRate(CompleteJobRequest request) {
        log.info("Client is attempting to complete contract ID: {} with rating: {}", 
                 request.getContractId(), request.getRating());

        // Вызываем PL/pgSQL процедуру, которая обновит 4 таблицы за одну транзакцию
        contractRepository.completeJobAndRate(
                request.getContractId(),
                request.getRating(),
                request.getFeedback()
        );
    }
}