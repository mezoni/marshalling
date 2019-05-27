# marshalling

The marshalling library allows to marshal and unmarshal (also serialize/deserialize) an objects (e.g. into json compatible types)

Version 0.1.8 (on development stage)

Three steps serialization (without any restrictions on nesting objects):

1. Declare the classes of plain objects (PODO)
2. Register classes, collection types, property accessors and properties
3. Automatically serialize/derialize objects

The above operations can be done manually or using sufficiently simple tools.

Below is an example of designing and generating objects (with an example of use).

## Prototype plain old objects (using "yaml" format)

json_objects.yaml

```yaml
Messages:
  messages: List<Iterable<String>>
ObjectWithMap:
  products: Map<String, Product>
Order:
  date: DateTime
  items: List<OrderItem>
  amount: double
OrderItem:
  product: Product
  quantity.qty: int
  price: double
Product:
  name: String
  id: int
```

## Auto generate source code (using the utility "yaml2podo")

json_objects.dart

```dart
// Generated by the 'yaml2podo' tool, https://pub.dev/packages/marshalling

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
  ..addIterableType<List<Iterable<String>>, Iterable<String>>(() => <Iterable<String>>[])
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

```

## Use generated code (automatically serialize/derialize objects)

example.dart

```dart
import 'json_objects.dart';

void main() {
  // Subject: Order
  var products = _getProducts();
  var order = _createOrder();
  _addItemsToOrder(order, products);

  // Serialize via `marshalling`
  var jsonOrder1 = json.marshal(order) as Map;  
  // Or serialize via `to json`
  var jsonOrder2 = order.toJson();

  print(jsonOrder1);
  print(jsonOrder2);
  
  // Deserialize via `unmarshalling`
  order = json.unmarshal<Order>(jsonOrder1);
  // Or deserialize via `from json`
  order = Order.fromJson(jsonOrder2);
      
  // Subject: Lit<OrderItem>
  var orderItems = order.items;

  // Serialize via `marshalling`
  var jsonOrderItems = json.marshal(orderItems);

  print(jsonOrderItems);
  
  // Deserialize via `unmarshalling`
  order.items = json.unmarshal<List<OrderItem>>(jsonOrderItems);  
  
  // Subject: Messages
  var messages = Messages();
  messages.messages = [];
  messages.messages.add(['Hello', 'Goodbye']);
  messages.messages.add(['Yes', 'No']);

  // Serialize via `marshalling`
  var jsonMessages1 = json.marshal(messages);
  // Or serialize via `to json`
  var jsonMessages2 = messages.toJson();
  
  print(jsonMessages1);
  print(jsonMessages2);

  // Deserialize via `unmarshalling`
  messages = json.unmarshal<Messages>(jsonMessages1);  

  // Subject: ObjectWithMap
  var objectWithMap = ObjectWithMap();
  objectWithMap.products = {};
  for (var product in products) {
    objectWithMap.products[product.name] = product;
  }

  // Serialize via `marshalling`
  var jsonObjectWithMap1 = json.marshal(objectWithMap) as Map;
  // Or serialize via `to json`
  var jsonObjectWithMap2 = objectWithMap.toJson();

  print(jsonObjectWithMap1);
  print(jsonObjectWithMap2);  
  
  // Deserialize via `unmarshalling`
  objectWithMap = json.unmarshal<ObjectWithMap>(jsonObjectWithMap1);
  // Or deserialize via `from json`
  objectWithMap = ObjectWithMap.fromJson(jsonObjectWithMap1);
}

void _addItemsToOrder(Order order, List<Product> products) {
  for (var i = 0; i < products.length; i++) {
    var product = products[i];
    var orderItem = OrderItem();
    orderItem.product = product;
    orderItem.quantity = i + 1;
    orderItem.price = 10.0 + i;
    order.items.add(orderItem);
    order.amount += orderItem.quantity * orderItem.price;
  }
}

Order _createOrder() {
  var result = Order();
  result.amount = 0;
  result.date = DateTime.now();
  result.items = [];
  return result;
}

List<Product> _getProducts() {
  var result = <Product>[];
  for (var i = 0; i < 2; i++) {
    var product = Product();
    product.id = i;
    product.name = 'Product $i';
    result.add(product);
  }

  return result;
}

```
