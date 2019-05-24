import 'dart:convert';

import 'package:marshalling/json_serializer.dart';
import 'package:test/test.dart';

void main() {
  _testJsonSerializer();
}

final _json = JsonSerializer()
  ..addType(() => Alias())
  ..addType(() => Bar())
  ..addType(() => Foo())
  ..addType(() => Order())
  ..addType(() => OrderItem())
  ..addType(() => Product())
  ..addIterableType<List<OrderItem>, OrderItem>(() => <OrderItem>[])
  ..addMapType<Map<String, Bar>, String, Bar>(() => <String, Bar>{})
  ..addAccessor('amount', (o) => o.amount, (o, v) => o.amount = v)
  ..addAccessor('clazz', (o) => o.clazz, (o, v) => o.clazz = v)
  ..addAccessor('bars', (o) => o.bars, (o, v) => o.bars = v)
  ..addAccessor('date', (o) => o.date, (o, v) => o.date = v)
  ..addAccessor('i', (o) => o.i, (o, v) => o.i = v)
  ..addAccessor('id', (o) => o.id, (o, v) => o.id = v)
  ..addAccessor('items', (o) => o.items, (o, v) => o.items = v)
  ..addAccessor('isShipped', (o) => o.isShipped, (o, v) => o.isShipped = v)
  ..addAccessor('name', (o) => o.name, (o, v) => o.name = v)
  ..addAccessor('price', (o) => o.price, (o, v) => o.price = v)
  ..addAccessor('product', (o) => o.product, (o, v) => o.product = v)
  ..addAccessor('quantity', (o) => o.quantity, (o, v) => o.quantity = v)
  ..addAccessor('s', (o) => o.s, (o, v) => o.s = v)
  ..addProperty<Alias, String>('clazz', alias: 'class')
  ..addProperty<Bar, int>('i')
  ..addProperty<Foo, Map<String, Bar>>('bars')
  ..addProperty<Order, double>('amount')
  ..addProperty<Order, DateTime>('date')
  ..addProperty<Order, List<OrderItem>>('items')
  ..addProperty<Order, bool>('isShipped')
  ..addProperty<OrderItem, num>('price')
  ..addProperty<OrderItem, Product>('product')
  ..addProperty<OrderItem, int>('quantity')
  ..addProperty<Product, int>('id')
  ..addProperty<Product, String>('name');

final List<Product> _products = [
  Product()
    ..id = 0
    ..name = 'Product 0',
  Product()
    ..id = 1
    ..name = 'Product 1'
];

void _testJsonSerializer() {
  test('Serialize "Order" instance', () {
    var order = Order();
    order.amount = 0;
    order.date = DateTime.now();
    order.items = [];
    order.isShipped = true;
    for (var i = 0; i < _products.length; i++) {
      var product = _products[i];
      var item = OrderItem();
      item.product = product;
      item.price = i;
      item.quantity = i;
      order.items.add(item);
    }

    var jsonOrder = _json.marshal(order);
    var expected = <String, dynamic>{
      'amount': 0,
      'date': order.date.toIso8601String(),
      'items': [
        {
          'product': {'id': 0, 'name': 'Product 0'},
          'price': 0,
          'quantity': 0
        },
        {
          'product': {'id': 1, 'name': 'Product 1'},
          'price': 1,
          'quantity': 1
        }
      ],
      'isShipped': true,
    };

    expect(jsonOrder, expected);
    _transform(order);
  });

  test('Serialize "Foo" instance', () {
    var foo = Foo();
    foo.bars = {};
    foo.bars['0'] = Bar()..i = 0;
    foo.bars['1'] = Bar()..i = 1;
    var jsonOrder = _json.marshal(foo);
    var expected = {
      'bars': {
        '0': {'i': 0},
        '1': {'i': 1}
      }
    };
    expect(jsonOrder, expected);
    _transform(foo);
  });

  test('Serialize "bool" instance', () {
    var value = true;
    var jsonValue = _json.marshal(value);
    var expected = true;
    expect(jsonValue, expected);
    _transform(value);
  });

  test('Serialize "DateTime" instance', () {
    var value = DateTime.now();
    var jsonValue = _json.marshal(value);
    var expected = value.toIso8601String();
    expect(jsonValue, expected);
    _transform(value);
  });

  test('Serialize "double" instance', () {
    var value = 1.0;
    var jsonValue = _json.marshal(value);
    var expected = 1.0;
    expect(jsonValue, expected);
    _transform(value);
  });

  test('Serialize "int" instance', () {
    var value = 1;
    var jsonValue = _json.marshal(value);
    var expected = 1;
    expect(jsonValue, expected);
    _transform(value);
    var jsonValue2 = _json.marshal(value, type: String);
    var expected2 = '1';
    expect(jsonValue2, expected2);
    var value2 = _json.unmarshal(jsonValue2, type: int);
    expect(value2, value);
  });

  test('Serialize "List" instance', () {
    var now = DateTime.now();
    var value = [
      true,
      1,
      "Hello",
      now,
      [1]
    ];
    var jsonValue = _json.marshal(value);
    var expected = [
      true,
      1,
      "Hello",
      now.toIso8601String(),
      [1]
    ];
    expect(jsonValue, expected);
    _transform(value);
  });

  test('Serialize the "List<Product>" instance', () {
    var value = _products;
    var jsonValue = _json.marshal(value);
    var expected = [
      {'id': 0, 'name': 'Product 0'},
      {'id': 1, 'name': 'Product 1'},
    ];
    expect(jsonValue, expected);
    _transform(value);
  });

  test('Serialize "Map" instance', () {
    var now = DateTime.now();
    var value = {
      'number': 1,
      'string': 'Hello',
      'list': [1, now]
    };
    var jsonValue = _json.marshal(value);
    var expected = {
      'number': 1,
      'string': 'Hello',
      'list': [1, now.toIso8601String()]
    };
    expect(jsonValue, expected);
    _transform(value);
  });

  test('Serialize "Map<String, Bar>" instance', () {
    var value = {
      '0': Bar()..i = 0,
      '1': Bar()..i = 1,
    };
    var jsonValue = _json.marshal(value);
    var expected = {
      '0': {'i': 0},
      '1': {'i': 1},
    };
    expect(jsonValue, expected);
    _transform(value);
  });

  test('Serialize "Alias" instance', () {
    var value = Alias()..clazz = 'foo';
    var jsonValue = _json.marshal(value);
    var expected = {
      'class': 'foo',
    };
    expect(jsonValue, expected);
    _transform(value);
  });
}

void _transform(dynamic object) {
  var type = object.runtimeType as Type;
  var jsonOject = _json.marshal(object);
  var object2 = _json.unmarshal(jsonOject, type: type);
  var jsonOject2 = _json.marshal(object2);
  expect(jsonOject, jsonOject2);
}

class Alias {
  String clazz;
}

class Bar {
  int i;
}

class Foo {
  Map<String, Bar> bars;
}

class Order {
  double amount;
  DateTime date;
  List<OrderItem> items;
  bool isShipped;
}

class OrderItem {
  Product product;
  int quantity;
  num price;
}

class Product {
  int id;
  String name;
}
