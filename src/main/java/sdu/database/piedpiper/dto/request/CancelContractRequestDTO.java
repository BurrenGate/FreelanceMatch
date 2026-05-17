package sdu.database.piedpiper.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CancelContractRequestDTO {
    private Long contractId;
    private Long cancelledBy;
    private String cancellationReason;
}
