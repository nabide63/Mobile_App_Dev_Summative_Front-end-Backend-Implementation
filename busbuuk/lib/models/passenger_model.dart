// passenger details data model - used on the Passenger Details screen
class PassengerModel {
  final String name;
  final int age;
  final String gender;
  final String seatNumber;

  PassengerModel({
    required this.name,
    required this.age,
    required this.gender,
    required this.seatNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'seatNumber': seatNumber,
    };
  }

  factory PassengerModel.fromMap(Map<String, dynamic> map) {
    return PassengerModel(
      name: map['name'] as String,
      age: map['age'] as int,
      gender: map['gender'] as String,
      seatNumber: map['seatNumber'] as String,
    );
  }
}
