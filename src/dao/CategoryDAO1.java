package dao;

import model.Category1;
import model.Dish1;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO1 extends DAO1 {
    public CategoryDAO1() throws SQLException {
        super();
    }

    public Category1[] getAllCategories() throws SQLException {
        try (var connection = getConnection();
             var stmt = connection.prepareStatement("SELECT id, name, description FROM tblCategory1 ORDER BY id");
             var rows = stmt.executeQuery()) {
            List<Category1> categories = new ArrayList<>();
            while (rows.next()) {
                categories.add(new Category1(rows.getInt("id"), rows.getString("name"),
                        rows.getString("description"), new Dish1[0]));
            }
            return categories.toArray(new Category1[0]);
        }
    }
}
