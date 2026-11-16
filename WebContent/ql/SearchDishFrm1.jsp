<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" import="dao.DishDAO1,model.Dish1,java.sql.SQLException" %>
<%@ include file="/WEB-INF/jspf/manager.jspf" %>
<%
    String pageTitle = "Search Dish Information";
    String keyword = value(request.getParameter("keyword"));
    String error = null;
    boolean searched = request.getParameter("keyword") != null;
    Dish1[] dishes = new Dish1[0];
    Map<Integer, String> categories = new HashMap<>();
    if (searched) {
        if (keyword.isEmpty()) {
            error = "Enter a dish";
        } else if (keyword.length() > 255) {
            error = "Enter at most 255 characters";
        } else {
            try {
                dishes = new DishDAO1().searchDishByName(keyword, categories);
            } catch (SQLException e) {
                application.log("Dish search failed", e);
                error = "Search failed. Please try again.";
            }
        }
    }
%>
<%@ include file="/WEB-INF/jspf/banner.jspf" %>
<nav class="page-navigation" aria-label="Back">
    <a class="button secondary back" id="btnBack" href="ManageDishFrm1.jsp">Back</a>
</nav>
<main class="shell">
    <section>
        <h1>Search Dish Information</h1>
        <form class="search-form" id="dishSearch" method="get" action="SearchDishFrm1.jsp">
            <label class="sr-only" for="searchBar">Dish name</label>
            <input id="searchBar" name="keyword" placeholder="Dish…" maxlength="255" value="<%= html(keyword) %>" autofocus>
            <button class="button primary" id="btnSearch" type="submit">Search</button>
        </form>
        <p class="notice error" role="alert" id="searchMessage"<%= error == null ? " hidden" : "" %>><%= html(error) %></p>
        <% if (searched && error == null) { %>
        <div class="table-wrap">
            <table class="data-table" id="tblListDish">
                <thead><tr><th>No.</th><th>Name</th><th>Category</th><th class="numeric">Price</th></tr></thead>
                <tbody>
                <% if (dishes.length == 0) { %>
                    <tr><td colspan="4" class="empty">No result</td></tr>
                <% } else {
                    for (int i = 0; i < dishes.length; i++) {
                        Dish1 dish = dishes[i];
                        String href = "EditDishFrm1.jsp?id=" + dish.getId() + "&keyword="
                                + java.net.URLEncoder.encode(keyword, java.nio.charset.StandardCharsets.UTF_8);
                %>
                    <tr class="dish-result" data-href="<%= html(href) %>">
                        <td><%= i + 1 %></td><td><a href="<%= html(href) %>"><%= html(dish.getName()) %></a></td>
                        <td><%= html(categories.get(dish.getId())) %></td><td class="numeric"><%= money(dish.getPrice()) %></td>
                    </tr>
                <%  }
                   } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </section>
</main>
<script src="<%= root %>/assets/dish.js" defer></script>
</body></html>
