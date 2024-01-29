class Property {
  int id;
  String name;
  String tenantName;
  String tenantPhone;

  Property(
      {required this.id,
      required this.name,
      this.tenantName = '',
      this.tenantPhone = ''});

  bool get isOccupied => tenantPhone.isNotEmpty;

  // This method updates the tenant's name and occupancy status of the property.
  void updateTenant(String newTenantName, String newTenantPhone) {
    tenantName = newTenantName;
    tenantPhone = newTenantName;
  }

  // Converts a Property object into a Map. Useful for database operations.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'tenantName': tenantName,
      'tenantPhone': tenantPhone,
    };
  }

  // Creates a Property object from a Map. Useful for database operations.
  static Property fromMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'],
      name: map['name'],
      tenantName: map['tenantName'] ?? '',
      tenantPhone: map['tenantPhone'] ?? '',
    );
  }
}
