import 'package:marshalling/json_serializer.dart';

import 'example_json_objects.dart';

final JsonSerializer json = () {
  return JsonSerializer()
    ..addType(() => Messages())
    ..addType(() => Order())
    ..addType(() => OrderItem())
    ..addType(() => Product())
    ..addType(() => ObjectWithMap())
    //
    ..addIterableType<List<OrderItem>, OrderItem>(() => <OrderItem>[])
    ..addIterableType<Iterable<String>, String>(() => <String>[])
    ..addIterableType<List<Iterable<String>>, Iterable<String>>(
        () => <Iterable<String>>[])
    //
    ..addMapType<Map<String, Product>, String, Product>(
        () => <String, Product>{})
    //
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
    //
    ..addProperty<Messages, List<Iterable<String>>>('messages')
    ..addProperty<Order, double>('amount')
    ..addProperty<Order, DateTime>('date')
    ..addProperty<Order, List<OrderItem>>('items')
    ..addProperty<OrderItem, int>('quantity')
    ..addProperty<OrderItem, double>('price')
    ..addProperty<OrderItem, Product>('product')
    ..addProperty<Product, int>('id')
    ..addProperty<Product, String>('name')
    ..addProperty<ObjectWithMap, Map<String, Product>>('products');
}();
