<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ include file="/WEB-INF/jspf/common.jspf" %>
<%
    if (!"POST".equals(request.getMethod()) || !csrfToken.equals(request.getParameter("csrfToken"))) {
        response.sendError(403);
        return;
    }
    session.invalidate();
    response.sendRedirect(root + "/index.jsp");
%>
