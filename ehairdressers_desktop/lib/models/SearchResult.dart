class SearchResult<T> {
  int count = 0;
  List<T> result = [];

  SearchResult({this.count = 0, this.result = const []});

  factory SearchResult.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return SearchResult<T>(
      count: json['Count'] ?? json['TotalCount'] ?? (json['Result'] as List?)?.length ?? 0,
      result: (json['Result'] as List<dynamic>?)
          ?.map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson(Object Function(T) toJsonT) {
    return {
      'Count': count,
      'Result': result.map((item) => toJsonT(item)).toList(),
    };
  }
}