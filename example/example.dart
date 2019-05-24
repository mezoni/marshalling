import 'json_objects.dart';

void main() {
  var products = _getProducts();
  var order = _createOrder();
  _addItemsToOrder(order, products);
  var jsonOrder = json.marshal(order);  
  print(jsonOrder);
  order = json.unmarshal<Order>(jsonOrder);  
  
  //
  var orderItems = order.items;
  var jsonOrderItems = json.marshal(orderItems);  
  print(jsonOrderItems);
  order.items = json.unmarshal<List<OrderItem>>(jsonOrderItems);
  jsonOrderItems = json.marshal(orderItems);  
  
  //
  var messages = Messages();
  messages.messages = [];
  messages.messages.add(['Hello', 'Goodbye']);
  messages.messages.add(['Yes', 'No']);
  var jsonMessages = json.marshal(messages);  
  print(jsonMessages);
  messages = json.unmarshal<Messages>(jsonMessages);
  jsonMessages = json.marshal(messages);
  
  //
  var withMap = ObjectWithMap();
  withMap.products = {};
  for (var product in products) {
    withMap.products[product.name] = product;
  }

  var jsonWithMap = json.marshal(withMap);  
  print(jsonWithMap);
  withMap = json.unmarshal<ObjectWithMap>(jsonWithMap);
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
