<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" import="dao.UserDAO1" %>
<%@ include file="/WEB-INF/jspf/common.jspf" %>
<%
    if (!"POST".equals(request.getMethod())) {
        response.sendRedirect(root + "/LoginFrm1.jsp");
        return;
    }
    if (!csrfToken.equals(request.getParameter("csrfToken"))) {
        response.sendError(403);
        return;
    }
    String username = value(request.getParameter("username"));
    String password = request.getParameter("password");
    String loginError = "Invalid username or password";
    try {
        if (!username.isEmpty() && username.length() <= 255 && password != null
                && !password.isEmpty() && password.length() <= 255) {
            ManagementStaff1 authenticated = new UserDAO1().login(username, password);
            if (authenticated != null) {
                request.changeSessionId();
                session.setAttribute("manager", authenticated);
                session.setAttribute("csrfToken", UUID.randomUUID().toString());
                response.sendRedirect(root + "/ql/ManagerHomeFrm1.jsp");
                return;
            }
        }
    } catch (java.sql.SQLException | java.security.GeneralSecurityException e) {
        application.log("Manager login failed", e);
        loginError = "Login failed. Please try again.";
    }
    request.setAttribute("loginError", loginError);
    request.setAttribute("loginUsername", username);
    pageContext.forward("/LoginFrm1.jsp");
%>
