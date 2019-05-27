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
