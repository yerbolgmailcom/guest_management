import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/property.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DatabaseService dbService;
  late List<Property> properties = [];

  @override
  void initState() {
    super.initState();
    dbService = DatabaseService();
    _loadProperties();
  }

  void _loadProperties() async {
    properties = await dbService.getProperties();
    setState(() {});
  }

  void _updatePropertyStatus(Property property) async {
    if (property.isOccupied) {
      // Show dialog to confirm vacating the property
      final bool confirmVacate = await _showVacateConfirmationDialog() ?? false;
      if (confirmVacate) {
        property.updateTenant('', '');
        Fluttertoast.showToast(msg: '${property.name} свободен');
        await dbService.updateProperty(property);
      }
    } else {
      await _selectTenant(property);
    }
    _loadProperties(); // Reload properties to reflect the change
  }

  Future<bool?> _showVacateConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Подтвердите действие'),
          content: const Text('Вы действительно хотите освободить квартиру?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop(false); // Dismiss dialog with 'false'
              },
            ),
            TextButton(
              child: const Text('Освободить'),
              onPressed: () {
                Navigator.of(context).pop(true); // Dismiss dialog with 'true'
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectTenant(Property property) async {
    try {
      // Request and check contacts permission
      if (!(await Permission.contacts.isGranted) &&
          !(await Permission.contacts.request().isGranted)) {
        Fluttertoast.showToast(msg: 'Доступ к контактам не предоставлен');
        return;
      }

      final Contact? contact = await ContactsService.openDeviceContactPicker();
      final String phoneNumber =
          contact?.phones?.first.value?.replaceAll(RegExp(r'\D'), '') ?? '';
      if (phoneNumber.length < 10)
        throw 'Неверный или отсутствующий номер телефона';

      property.updateTenant(contact!.displayName ?? '',
          phoneNumber.substring(phoneNumber.length - 10));
      Fluttertoast.showToast(
          msg:
              '${property.name} заселен ${contact?.displayName ?? 'Неизвестно'} (${property.tenantPhone})');
      await dbService.updateProperty(property);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Ошибка: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Система учета гостей'),
      ),
      body: properties == null
          ? const CircularProgressIndicator()
          : ListView.builder(
              itemCount: properties.length,
              itemBuilder: (context, index) {
                var property = properties[index];
                return ListTile(
                  title: Text(property.name),
                  subtitle: Text(property.isOccupied
                      ? 'Заселен ${property.tenantName}'
                      : 'Свободно'),
                  onTap: () => _updatePropertyStatus(property),
                );
              },
            ),
    );
  }
}
