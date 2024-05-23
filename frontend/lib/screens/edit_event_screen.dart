import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/event.dart';
import '../widgets/footer.dart';
import 'package:intl/intl.dart';


class EditEventScreen extends StatefulWidget {
  final Event event;

  EditEventScreen({required this.event});

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _dateController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _feeController;
  late TextEditingController _feeLinkController;
  File? _thumbnailImage;
  late bool _isFreeEvent;
  late List<DateTime> _selectedDates;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _dateController = TextEditingController(text: widget.event.dates.map((date) => DateFormat('yyyy-MM-dd').format(date)).join(', '));
    _descriptionController = TextEditingController(text: widget.event.description);
    _locationController = TextEditingController(text: widget.event.location);
    _feeController = TextEditingController(text: widget.event.isFree ? '' : 'RM${widget.event.fee.toStringAsFixed(2)}');
    _feeLinkController = TextEditingController(text: widget.event.feeLink);
    _thumbnailImage = null; // Set to null initially; use event's thumbnail URL for display
    _isFreeEvent = widget.event.isFree;
    _selectedDates = widget.event.dates;
  }

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
        title: Text('Edit Event'),
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
                  : Image.network(
                      widget.event.thumbnailUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final updatedEvent = Event(
                      id: widget.event.id,
                      title: _titleController.text,
                      dates: _selectedDates,
                      location: _locationController.text,
                      isFree: _isFreeEvent,
                      fee: _isFreeEvent ? 0.0 : double.parse(_feeController.text.replaceFirst('RM', '')),
                      feeLink: _feeLinkController.text,
                      description: _descriptionController.text,
                      thumbnailUrl: _thumbnailImage?.path ?? widget.event.thumbnailUrl,
                      organizer: 'MobileCraft',
                    );
                    Navigator.pop(context, updatedEvent);
                  }
                },
                child: Text('Save Changes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Footer(currentIndex: 1),
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
