import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/event.dart';
import '../widgets/footer.dart';
import 'package:intl/intl.dart';


class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _feeController = TextEditingController();
  final _feeLinkController = TextEditingController();
  File? _thumbnailImage;
  bool _isFreeEvent = true;
  List<DateTime> _selectedDates = [];

  Future<void> _pickThumbnailImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _thumbnailImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _selectDates() async {
    final List<DateTime> pickedDates = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiDatePickerDialog(initiallySelectedDates: _selectedDates);
      },
    );

    if (pickedDates != null && pickedDates.isNotEmpty) {
      setState(() {
        _selectedDates = pickedDates;
        _dateController.text = _selectedDates.map((date) => DateFormat('yyyy-MM-dd').format(date)).join(', ');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Event Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Event Dates'),
                readOnly: true,
                onTap: _selectDates,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select dates';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Event Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Event Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SwitchListTile(
                title: Text('Is this event free?'),
                value: _isFreeEvent,
                onChanged: (value) {
                  setState(() {
                    _isFreeEvent = value;
                  });
                },
              ),
              if (!_isFreeEvent) ...[
                TextFormField(
                  controller: _feeController,
                  decoration: InputDecoration(labelText: 'Event Fee (RM)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a fee';
                    }
                    final fee = double.tryParse(value.replaceFirst('RM', ''));
                    if (fee == null || fee < 0.05 || fee > 0.95) {
                      return 'Please enter a valid fee between RM0.05 and RM0.95';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _feeLinkController,
                  decoration: InputDecoration(labelText: 'Fee Link'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a fee link';
                    }
                    return null;
                  },
                ),
              ],
              ElevatedButton(
                onPressed: _pickThumbnailImage,
                child: Text('Pick Thumbnail Image'),
              ),
              _thumbnailImage != null
                  ? Image.file(
                      _thumbnailImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : SizedBox(height: 200),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newEvent = Event(
                      id: UniqueKey().toString(),
                      title: _titleController.text,
                      dates: _selectedDates,
                      location: _locationController.text,
                      isFree: _isFreeEvent,
                      fee: _isFreeEvent ? 0.0 : double.parse(_feeController.text.replaceFirst('RM', '')),
                      feeLink: _feeLinkController.text,
                      description: _descriptionController.text,
                      thumbnailUrl: _thumbnailImage?.path ?? '',
                      organizer: 'MobileCraft',
                    );
                    Navigator.pop(context, newEvent);
                  }
                },
                child: Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Footer(currentIndex: 2),
    );
  }
}

class MultiDatePickerDialog extends StatefulWidget {
  final List<DateTime> initiallySelectedDates;

  MultiDatePickerDialog({required this.initiallySelectedDates});

  @override
  _MultiDatePickerDialogState createState() => _MultiDatePickerDialogState();
}

class _MultiDatePickerDialogState extends State<MultiDatePickerDialog> {
  List<DateTime> _selectedDates = [];

  @override
  void initState() {
    super.initState();
    _selectedDates = widget.initiallySelectedDates;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Event Dates'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );

              if (pickedDate != null && !_selectedDates.contains(pickedDate)) {
                setState(() {
                  _selectedDates.add(pickedDate);
                });
              }
            },
            child: Text('Add Date'),
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8.0,
            children: _selectedDates.map((date) {
              return Chip(
                label: Text(DateFormat('yyyy-MM-dd').format(date)),
                onDeleted: () {
                  setState(() {
                    _selectedDates.remove(date);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _selectedDates);
          },
          child: Text('Done'),
        ),
      ],
    );
  }
}
