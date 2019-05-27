// Generated by the 'yaml2podo' tool, https://pub.dev/packages/marshalling

import 'package:marshalling/json_serializer.dart';

final json = JsonSerializer()
  ..addType(() => Alias())
  ..addType(() => Bar())
  ..addType(() => Foo())
  ..addType(() => Order())
  ..addType(() => OrderItem())
  ..addType(() => Product())
  ..addIterableType<List<OrderItem>, OrderItem>(() => <OrderItem>[])
  ..addMapType<Map<String, Bar>, String, Bar>(() => <String, Bar>{})
  ..addAccessor('amount', (o) => o.amount, (o, v) => o.amount = v)
  ..addAccessor('bars', (o) => o.bars, (o, v) => o.bars = v)
  ..addAccessor('clazz', (o) => o.clazz, (o, v) => o.clazz = v)
  ..addAccessor('date', (o) => o.date, (o, v) => o.date = v)
  ..addAccessor('i', (o) => o.i, (o, v) => o.i = v)
  ..addAccessor('id', (o) => o.id, (o, v) => o.id = v)
  ..addAccessor('isShipped', (o) => o.isShipped, (o, v) => o.isShipped = v)
  ..addAccessor('items', (o) => o.items, (o, v) => o.items = v)
  ..addAccessor('name', (o) => o.name, (o, v) => o.name = v)
  ..addAccessor('price', (o) => o.price, (o, v) => o.price = v)
  ..addAccessor('product', (o) => o.product, (o, v) => o.product = v)
  ..addAccessor('quantity', (o) => o.quantity, (o, v) => o.quantity = v)
  ..addProperty<Alias, String>('clazz', alias: 'class')
  ..addProperty<Bar, int>('i')
  ..addProperty<Foo, Map<String, Bar>>('bars')
  ..addProperty<Order, double>('amount')
  ..addProperty<Order, bool>('isShipped', alias: 'is_shipped')
  ..addProperty<Order, DateTime>('date')
  ..addProperty<Order, List<OrderItem>>('items')
  ..addProperty<OrderItem, int>('quantity')
  ..addProperty<OrderItem, num>('price')
  ..addProperty<OrderItem, Product>('product')
  ..addProperty<Product, String>('name')
  ..addProperty<Product, int>('id');

class Alias {
  String clazz;

  Alias();

  factory Alias.fromJson(Map map) {
    return json.unmarshal<Alias>(map);
  }

  Map<String, dynamic> toJson() {
    return json.marshal(this) as Map<String, dynamic>;
  }
}

class Bar {
  int i;

  Bar();

  factory Bar.fromJson(Map map) {
    return json.unmarshal<Bar>(map);
  }

  Map<String, dynamic> toJson() {
    return json.marshal(this) as Map<String, dynamic>;
  }
}

class Foo {
  Map<String, Bar> bars;

  Foo();

  factory Foo.fromJson(Map map) {
    return json.unmarshal<Foo>(map);
  }

  Map<String, dynamic> toJson() {
    return json.marshal(this) as Map<String, dynamic>;
  }
}

class Order {
  double amount;
  bool isShipped;
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
  num price;
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
