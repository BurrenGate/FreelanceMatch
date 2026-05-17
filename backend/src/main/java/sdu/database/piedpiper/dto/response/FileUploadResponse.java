package sdu.database.piedpiper.dto.response;

import lombok.*;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FileUploadResponse {
    private String fileName;
    private String fileUrl;
    private String objectName;
    private String contentType;
    private Long size;
    private String category;
}
