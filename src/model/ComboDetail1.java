package model;

public class ComboDetail1 {
    private int id;
    private int quantity;
    private Dish1 dish;
    private ComboMenu1 combo;

    public ComboDetail1(int id, int quantity, Dish1 dish, ComboMenu1 combo) {
        this.id = id;
        this.quantity = quantity;
        this.dish = dish;
        this.combo = combo;
    }

    public int getId() {
        return id;
    }

    public int getQuantity() {
        return quantity;
    }

    public Dish1 getDish() {
        return dish;
    }

    public ComboMenu1 getCombo() {
        return combo;
    }
}
