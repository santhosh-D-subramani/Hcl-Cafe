class ItemModel {
  String shopName;
  String itemName;
  int itemPrice;
  String availability;
  String itemImage;
  int freshness;
  double freshnessProbability;

  ItemModel(
      this.shopName, this.availability, this.itemName, this.itemPrice, this.itemImage, this.freshness, this.freshnessProbability);
}
