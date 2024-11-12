import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'contact_details_screen.dart'; // Import the contact details screen

class ContactInfoScreen extends StatefulWidget {
  const ContactInfoScreen({super.key});

  @override
  State<ContactInfoScreen> createState() => _ContactInfoScreenState();
}

class _ContactInfoScreenState extends State<ContactInfoScreen> {
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    if (await Permission.contacts.request().isGranted) {
      List<Contact> fetchedContacts = await ContactsService.getContacts();
      setState(() {
        contacts = fetchedContacts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Info'),
      ),
      body: contacts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          Contact contact = contacts[index];
          return ListTile(
            title: Text(contact.displayName ?? 'No Name'),
            subtitle: Text(contact.phones?.isNotEmpty == true
                ? contact.phones!.first.value!
                : 'No phone number'),
            leading: contact.avatar != null && contact.avatar!.isNotEmpty
                ? CircleAvatar(
              backgroundImage: MemoryImage(contact.avatar!),
            )
                : CircleAvatar(
              child: Text(
                contact.initials(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactDetailsScreen(contact: contact,),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
