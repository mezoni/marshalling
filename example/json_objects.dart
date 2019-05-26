// Generated by tool.

import 'package:marshalling/json_serializer.dart';

final json = JsonSerializer()
  ..addType(() => Messages())
  ..addType(() => ObjectWithMap())
  ..addType(() => Order())
  ..addType(() => OrderItem())
  ..addType(() => Product())
  ..addIterableType<List<OrderItem>, OrderItem>(() => <OrderItem>[])
  ..addMapType<Map<String, Product>, String, Product>(() => <String, Product>{})
  ..addIterableType<Iterable<String>, String>(() => <String>[])
  ..addIterableType<List<Iterable<String>>, Iterable<String>>(
      () => <Iterable<String>>[])
  ..addAccessor('amount', (o) => o.amount, (o, v) => o.amount = v)
  ..addAccessor('date', (o) => o.date, (o, v) => o.date = v)
  ..addAccessor('id', (o) => o.id, (o, v) => o.id = v)
  ..addAccessor('items', (o) => o.items, (o, v) => o.items = v)
  ..addAccessor('messages', (o) => o.messages, (o, v) => o.messages = v)
  ..addAccessor('name', (o) => o.name, (o, v) => o.name = v)
  ..addAccessor('price', (o) => o.price, (o, v) => o.price = v)
  ..addAccessor('product', (o) => o.product, (o, v) => o.product = v)
  ..addAccessor('products', (o) => o.products, (o, v) => o.products = v)
  ..addAccessor('quantity', (o) => o.quantity, (o, v) => o.quantity = v)
  ..addProperty<Messages, List<Iterable<String>>>('messages')
  ..addProperty<ObjectWithMap, Map<String, Product>>('products')
  ..addProperty<Order, double>('amount')
  ..addProperty<Order, DateTime>('date')
  ..addProperty<Order, List<OrderItem>>('items')
  ..addProperty<OrderItem, int>('quantity', alias: 'qty')
  ..addProperty<OrderItem, double>('price')
  ..addProperty<OrderItem, Product>('product')
  ..addProperty<Product, String>('name')
  ..addProperty<Product, int>('id');

class Messages {
  List<Iterable<String>> messages;

  Messages();

  factory Messages.fromJson(Map map) {
    return json.unmarshal<Messages>(map);
  }

  Map<String, dynamic> toJson() {
    return json.marshal(this) as Map<String, dynamic>;
  }
}

class ObjectWithMap {
  Map<String, Product> products;

  ObjectWithMap();

  factory ObjectWithMap.fromJson(Map map) {
    return json.unmarshal<ObjectWithMap>(map);
  }

  Map<String, dynamic> toJson() {
    return json.marshal(this) as Map<String, dynamic>;
  }
}

class Order {
  double amount;
  DateTime date;
  List<OrderItem> items;

  Order();

  factory Order.fromJson(Map map) {
    return json.unmarshal<Order>(map);
  }

  Map<String, dynamic> toJson() {
    return json.marshal(this) as Map<String, dynamic>;
  }
}

class OrderItem {
  int quantity;
  double price;
  Product product;

  OrderItem();

  factory OrderItem.fromJson(Map map) {
    return json.unmarshal<OrderItem>(map);
  }

  Map<String, dynamic> toJson() {
    return json.marshal(this) as Map<String, dynamic>;
  }
}

class Product {
  String name;
  int id;

  Product();

  factory Product.fromJson(Map map) {
    return json.unmarshal<Product>(map);
  }

  Map<String, dynamic> toJson() {
    return json.marshal(this) as Map<String, dynamic>;
  }
}
