package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.response.FreelancerProfileDTO;
import sdu.database.piedpiper.exception.NotFoundException;
import sdu.database.piedpiper.repository.FreelancerProfileRepository;

import java.util.Optional;

@Service
public class FreelancerProfileService {

    private static final Logger log = LoggerFactory.getLogger(FreelancerProfileService.class);
    private final FreelancerProfileRepository freelancerProfileRepository;

    public FreelancerProfileService(FreelancerProfileRepository freelancerProfileRepository) {
        this.freelancerProfileRepository = freelancerProfileRepository;
    }

    public FreelancerProfileDTO getFreelancerProfile(Long freelancerId) {
        log.info("Fetching freelancer profile for ID: {}", freelancerId);
        
        Optional<FreelancerProfileDTO> profileOpt = freelancerProfileRepository.getFreelancerProfile(freelancerId);
        
        if (profileOpt.isEmpty()) {
            throw new NotFoundException("Freelancer profile not found with id: " + freelancerId);
        }
        
        FreelancerProfileDTO profile = profileOpt.get();
        
        // Fetch skills
        profile.setSkills(freelancerProfileRepository.getFreelancerSkills(freelancerId));
        
        // Fetch recent reviews (limit to 10)
        profile.setRecentReviews(freelancerProfileRepository.getFreelancerReviews(freelancerId, 10));
        
        log.info("Successfully retrieved profile for freelancer ID: {}", freelancerId);
        return profile;
    }
}
