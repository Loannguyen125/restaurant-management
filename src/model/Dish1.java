package model;

public class Dish1 {
    private int id;
    private String name;
    private int price;
    private String unit;
    private String image;

    public Dish1(int id, String name, int price, String unit, String image) {
        this.id = id;
        this.name = name;
        this.price = price;
        this.unit = unit;
        this.image = image;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public int getPrice() {
        return price;
    }

    public String getUnit() {
        return unit;
    }

    public String getImage() {
        return image;
    }
}
