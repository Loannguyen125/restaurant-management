<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" import="dao.DishDAO1,dao.ComboMenuDAO1,model.Dish1,model.ComboMenu1,model.ComboDetail1,java.sql.SQLException,java.io.ByteArrayInputStream,java.io.IOException,java.io.InputStream,javax.imageio.ImageIO,javax.imageio.ImageReader,javax.imageio.stream.ImageInputStream,javax.servlet.http.Part" %>
<%@ include file="/WEB-INF/jspf/manager.jspf" %>
<%!
    private String readComboImage(Collection<Part> parts) throws IOException {
        Part imagePart = null;
        for (Part part : parts) {
            if (!"image".equals(part.getName()) || part.getSize() == 0) continue;
            if (imagePart != null) throw new IllegalArgumentException("Choose only one image.");
            imagePart = part;
        }
        if (imagePart == null) throw new IllegalArgumentException("Choose an image for the combo.");

        if (imagePart.getSize() > 5 * 1024 * 1024) {
            throw new IllegalArgumentException("Choose an image of up to 5 MB.");
        }
        byte[] bytes;
        try (InputStream upload = imagePart.getInputStream()) {
            bytes = upload.readAllBytes();
        }

        try (ImageInputStream input = ImageIO.createImageInputStream(new ByteArrayInputStream(bytes))) {
            Iterator<ImageReader> readers = ImageIO.getImageReaders(input);
            if (!readers.hasNext()) throw new IllegalArgumentException("Choose a PNG or JPEG image.");
            ImageReader reader = readers.next();
            try {
                reader.setInput(input);
                String format = reader.getFormatName().toLowerCase(Locale.ROOT);
                if (!"png".equals(format) && !"jpeg".equals(format)) {
                    throw new IllegalArgumentException("Choose a PNG or JPEG image.");
                }
                if ((long) reader.getWidth(0) * reader.getHeight(0) > 12_000_000L) {
                    throw new IllegalArgumentException("Choose an image of up to 12 megapixels.");
                }
                reader.read(0);
                return "data:image/" + format + ";base64," + Base64.getEncoder().encodeToString(bytes);
            } finally {
                reader.dispose();
            }
        }
    }
%>
<%
    if ("POST".equals(request.getMethod())) {
        response.setContentType("text/plain;charset=UTF-8");
        try {
            Collection<Part> parts = request.getParts();
            if (!csrfToken.equals(request.getParameter("csrfToken"))) {
                response.setStatus(403);
                out.print("Add new combo failed");
                return;
            }
            String name = value(request.getParameter("name"));
            String description = value(request.getParameter("description"));
            if (name.isEmpty() || name.length() > 255 || description.length() > 255) {
                throw new IllegalArgumentException("Enter a name and a description of up to 255 characters.");
            }
            int comboPrice = price(value(request.getParameter("price")));
            String[] dishIds = request.getParameterValues("dishId");
            String[] quantities = request.getParameterValues("quantity");
            if (dishIds == null || quantities == null || dishIds.length != quantities.length || dishIds.length > 200) {
                throw new IllegalArgumentException("Choose at least one dish.");
            }
            ComboMenu1 combo = new ComboMenu1(0, name, comboPrice, description, readComboImage(parts));
            ComboDetail1[] details = new ComboDetail1[dishIds.length];
            Set<Integer> selectedIds = new HashSet<>();
            for (int i = 0; i < dishIds.length; i++) {
                int dishId = positiveInt(dishIds[i]);
                int quantity = positiveInt(quantities[i]);
                if (!selectedIds.add(dishId) || quantity > 999) {
                    throw new IllegalArgumentException("Choose each dish once and use a quantity from 1 to 999.");
                }
                details[i] = new ComboDetail1(0, quantity, new Dish1(dishId, null, 0, null, null), combo);
            }
            int comboId = new ComboMenuDAO1().addCombo(combo, details);
            session.setAttribute("savedComboCode", code("C", comboId));
            out.print("OK");
        } catch (SQLException e) {
            if (e.getErrorCode() == 1062) {
                response.setStatus(409);
                out.print("Combo existed");
            } else {
                application.log("Combo save failed", e);
                response.setStatus(500);
                out.print("Add new combo failed");
            }
        } catch (IllegalArgumentException e) {
            response.setStatus(400);
            out.print(e instanceof NumberFormatException
                    ? "Enter a valid price and dish quantities." : e.getMessage());
        } catch (IllegalStateException e) {
            response.setStatus(413);
            out.print("Choose an image of up to 5 MB.");
        } catch (IOException | javax.servlet.ServletException e) {
            response.setStatus(400);
            out.print("The image could not be read. Choose a valid PNG or JPEG image.");
        }
        return;
    }

    if ("1".equals(request.getParameter("fragment"))) {
        String keyword = value(request.getParameter("keyword"));
        String searchType = value(request.getParameter("searchType"));
        if (keyword.isEmpty() || keyword.length() > 255
                || (!"name".equals(searchType) && !"category".equals(searchType))) {
            response.setStatus(400);
            out.print("Enter a dish or category");
            return;
        }
        Dish1[] dishes;
        Map<Integer, String> categories = new HashMap<>();
        try {
            DishDAO1 dishDAO = new DishDAO1();
            dishes = "category".equals(searchType)
                    ? dishDAO.searchDishByCategory(keyword, categories) : dishDAO.searchDishByName(keyword, categories);
        } catch (SQLException e) {
            application.log("Combo dish search failed", e);
            response.setStatus(500);
            out.print("Search failed. Please try again.");
            return;
        }
        if (dishes.length == 0) {
%>
<tr><td colspan="6" class="empty">No result</td></tr>
<%
        }
        for (Dish1 dish : dishes) {
%>
<tr>
    <td><%= code("D", dish.getId()) %></td>
    <td><%= html(dish.getName()) %></td>
    <td><%= html(categories.get(dish.getId())) %></td>
    <td class="numeric"><%= money(dish.getPrice()) %></td>
    <td><%= html(dish.getUnit()) %></td>
    <td><button class="button secondary add-dish" type="button" data-id="<%= dish.getId() %>"
            data-code="<%= code("D", dish.getId()) %>" data-name="<%= html(dish.getName()) %>"
            data-price="<%= money(dish.getPrice()) %>" data-unit="<%= html(dish.getUnit()) %>">Add</button></td>
</tr>
<%
        }
        return;
    }
    String pageTitle = "Add new Combo";
