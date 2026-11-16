<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ include file="/WEB-INF/jspf/common.jspf" %>
<%
    if (manager != null) {
        response.sendRedirect(root + "/ql/ManagerHomeFrm1.jsp");
        return;
    }
    String pageTitle = "Home";
%>
<%@ include file="/WEB-INF/jspf/banner.jspf" %>
<main class="shell">
    <section class="menu-panel">
        <h1>Restaurant Management System</h1>
        <p>Log in as a manager to edit dishes and create combo menus.</p>
    </section>
</main>
</body></html>
