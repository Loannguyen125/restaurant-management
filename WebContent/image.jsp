<%@ page pageEncoding="UTF-8" trimDirectiveWhitespaces="true" import="java.nio.file.Files,java.nio.file.Path" %>
<%
    // Đọc lại ảnh trên ổ đĩa từ phiên bản cũ khi URL đã được chuyển sang cột image.
    String filename = request.getParameter("file");
    if (filename == null || !filename.matches("[0-9a-f-]{36}\\.png")) {
        response.sendError(404);
        return;
    }
    String configuredDir = System.getenv("RMS_UPLOAD_DIR");
    Path uploadDir = configuredDir == null || configuredDir.isBlank()
            ? Path.of(System.getProperty("catalina.base"), "uploads", "restaurant-management")
            : Path.of(configuredDir);
    Path file = uploadDir.resolve(filename);
    if (!Files.isRegularFile(file)) {
        response.sendError(404);
        return;
    }
    response.setContentType("image/png");
    response.setContentLengthLong(Files.size(file));
    Files.copy(file, response.getOutputStream());
%>
