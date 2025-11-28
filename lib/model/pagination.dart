// TODO Implement this library.
class Pagination<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  Pagination({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory Pagination.fromMap(
    Map<String, dynamic> map,
    T Function(dynamic json) mapper,
  ) {
    return Pagination(
      count: map['count'] is int
          ? map['count'] as int
          : int.tryParse('${map['count']}') ?? 0,
      next: map['next']?.toString(),
      previous: map['previous']?.toString(),
      results: (map['results'] as List<dynamic>? ?? [])
          .map((item) => mapper(item))
          .toList(),
    );
  }
}
