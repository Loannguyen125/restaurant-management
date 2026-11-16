package dao;

import model.Dish1;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Locale;

public class DishDAO1 extends DAO1 {
    public DishDAO1() throws SQLException {
        super();
    }

    public Dish1[] searchDishByName(String name, Map<Integer, String> categories) throws SQLException {
        return searchDishes(name, categories, "d.name");
    }

    public Dish1[] searchDishByCategory(String name, Map<Integer, String> categories) throws SQLException {
        return searchDishes(name, categories, "c.name");
    }

    private Dish1[] searchDishes(String keyword, Map<Integer, String> categories, String column)
            throws SQLException {
        String sql = "SELECT d.id, d.name, d.price, d.unit, d.image, c.name AS category FROM tblDish1 d "
                + "JOIN tblCategory1 c ON c.id = d.tblCategory1id WHERE REPLACE(LOWER(" + column
                + "), 'đ', 'd') LIKE ? ESCAPE '!' ORDER BY d.id";
        try (var connection = getConnection(); PreparedStatement stmt = connection.prepareStatement(sql)) {
            String escaped = keyword.toLowerCase(Locale.ROOT).replace('đ', 'd')
                    .replace("!", "!!").replace("%", "!%").replace("_", "!_");
            stmt.setString(1, "%" + escaped + "%");
            try (ResultSet rows = stmt.executeQuery()) {
                List<Dish1> dishes = new ArrayList<>();
                while (rows.next()) {
                    int id = rows.getInt("id");
                    dishes.add(new Dish1(id, rows.getString("name"), rows.getInt("price"),
                            rows.getString("unit"), rows.getString("image")));
                    categories.put(id, rows.getString("category"));
                }
                return dishes.toArray(new Dish1[0]);
            }
        }
    }

    public Dish1 getDishById(int id, int[] categoryId) throws SQLException {
        String sql = "SELECT name, price, unit, image, tblCategory1id FROM tblDish1 WHERE id = ?";
        try (var connection = getConnection(); PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rows = stmt.executeQuery()) {
                if (!rows.next()) return null;
                categoryId[0] = rows.getInt("tblCategory1id");
                return new Dish1(id, rows.getString("name"), rows.getInt("price"),
                        rows.getString("unit"), rows.getString("image"));
            }
        }
    }

    public boolean updateDishInfo(Dish1 dish, int categoryId) throws SQLException {
        String sql = "UPDATE tblDish1 SET name = ?, price = ?, unit = ?, tblCategory1id = ? WHERE id = ?";
        try (var connection = getConnection(); PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, dish.getName());
            stmt.setInt(2, dish.getPrice());
            stmt.setString(3, dish.getUnit());
            stmt.setInt(4, categoryId);
            stmt.setInt(5, dish.getId());
            return stmt.executeUpdate() == 1;
        }
    }
}