%>
<%@ include file="/WEB-INF/jspf/banner.jspf" %>
<nav class="page-navigation" aria-label="Back">
    <a class="button secondary back" href="ManageComboFrm1.jsp">Back</a>
</nav>
<main class="shell">
    <section>
        <h1>Add new Combo</h1>
        <h2>General information</h2>
        <form id="addCombo" method="post" enctype="multipart/form-data" action="AddComboFrm1.jsp">
            <input type="hidden" name="csrfToken" value="<%= html(csrfToken) %>">
            <div class="menu-overview">
                <table class="info-table" id="comboInfo">
                    <tbody>
                        <tr><th scope="row"><label for="comboName">Name</label></th><td><input id="comboName" name="name" maxlength="255" required></td></tr>
                        <tr><th scope="row"><label for="comboPrice">Price</label></th><td><input id="comboPrice" name="price" inputmode="numeric" maxlength="13" required></td></tr>
                        <tr><th scope="row"><label for="comboDescription">Description</label></th><td><textarea id="comboDescription" name="description" maxlength="255" rows="2"></textarea></td></tr>
                    </tbody>
                </table>
                <div>
                    <label for="comboImage">Image (required)</label>
                    <input id="comboImage" name="image" type="file" accept="image/png,image/jpeg"
                           aria-describedby="comboImageHint" required>
                    <small id="comboImageHint">One PNG or JPEG image, up to 5 MB.</small>
                    <p id="imageMessage" class="notice error" role="alert" hidden></p>
                    <img id="previewImage" class="menu-photo" alt="Combo image preview" hidden>
                </div>
            </div>

            <h2>List Dish For Combo</h2>
            <div class="table-wrap">
                <table class="data-table" id="selectedListDish">
                    <thead><tr><th>No.</th><th>Code</th><th>Name</th><th class="numeric">Price</th><th>Unit</th><th>Quantity</th><th><span class="sr-only">Remove</span></th></tr></thead>
                    <tbody id="selectedDishes"><tr><td class="empty" colspan="7">No dishes selected</td></tr></tbody>
                </table>
            </div>
        </form>

        <h2>Search Dish</h2>
        <form id="comboSearch" class="search-form" method="get" action="AddComboFrm1.jsp">
            <label class="sr-only" for="dishSearch">Search keyword</label>
            <input id="dishSearch" name="keyword" placeholder="Dish…" maxlength="255">
            <label class="sr-only" for="searchType">Search by</label>
            <select id="searchType" name="searchType">
                <option value="category">Category</option><option value="name">Name</option>
            </select>
            <button class="button primary" id="search" type="submit">Search</button>
        </form>
        <p id="comboSearchMessage" class="notice error" role="alert" hidden></p>
        <div class="table-wrap" id="comboSearchResults" hidden>
            <table class="data-table" id="listDish">
                <thead><tr><th>ID</th><th>Name</th><th>Category</th><th class="numeric">Price</th><th>Unit</th><th><span class="sr-only">Select</span></th></tr></thead>
                <tbody id="searchResults" aria-live="polite"></tbody>
            </table>
        </div>

        <p id="saveMessage" class="notice error" role="alert" hidden></p>
        <div class="form-actions">
            <button class="button primary" id="saveCombo" form="addCombo" type="submit" disabled>Save</button>
            <a class="button secondary" id="cancel" href="ManageComboFrm1.jsp">Cancel</a>
        </div>
    </section>
</main>
<script src="<%= root %>/assets/combo.js" defer></script>
</body></html>
