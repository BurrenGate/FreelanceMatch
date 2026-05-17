package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.response.ClientProfileDTO;
import sdu.database.piedpiper.exception.NotFoundException;
import sdu.database.piedpiper.repository.ClientProfileRepository;

@Service
public class ClientProfileService {

    private static final Logger log = LoggerFactory.getLogger(ClientProfileService.class);
    private final ClientProfileRepository clientProfileRepository;

    public ClientProfileService(ClientProfileRepository clientProfileRepository) {
        this.clientProfileRepository = clientProfileRepository;
    }

    public ClientProfileDTO getClientProfile(Long clientId) {
        log.info("Fetching profile for client: {}", clientId);
        
        try {
            ClientProfileDTO profile = clientProfileRepository.getClientProfile(clientId);
            if (profile == null) {
                throw new NotFoundException("Client profile not found with ID: " + clientId);
            }
            
            profile.setRecentJobs(clientProfileRepository.getClientJobs(clientId, 5));
            profile.setRecentReviews(clientProfileRepository.getClientReviews(clientId, 5));
            
            return profile;
        } catch (Exception e) {
            log.error("Error in getClientProfile for clientId {}: {}", clientId, e.getMessage(), e);
            throw e;
        }
    }
}
