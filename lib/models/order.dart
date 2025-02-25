class Order {
  final int id;
  final String createdAt;

  Order({required this.id, required this.createdAt});

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(id: map['id'], createdAt: map['created_at']);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'created_at': createdAt};
  }
}
