class NoteModel {
  final int? id;
  final String title;
  final String note;
  final String date;
  final String imagePath;
  final int color; 
  final String category; 
  final String? attachedIds;

  NoteModel({
    this.id,
    required this.title,
    required this.note,
    required this.date,
    required this.imagePath,
    required this.color,
    required this.category,
    this.attachedIds,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
        id: json['id'],
        title: json['title'] ?? '',
        note: json['note'] ?? '',
        date: json['date'] ?? '',
        imagePath: json['imagePath'] ?? '',
        color: json['color'] ?? 0,
        category: json['category'] ?? 'Semua',
        attachedIds: json['attachedIds'], 
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'note': note,
        'date': date,
        'imagePath': imagePath,
        'color': color,
        'category': category,
        'attachedIds': attachedIds, // Pastikan ini ditambahkan agar tersimpan ke DB
      };
}