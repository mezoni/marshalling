import 'package:test/test.dart';

import 'json_objects.dart';

void main() {
  _testJsonSerializer();
}

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

    var jsonOrder = json.marshal(order);
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
    var jsonOrder = json.marshal(foo);
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
    var jsonValue = json.marshal(value);
    var expected = true;
    expect(jsonValue, expected);
    _transform(value);
  });

  test('Serialize "DateTime" instance', () {
    var value = DateTime.now();
    var jsonValue = json.marshal(value);
    var expected = value.toIso8601String();
    expect(jsonValue, expected);
    _transform(value);
  });

  test('Serialize "double" instance', () {
    var value = 1.0;
    var jsonValue = json.marshal(value);
    var expected = 1.0;
    expect(jsonValue, expected);
    _transform(value);
  });

  test('Serialize "int" instance', () {
    var value = 1;
    var jsonValue = json.marshal(value);
    var expected = 1;
    expect(jsonValue, expected);
    _transform(value);
    var jsonValue2 = json.marshal(value, type: String);
    var expected2 = '1';
    expect(jsonValue2, expected2);
    var value2 = json.unmarshal(jsonValue2, type: int);
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
    var jsonValue = json.marshal(value);
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
    var jsonValue = json.marshal(value);
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
    var jsonValue = json.marshal(value);
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
    var jsonValue = json.marshal(value);
    var expected = {
      '0': {'i': 0},
      '1': {'i': 1},
    };
    expect(jsonValue, expected);
    _transform(value);
  });

  test('Serialize "Alias" instance', () {
    var value = Alias()..clazz = 'foo';
    var jsonValue = json.marshal(value);
    var expected = {
      'class': 'foo',
    };
    expect(jsonValue, expected);
    _transform(value);
  });
}

void _transform(dynamic object) {
  var type = object.runtimeType as Type;
  var jsonOject = json.marshal(object);
  var object2 = json.unmarshal(jsonOject, type: type);
  var jsonOject2 = json.marshal(object2);
  expect(jsonOject, jsonOject2);
}
