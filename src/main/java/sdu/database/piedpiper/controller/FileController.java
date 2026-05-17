package sdu.database.piedpiper.controller;

import io.minio.StatObjectResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.dto.response.FileUploadResponse;
import sdu.database.piedpiper.service.FileStorageService;

import java.io.InputStream;

@RestController
@RequestMapping("/api/files")
public class FileController {

    private static final Logger log = LoggerFactory.getLogger(FileController.class);
    private final FileStorageService fileStorageService;

    // Max file sizes
    private static final long MAX_IMAGE_SIZE = 10 * 1024 * 1024; // 10MB
    private static final long MAX_VIDEO_SIZE = 100 * 1024 * 1024; // 100MB
    private static final long MAX_AUDIO_SIZE = 20 * 1024 * 1024; // 20MB
    private static final long MAX_DOCUMENT_SIZE = 20 * 1024 * 1024; // 20MB

    public FileController(FileStorageService fileStorageService) {
        this.fileStorageService = fileStorageService;
    }

    @PostMapping("/upload/image")
    public ResponseEntity<ApiResponse<FileUploadResponse>> uploadImage(@RequestParam("file") MultipartFile file) {
        log.debug("POST /api/files/upload/image");
        try {
            if (!fileStorageService.isValidFileType(file, "image/")) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("Invalid file type. Only images are allowed."));
            }

