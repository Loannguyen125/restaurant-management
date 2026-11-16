<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ include file="/WEB-INF/jspf/manager.jspf" %>
<%
    String pageTitle = "Manage Combo Information";
    String savedComboCode = (String) session.getAttribute("savedComboCode");
    session.removeAttribute("savedComboCode");
%>
<%@ include file="/WEB-INF/jspf/banner.jspf" %>
<nav class="page-navigation" aria-label="Back">
    <a class="button secondary back" href="ManagerHomeFrm1.jsp">Back</a>
</nav>
<main class="shell">
    <section class="menu-panel">
        <h1>Manage Combo Information</h1>
        <% if (savedComboCode != null) { %>
            <p class="notice success" role="status">Add new combo successfully<%= savedComboCode.isEmpty() ? "" : " · " + html(savedComboCode) %></p>
        <% } %>
        <div class="menu-actions">
            <a class="button primary" id="addCombo" href="AddComboFrm1.jsp">Add new combo</a>
        </div>
    </section>
</main>
</body></html>
