class Event {
  final String id;
  final String title;
  final List<DateTime> dates;
  final String location;
  final bool isFree;
  final double fee;
  final String feeLink;
  final String description;
  final String thumbnailUrl;
  final String organizer;

  Event({
    required this.id,
    required this.title,
    required this.dates,
    required this.location,
    required this.isFree,
    required this.fee,
    required this.feeLink,
    required this.description,
    required this.thumbnailUrl,
    required this.organizer,
  });
}
