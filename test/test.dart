import 'package:test/test.dart';

import '../bin/_utils.dart' as _utils;
import 'json_objects.dart';

void main() {
  _testBinUtils();
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

void _testBinUtils() {
  test('_utils: capitalizeIdentifier()', () {
    var result = _utils.capitalizeIdentifier('abc');
    expect(result, 'Abc');
    result = _utils.capitalizeIdentifier('_abc');
    expect(result, '_Abc');
    result = _utils.capitalizeIdentifier('\$abc');
    expect(result, '\$Abc');
    result = _utils.capitalizeIdentifier('_\$abc');
    expect(result, '_\$Abc');
    result = _utils.capitalizeIdentifier('\$_abc');
    expect(result, '\$_Abc');
    result = _utils.capitalizeIdentifier('_');
    expect(result, '_');
    result = _utils.capitalizeIdentifier('');
    expect(result, '');
  });

  test('_utils: camelizeIdentifier()', () {
    var result = _utils.camelizeIdentifier('');
    expect(result, '');
    result = _utils.camelizeIdentifier('abc');
    expect(result, 'abc');
    result = _utils.camelizeIdentifier('abc_');
    expect(result, 'abc_');
    result = _utils.camelizeIdentifier('abc_def_');
    expect(result, 'abcDef_');
    result = _utils.camelizeIdentifier('abc_def');
    expect(result, 'abcDef');
    result = _utils.camelizeIdentifier('_abc_def');
    expect(result, '_abcDef');
    result = _utils.camelizeIdentifier('__abc_def');
    expect(result, '__abcDef');
    result = _utils.camelizeIdentifier('abc__def');
    expect(result, 'abc_Def');
    result = _utils.camelizeIdentifier('_abc__def');
    expect(result, '_abc_Def');
    result = _utils.camelizeIdentifier('__abc__def');
    expect(result, '__abc_Def');
  });

  test('_utils: convertToIdentifier()', () {
    var replacement = '\$';
    var result = _utils.convertToIdentifier('1abc', replacement);
    expect(result, '\$abc');
    result = _utils.convertToIdentifier('a:bc', replacement);
    expect(result, 'a\$bc');
    result = _utils.convertToIdentifier('abc?', replacement);
    expect(result, 'abc\$');
  });

  test('_utils: isValidDate()', () {
    var result = _utils.isValidDate('2018');
    expect(result, false);
    result = _utils.isValidDate('2018-12');
    expect(result, false);
    result = _utils.isValidDate('2018-12-01');
    expect(result, true);
    result = _utils.isValidDate('92998-3874');
    expect(result, false);
  });

  test('_utils: makePublicIdentifier()', () {
    var result = _utils.makePublicIdentifier('', 'temp');
    expect(result, 'temp');
    result = _utils.makePublicIdentifier('_', 'temp');
    expect(result, 'temp_');
    result = _utils.makePublicIdentifier('__', 'temp');
    expect(result, 'temp__');
    result = _utils.makePublicIdentifier('abc', 'temp');
    expect(result, 'abc');
    result = _utils.makePublicIdentifier('_abc', 'temp');
    expect(result, 'abc_');
    result = _utils.makePublicIdentifier('__abc', 'temp');
    expect(result, 'abc__');
  });
}

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
      'is_shipped': true,
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
    value = json.unmarshal(3, type: double);
    expected = 3.0;
    expect(value, expected);
  });

  test('Serialize "int" instance', () {
    var value = 1;
    var jsonValue = json.marshal(value);
    var expected = 1;
    expect(jsonValue, expected);
    _transform(value);
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

  test('Convert "int" => "String"', () {
    var value = 1;
    var jsonValue = json.marshal(value, type: String);
    var expected = '1';
    expect(jsonValue, expected);
    var value2 = json.unmarshal(jsonValue, type: int);
    expect(value2, value);
  });

  test('Convert "String" => "int"', () {
    var value = '1';
    var jsonValue = json.marshal(value, type: int);
    var expected = 1;
    expect(jsonValue, expected);
    var value2 = json.unmarshal(jsonValue, type: String);
    expect(value2, value);
  });

  test('Convert "int" => "double"', () {
    var value = 1;
    var jsonValue = json.marshal(value, type: double);
    var expected = 1.0;
    expect(jsonValue, expected);
    var value2 = json.unmarshal(jsonValue, type: int);
    expect(value2, value);
  });

  test('Convert "double" => "int"', () {
    var value = 1.0;
    var jsonValue = json.marshal(value, type: int);
    var expected = 1;
    expect(jsonValue, expected);
    var value2 = json.unmarshal(jsonValue, type: double);
    expect(value2, value);
  });

  test('Convert "double" => "String"', () {
    var value = 1.0;
    var jsonValue = json.marshal(value, type: String);
    var expected = '1.0';
    expect(jsonValue, expected);
    var value2 = json.unmarshal(jsonValue, type: double);
    expect(value2, value);
  });

  test('Convert "String" => "double"', () {
    var value = '1.0';
    var jsonValue = json.marshal(value, type: double);
    var expected = 1.0;
    expect(jsonValue, expected);
    var value2 = json.unmarshal(jsonValue, type: String);
    expect(value2, value);
  });
}

void _transform(dynamic object) {
  var type = object.runtimeType as Type;
  var jsonOject = json.marshal(object);
  var object2 = json.unmarshal(jsonOject, type: type);
  var jsonOject2 = json.marshal(object2);
  expect(jsonOject, jsonOject2);
}
