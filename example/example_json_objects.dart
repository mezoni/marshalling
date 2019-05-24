class Messages {
  List<Iterable<String>> messages;
}

class ObjectWithMap {
  Map<String, Product> products;
}

class Order {
  double amount;
  DateTime date;
  List<OrderItem> items;
}

class OrderItem {
  double price;
  Product product;
  int quantity;
}

class Product {
  int id;
  String name;
}
