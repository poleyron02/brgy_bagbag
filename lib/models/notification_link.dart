import 'dart:convert';

class NotificationLink {
  String name;
  String url;
  NotificationLink({
    required this.name,
    required this.url,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({
      'name': name
    });
    result.addAll({
      'url': url
    });

    return result;
  }

  factory NotificationLink.fromMap(Map<String, dynamic> map) {
    return NotificationLink(
      name: map['name'] ?? '',
      url: map['url'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationLink.fromJson(String source) => NotificationLink.fromMap(json.decode(source));
}
