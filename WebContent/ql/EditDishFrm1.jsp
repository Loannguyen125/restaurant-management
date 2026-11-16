<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" import="dao.DishDAO1,dao.CategoryDAO1,model.Dish1,model.Category1,java.sql.SQLException" %>
<%@ include file="/WEB-INF/jspf/manager.jspf" %>
<%
    String pageTitle = "Dish Information";
    String searchHref = "SearchDishFrm1.jsp?keyword=" + java.net.URLEncoder.encode(
            value(request.getParameter("keyword")), java.nio.charset.StandardCharsets.UTF_8);
    int dishId;
    try {
        dishId = positiveInt(value(request.getParameter("id")));
    } catch (IllegalArgumentException e) {
        response.sendError(404);
        return;
    }
    String error = null;
    String failure = "Sửa thông tin món ăn thất bại";
    boolean post = "POST".equals(request.getMethod());
    boolean asyncSave = post && "save-dish".equals(request.getHeader("X-RMS-Action"));
    if (post && !csrfToken.equals(request.getParameter("csrfToken"))) {
        response.sendError(403);
        return;
    }
    Dish1 dish = null;
    Category1[] categories = new Category1[0];
    int[] categoryId = new int[1];
    String editedName = "", editedPrice = "", editedUnit = "", editedCategory = "";
    if (post) {
        editedName = value(request.getParameter("name"));
        editedPrice = value(request.getParameter("price"));
        editedUnit = value(request.getParameter("unit"));
        editedCategory = value(request.getParameter("categoryId"));
        try {
            if (editedName.isEmpty() || editedName.length() > 255 || editedUnit.isEmpty() || editedUnit.length() > 255) {
                throw new IllegalArgumentException("Name and unit are required");
            }
            int parsedPrice = price(editedPrice);
            int parsedCategory = positiveInt(editedCategory);
            Dish1 edited = new Dish1(dishId, editedName, parsedPrice, editedUnit, null);
            if (new DishDAO1().updateDishInfo(edited, parsedCategory)) {
                session.setAttribute("updatedDish", dishId);
                String editHref = "EditDishFrm1.jsp?id=" + dishId + "&keyword="
                        + java.net.URLEncoder.encode(value(request.getParameter("keyword")),
                                java.nio.charset.StandardCharsets.UTF_8);
                if (asyncSave) {
                    response.setContentType("text/plain;charset=UTF-8");
                    out.print(editHref);
                } else {
                    response.sendRedirect(editHref);
                }
                return;
            }
            error = failure;
        } catch (IllegalArgumentException e) {
            error = "Enter a valid name, category, price and unit.";
        } catch (SQLException e) {
            application.log("Dish update failed", e);
            error = failure;
        }
        if (asyncSave) {
            response.setContentType("text/plain;charset=UTF-8");
            response.setStatus(failure.equals(error) ? 500 : 400);
            out.print(error);
            return;
        }
    }
    try {
        dish = new DishDAO1().getDishById(dishId, categoryId);
        if (dish == null) {
            response.sendError(404);
            return;
        }
        categories = new CategoryDAO1().getAllCategories();
    } catch (SQLException e) {
        application.log("Dish form could not load", e);
        if (error == null) error = post ? failure : "Unable to load dish information.";
    }
    boolean updated = Integer.valueOf(dishId).equals(session.getAttribute("updatedDish"));
    if (updated) session.removeAttribute("updatedDish");
    if (!post && dish != null) {
        editedName = dish.getName();
        editedPrice = money(dish.getPrice());
        editedUnit = dish.getUnit();
        editedCategory = Integer.toString(categoryId[0]);
    }
%>
<%@ include file="/WEB-INF/jspf/banner.jspf" %>
<nav class="page-navigation" aria-label="Back">
    <a class="button secondary back" id="btnBack" href="<%= html(searchHref) %>">Back</a>
</nav>
<main class="shell">
    <section>
        <h1>Dish Information</h1>
        <% if (updated) { %><p class="notice success" role="status">Edit dish information successfully</p><% } %>
        <p id="editMessage" class="notice error" role="alert"<%= error == null ? " hidden" : "" %>><%= html(error) %></p>
        <% if (dish != null && categories.length > 0) { %>
        <form id="editDish" class="dish-edit-form" method="post" action="EditDishFrm1.jsp">
            <input type="hidden" name="csrfToken" value="<%= html(csrfToken) %>">
            <input type="hidden" name="id" value="<%= dishId %>">
            <input type="hidden" name="keyword" value="<%= html(request.getParameter("keyword")) %>">
            <div class="menu-overview">
                <div class="dish-fields">
                    <table class="info-table" id="tblDishInfo">
                        <tbody>
                            <tr><th scope="row">ID No.</th><td><%= code("D", dishId) %></td></tr>
                            <tr><th scope="row"><label for="dishName">Name</label></th><td><input id="dishName" name="name" required maxlength="255" value="<%= html(editedName) %>"></td></tr>
                            <tr><th scope="row"><label for="dishCategory">Category</label></th><td>
                                <select id="dishCategory" name="categoryId" required>
                                    <% for (Category1 category : categories) { %>
                                    <option value="<%= category.getId() %>"<%= Integer.toString(category.getId()).equals(editedCategory) ? " selected" : "" %>><%= html(category.getName()) %></option>
                                    <% } %>
                                </select>
                            </td></tr>
                            <tr><th scope="row"><label for="dishPrice">Price</label></th><td><input id="dishPrice" name="price" required inputmode="numeric" maxlength="13" value="<%= html(editedPrice) %>"></td></tr>
                            <tr><th scope="row"><label for="dishUnit">Unit</label></th><td><input id="dishUnit" name="unit" required maxlength="255" value="<%= html(editedUnit) %>"></td></tr>
                        </tbody>
                    </table>
                    <div class="form-actions">
                        <button class="button primary" id="btnSave" type="submit" disabled>Save</button>
                        <a class="button secondary" id="btnCancel" href="<%= html(searchHref) %>">Cancel</a>
                    </div>
                </div>
                <figure class="dish-image-frame">
                    <% if (dish.getImage() != null && !dish.getImage().isBlank()) { %>
                    <img id="dishImage" class="menu-photo" src="<%= html(imageSource(root, dish.getImage())) %>"
                         alt="<%= html(dish.getName()) %>">
                    <% } else { %>
                    <p class="dish-image-empty">No image available</p>
                    <% } %>
                </figure>
            </div>
        </form>
        <% } %>
    </section>
</main>
<script src="<%= root %>/assets/dish.js" defer></script>
</body></html>
