package sdu.database.piedpiper.service;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.User;
import sdu.database.piedpiper.dto.request.ProposalUpdateRequest;
import sdu.database.piedpiper.dto.request.ReviewRequest;
import sdu.database.piedpiper.dto.request.SubmitProposalRequest;
import sdu.database.piedpiper.dto.response.JobDTO;
import sdu.database.piedpiper.exception.ForbiddenOperationException;
import sdu.database.piedpiper.model.Account;
import sdu.database.piedpiper.model.Job;
import sdu.database.piedpiper.model.Profile;
import sdu.database.piedpiper.model.Proposal;
import sdu.database.piedpiper.model.Review;
import sdu.database.piedpiper.repository.AccountRepository;
import sdu.database.piedpiper.repository.JobRepository;
import sdu.database.piedpiper.repository.JobRequiredSkillRepository;
import sdu.database.piedpiper.repository.ProfileRepository;
import sdu.database.piedpiper.repository.ProposalRepository;
import sdu.database.piedpiper.repository.ReviewRepository;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ServiceLogicSmokeTest {

    @Mock
    private ProposalRepository proposalRepository;
    @Mock
    private AccountRepository accountRepository;
    @Mock
    private ProfileRepository profileRepository;

    @InjectMocks
    private ProposalService proposalService;

    @Mock
    private ReviewRepository reviewRepository;

    @InjectMocks
    private ReviewService reviewService;

    @Mock
    private JobRepository jobRepository;
    @Mock
    private JobRequiredSkillRepository jobRequiredSkillRepository;

    @InjectMocks
    private JobService jobService;

    @AfterEach
    void cleanupSecurityContext() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void submitProposal_usesProfileIdFromJwtContext_notAccountId() {
        authenticateAs("freelancer@mail.com");

        Account account = org.mockito.Mockito.mock(Account.class);
        doReturn(10L).when(account).getId();
        when(accountRepository.findByEmail("freelancer@mail.com")).thenReturn(account);

        Profile profile = org.mockito.Mockito.mock(Profile.class);
        doReturn(77L).when(profile).getId();
        when(profileRepository.findByAccountId(10L)).thenReturn(Optional.of(profile));

        SubmitProposalRequest request = org.mockito.Mockito.mock(SubmitProposalRequest.class);
        doReturn(5L).when(request).getJobId();
        doReturn(new BigDecimal("150")).when(request).getBidAmount();
        doReturn("Ready to help").when(request).getCoverLetter();

        proposalService.submitProposal(request);

        verify(proposalRepository).submitProposal(5L, 77L, new BigDecimal("150"), "Ready to help");
    }

    @Test
    void createReview_setsReviewerFromAuthenticatedProfile() {
        authenticateAs("client@mail.com");

        Account account = org.mockito.Mockito.mock(Account.class);
        doReturn(20L).when(account).getId();
        when(accountRepository.findByEmail("client@mail.com")).thenReturn(account);

        Profile profile = org.mockito.Mockito.mock(Profile.class);
        doReturn(33L).when(profile).getId();
        when(profileRepository.findByAccountId(20L)).thenReturn(Optional.of(profile));

        when(reviewRepository.save(any(Review.class))).thenAnswer(inv -> inv.getArgument(0));

        ReviewRequest request = org.mockito.Mockito.mock(ReviewRequest.class);
        doReturn(4L).when(request).getContractId();
        doReturn(5).when(request).getRating();
        doReturn("Excellent").when(request).getComment();

        reviewService.createReview(request);

        ArgumentCaptor<Review> captor = ArgumentCaptor.forClass(Review.class);
        verify(reviewRepository).save(captor.capture());
        assertEquals(33L, captor.getValue().getReviewerId());
        assertEquals(4L, captor.getValue().getContractId());
    }

    @Test
    void updateReview_forbiddenWhenTryingToEditAnotherUsersReview() {
        authenticateAs("client@mail.com");

        Account account = org.mockito.Mockito.mock(Account.class);
        doReturn(20L).when(account).getId();
        when(accountRepository.findByEmail("client@mail.com")).thenReturn(account);

        Profile current = org.mockito.Mockito.mock(Profile.class);
        doReturn(33L).when(current).getId();
        when(profileRepository.findByAccountId(20L)).thenReturn(Optional.of(current));

        Review existing = org.mockito.Mockito.mock(Review.class);
        doReturn(999L).when(existing).getReviewerId();
        when(reviewRepository.findById(100L)).thenReturn(Optional.of(existing));

        ReviewRequest request = org.mockito.Mockito.mock(ReviewRequest.class);
        doReturn(4).when(request).getRating();

        assertThrows(ForbiddenOperationException.class, () -> reviewService.updateReview(100L, request));
    }

    @Test
    void updateProposal_forbiddenWhenTryingToEditAnotherFreelancersProposal() {
        authenticateAs("freelancer@mail.com");

        Account account = org.mockito.Mockito.mock(Account.class);
        doReturn(10L).when(account).getId();
        when(accountRepository.findByEmail("freelancer@mail.com")).thenReturn(account);

        Profile current = org.mockito.Mockito.mock(Profile.class);
        doReturn(77L).when(current).getId();
        when(profileRepository.findByAccountId(10L)).thenReturn(Optional.of(current));

        Proposal proposal = org.mockito.Mockito.mock(Proposal.class);
        doReturn(999L).when(proposal).getFreelancerId();
        when(proposalRepository.findById(7L)).thenReturn(Optional.of(proposal));

        ProposalUpdateRequest request = org.mockito.Mockito.mock(ProposalUpdateRequest.class);

        assertThrows(ForbiddenOperationException.class, () -> proposalService.updateProposal(7L, request));
    }

    @Test
    void updateJob_forbiddenWhenCurrentClientIsNotOwner() {
        authenticateAs("client@mail.com");

        Account account = org.mockito.Mockito.mock(Account.class);
        doReturn(50L).when(account).getId();
        when(accountRepository.findByEmail("client@mail.com")).thenReturn(account);

        Profile currentProfile = org.mockito.Mockito.mock(Profile.class);
        doReturn(2L).when(currentProfile).getId();
        when(profileRepository.findByAccountId(50L)).thenReturn(Optional.of(currentProfile));

        Job existingJob = org.mockito.Mockito.mock(Job.class);
        doReturn(999L).when(existingJob).getClientId();
        when(jobRepository.findById(1L)).thenReturn(Optional.of(existingJob));

        JobDTO dto = org.mockito.Mockito.mock(JobDTO.class);

        assertThrows(ForbiddenOperationException.class, () -> jobService.updateJob(1L, dto));
    }

    private void authenticateAs(String email) {
        User principal = new User(email, "x", Collections.emptyList());
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(principal, null, principal.getAuthorities())
        );
    }
}
