package model;

public class Category1 {
    private int id;
    private String name;
    private String description;
    private Dish1[] listDish;

    public Category1(int id, String name, String description, Dish1[] listDish) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.listDish = listDish;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public Dish1[] getListDish() {
        return listDish;
    }
}
