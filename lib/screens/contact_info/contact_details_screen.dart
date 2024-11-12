import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';


class ContactDetailsScreen extends StatelessWidget {
  final Contact contact;

  const ContactDetailsScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.displayName ?? 'Contact Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            // Display contact name
            ListTile(
              title: Text(
                contact.displayName ?? 'No Name',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
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
            ),
            const Divider(),

            // Display phone numbers
            if (contact.phones != null && contact.phones!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Phone Numbers',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...contact.phones!.map((phone) => ListTile(
                    title: Text(phone.label ?? 'Phone'),
                    subtitle: Text(phone.value ?? ''),
                    leading: const Icon(Icons.phone),
                  )),
                ],
              ),
            const Divider(),

            // Display emails
            if (contact.emails != null && contact.emails!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Emails',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...contact.emails!.map((email) => ListTile(
                    title: Text(email.label ?? 'Email'),
                    subtitle: Text(email.value ?? ''),
                    leading: const Icon(Icons.email),
                  )),
                ],
              ),
            const Divider(),

            // Other fields can be displayed similarly
          ],
        ),
      ),
    );
  }
}
