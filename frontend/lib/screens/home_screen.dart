import 'package:flutter/material.dart';
import '../models/event.dart';
import '../widgets/event_card.dart';
import '../widgets/footer.dart';
import 'create_event_screen.dart';
import 'package:intl/intl.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Event> _events = [];
  List<Event> _filteredEvents = [];
  String _searchQuery = "";
  String _filter = "all";

  void _addEvent(Event event) {
    setState(() {
      _events.add(event);
      _filterEvents();
    });
  }

  void _filterEvents() {
    setState(() {
      _filteredEvents = _events.where((event) {
        final matchesSearch = event.title.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesFilter = (_filter == "all") ||
            (_filter == "before" && event.dates.first.isBefore(DateTime.now())) ||
            (_filter == "past" && event.dates.first.isAfter(DateTime.now()));
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterEvents();
    });
  }

  void _onFilterChanged(String? filter) {
    setState(() {
      _filter = filter ?? 'All Events';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
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
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: _filter,
                  onChanged: _onFilterChanged,
                  items: [
                    DropdownMenuItem(value: "all", child: Text("All")),
                    DropdownMenuItem(value: "before", child: Text("Before")),
                    DropdownMenuItem(value: "past", child: Text("Past")),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredEvents.length,
                itemBuilder: (context, index) {
                  return EventCard(event: _filteredEvents[index]);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newEvent = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateEventScreen(),
            ),
          );

          if (newEvent != null) {
            _addEvent(newEvent);
          }
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: Footer(currentIndex: 0),
    );
  }
}
