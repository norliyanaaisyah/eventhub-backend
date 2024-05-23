import 'package:flutter/material.dart';
import '../models/event.dart';
import '../widgets/footer.dart';
import 'package:intl/intl.dart';


class EventDetailsScreen extends StatelessWidget {
  final Event event;

  EventDetailsScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    final formattedDates = event.dates.map((date) => DateFormat('yyyy-MM-dd').format(date)).join(', ');

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Handle logout
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(event.thumbnailUrl, fit: BoxFit.cover),
            SizedBox(height: 10),
            Text(
              event.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Dates: $formattedDates', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Time: ${event.dates.first.hour}:${event.dates.first.minute}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Location: ${event.location}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Organizer: ${event.organizer}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Description:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 5),
            Text(event.description, style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            event.isFree
                ? Text('This event is free', style: TextStyle(fontSize: 18))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fee: RM${event.fee.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 5),
                      Text('Fee Link: ${event.feeLink}', style: TextStyle(fontSize: 18)),
                    ],
                  ),
          ],
        ),
      ),
      bottomNavigationBar: Footer(currentIndex: 0),
    );
  }
}