            if (file.getSize() > MAX_IMAGE_SIZE) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("File size exceeds maximum limit of 10MB"));
            }

            String objectName = fileStorageService.uploadFile(file, "chat/images");
            String fileUrl = fileStorageService.getFileUrl(objectName);

            FileUploadResponse response = FileUploadResponse.builder()
                    .fileName(file.getOriginalFilename())
                    .fileUrl(fileUrl)
                    .objectName(objectName)
                    .contentType(file.getContentType())
                    .size(file.getSize())
                    .category("image")
                    .build();

            return ResponseEntity.ok(ApiResponse.ok("Image uploaded successfully", response));
        } catch (Exception e) {
            log.error("Error uploading image: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to upload image: " + e.getMessage()));
        }
    }

    @PostMapping("/upload/video")
    public ResponseEntity<ApiResponse<FileUploadResponse>> uploadVideo(@RequestParam("file") MultipartFile file) {
        log.debug("POST /api/files/upload/video");
        try {
            if (!fileStorageService.isValidFileType(file, "video/")) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("Invalid file type. Only videos are allowed."));
            }

            if (file.getSize() > MAX_VIDEO_SIZE) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("File size exceeds maximum limit of 100MB"));
            }

            String objectName = fileStorageService.uploadFile(file, "chat/videos");
            String fileUrl = fileStorageService.getFileUrl(objectName);

            FileUploadResponse response = FileUploadResponse.builder()
                    .fileName(file.getOriginalFilename())
                    .fileUrl(fileUrl)
                    .objectName(objectName)
                    .contentType(file.getContentType())
                    .size(file.getSize())
                    .category("video")
                    .build();

            return ResponseEntity.ok(ApiResponse.ok("Video uploaded successfully", response));
        } catch (Exception e) {
            log.error("Error uploading video: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to upload video: " + e.getMessage()));
        }
    }

    @PostMapping("/upload/audio")
    public ResponseEntity<ApiResponse<FileUploadResponse>> uploadAudio(@RequestParam("file") MultipartFile file) {
        log.debug("POST /api/files/upload/audio");
        try {
            if (!fileStorageService.isValidFileType(file, "audio/")) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("Invalid file type. Only audio files are allowed."));
            }

            if (file.getSize() > MAX_AUDIO_SIZE) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("File size exceeds maximum limit of 20MB"));
            }

            String objectName = fileStorageService.uploadFile(file, "chat/audio");
            String fileUrl = fileStorageService.getFileUrl(objectName);

            FileUploadResponse response = FileUploadResponse.builder()
                    .fileName(file.getOriginalFilename())
                    .fileUrl(fileUrl)
                    .objectName(objectName)
                    .contentType(file.getContentType())
                    .size(file.getSize())
                    .category("audio")
                    .build();

            return ResponseEntity.ok(ApiResponse.ok("Audio uploaded successfully", response));
        } catch (Exception e) {
            log.error("Error uploading audio: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to upload audio: " + e.getMessage()));
        }
    }

    @PostMapping("/upload/document")
    public ResponseEntity<ApiResponse<FileUploadResponse>> uploadDocument(@RequestParam("file") MultipartFile file) {
        log.debug("POST /api/files/upload/document");
        try {
            if (!fileStorageService.isValidFileType(file, "application/pdf", "application/msword",
                    "application/vnd.openxmlformats", "text/")) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("Invalid file type. Only documents are allowed."));
            }

            if (file.getSize() > MAX_DOCUMENT_SIZE) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("File size exceeds maximum limit of 20MB"));
            }

            String objectName = fileStorageService.uploadFile(file, "chat/documents");
            String fileUrl = fileStorageService.getFileUrl(objectName);

            FileUploadResponse response = FileUploadResponse.builder()
                    .fileName(file.getOriginalFilename())
                    .fileUrl(fileUrl)
                    .objectName(objectName)
                    .contentType(file.getContentType())
                    .size(file.getSize())
                    .category("document")
                    .build();

            return ResponseEntity.ok(ApiResponse.ok("Document uploaded successfully", response));
        } catch (Exception e) {
            log.error("Error uploading document: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to upload document: " + e.getMessage()));
        }
    }

    @PostMapping("/upload/chat")
    public ResponseEntity<ApiResponse<FileUploadResponse>> uploadChatFile(@RequestParam("file") MultipartFile file) {
        log.debug("POST /api/files/upload/chat - file: {}, type: {}, size: {}",
                file.getOriginalFilename(), file.getContentType(), file.getSize());
        try {
            // Validate file type - supports images, videos, audio, documents, archives
            if (!fileStorageService.isValidChatFileType(file)) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error(
                                "Invalid file type. Supported: images, videos, audio, documents (PDF, Word, Excel, PowerPoint), archives (ZIP, RAR, 7Z)"));
            }

            // Determine max size based on file category
            String category = fileStorageService.getFileCategory(file.getContentType());
            long maxSize;
            String folder;

            switch (category) {
                case "image":
                    maxSize = MAX_IMAGE_SIZE;
                    folder = "chat/images";
                    break;
                case "video":
                    maxSize = MAX_VIDEO_SIZE;
                    folder = "chat/videos";
                    break;
                case "audio":
                    maxSize = MAX_AUDIO_SIZE;
                    folder = "chat/audio";
                    break;
                case "document":
                    maxSize = MAX_DOCUMENT_SIZE;
                    folder = "chat/documents";
                    break;
                case "archive":
                    maxSize = MAX_DOCUMENT_SIZE;
                    folder = "chat/archives";
                    break;
                default:
                    maxSize = MAX_DOCUMENT_SIZE;
                    folder = "chat/files";
            }

            if (file.getSize() > maxSize) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error(String.format(
                                "File size exceeds maximum limit of %dMB for %s files",
                                maxSize / (1024 * 1024), category)));
            }

            String objectName = fileStorageService.uploadFile(file, folder);
            String fileUrl = fileStorageService.getFileUrl(objectName);

            FileUploadResponse response = FileUploadResponse.builder()
                    .fileName(file.getOriginalFilename())
                    .fileUrl(fileUrl)
                    .objectName(objectName)
                    .contentType(file.getContentType())
                    .size(file.getSize())
                    .category(category)
                    .build();

            return ResponseEntity.ok(ApiResponse.ok(
                    String.format("%s uploaded successfully", category.substring(0, 1).toUpperCase() + category.substring(1)),
                    response));
        } catch (Exception e) {
            log.error("Error uploading chat file: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to upload file: " + e.getMessage()));
        }
    }

    @PostMapping("/upload/avatar")
    public ResponseEntity<ApiResponse<FileUploadResponse>> uploadAvatar(@RequestParam("file") MultipartFile file) {
        log.debug("POST /api/files/upload/avatar");
        try {
            if (!fileStorageService.isValidFileType(file, "image/")) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("Invalid file type. Only images are allowed for avatars."));
            }

            if (file.getSize() > MAX_IMAGE_SIZE) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("File size exceeds maximum limit of 10MB"));
            }

            String objectName = fileStorageService.uploadFile(file, "avatars");
            String fileUrl = fileStorageService.getFileUrl(objectName);

            FileUploadResponse response = FileUploadResponse.builder()
                    .fileName(file.getOriginalFilename())
                    .fileUrl(fileUrl)
                    .objectName(objectName)
                    .contentType(file.getContentType())
                    .size(file.getSize())
                    .category("avatar")
                    .build();

            return ResponseEntity.ok(ApiResponse.ok("Avatar uploaded successfully", response));
        } catch (Exception e) {
            log.error("Error uploading avatar: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to upload avatar: " + e.getMessage()));
        }
    }

    @PostMapping("/upload/client-photo")
    public ResponseEntity<ApiResponse<FileUploadResponse>> uploadClientPhoto(@RequestParam("file") MultipartFile file) {
        log.debug("POST /api/files/upload/client-photo");
        try {
            if (!fileStorageService.isValidFileType(file, "image/")) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("Invalid file type. Only images are allowed for client photos."));
            }

            if (file.getSize() > MAX_IMAGE_SIZE) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("File size exceeds maximum limit of 10MB"));
            }

            String objectName = fileStorageService.uploadFile(file, "client-photos");
            String fileUrl = fileStorageService.getFileUrl(objectName);

            FileUploadResponse response = FileUploadResponse.builder()
                    .fileName(file.getOriginalFilename())
                    .fileUrl(fileUrl)
                    .objectName(objectName)
                    .contentType(file.getContentType())
                    .size(file.getSize())
                    .category("client-photo")
                    .build();

            return ResponseEntity.ok(ApiResponse.ok("Client photo uploaded successfully", response));
        } catch (Exception e) {
            log.error("Error uploading client photo: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to upload client photo: " + e.getMessage()));
        }
    }

    @GetMapping("/download/{objectName:.+}")
    public ResponseEntity<InputStreamResource> downloadFile(@PathVariable String objectName) {
        log.debug("GET /api/files/download/{}", objectName);
        try {
            if (!fileStorageService.fileExists(objectName)) {
                return ResponseEntity.notFound().build();
            }

            InputStream inputStream = fileStorageService.downloadFile(objectName);
            StatObjectResponse metadata = fileStorageService.getFileMetadata(objectName);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.parseMediaType(metadata.contentType()));
            headers.setContentLength(metadata.size());
            headers.setContentDispositionFormData("attachment", objectName);

            return ResponseEntity.ok()
                    .headers(headers)
                    .body(new InputStreamResource(inputStream));
        } catch (Exception e) {
            log.error("Error downloading file: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @DeleteMapping("/{objectName:.+}")
    public ResponseEntity<ApiResponse<Void>> deleteFile(@PathVariable String objectName) {
        log.debug("DELETE /api/files/{}", objectName);
        try {
            if (!fileStorageService.fileExists(objectName)) {
                return ResponseEntity.notFound().build();
            }

            fileStorageService.deleteFile(objectName);
            return ResponseEntity.ok(ApiResponse.ok("File deleted successfully", null));
        } catch (Exception e) {
            log.error("Error deleting file: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to delete file: " + e.getMessage()));
        }
    }

    @GetMapping("/url/{objectName:.+}")
    public ResponseEntity<ApiResponse<String>> getFileUrl(@PathVariable String objectName) {
        log.debug("GET /api/files/url/{}", objectName);
        try {
            if (!fileStorageService.fileExists(objectName)) {
                return ResponseEntity.notFound().build();
            }

            String fileUrl = fileStorageService.getFileUrl(objectName);
            return ResponseEntity.ok(ApiResponse.ok("File URL generated successfully", fileUrl));
        } catch (Exception e) {
            log.error("Error generating file URL: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to generate file URL: " + e.getMessage()));
        }
    }
}
