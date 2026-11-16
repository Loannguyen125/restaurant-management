<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ include file="/WEB-INF/jspf/common.jspf" %>
<%
    response.setHeader("Cache-Control", "no-store");
    if (manager != null) {
        response.sendRedirect(root + "/ql/ManagerHomeFrm1.jsp");
        return;
    }
    String pageTitle = "Manager Login";
    String error = (String) request.getAttribute("loginError");
%>
<%@ include file="/WEB-INF/jspf/banner.jspf" %>
<main class="shell">
    <section class="login-panel">
        <h1>Manager Login</h1>
        <% if (error != null) { %><p class="notice error" role="alert"><%= html(error) %></p><% } %>
        <form method="post" action="<%= root %>/doLogin.jsp" class="login-form">
            <input type="hidden" name="csrfToken" value="<%= html(csrfToken) %>">
            <label for="username">Username</label>
            <input id="username" name="username" maxlength="255" autocomplete="username" required autofocus
                   value="<%= html(request.getAttribute("loginUsername")) %>">
            <label for="password">Password</label>
            <input id="password" name="password" type="password" maxlength="255" autocomplete="current-password" required>
            <button class="button primary" type="submit">Login</button>
        </form>
    </section>
</main>
</body></html>
