import 'dart:convert';
import 'package:http/http.dart' as http;

class GithubRepository {
  const GithubRepository({
    required this.name,
    required this.description,
    required this.htmlUrl,
    required this.language,
    required this.stars,
    required this.forks,
  });

  final String name;
  final String description;
  final String htmlUrl;
  final String? language;
  final int stars;
  final int forks;

  factory GithubRepository.fromJson(Map<String, dynamic> json) {
    return GithubRepository(
      name: json['name'] as String? ?? 'Repository',
      description: json['description'] as String? ?? 'No description provided.',
      htmlUrl: json['html_url'] as String? ?? '',
      language: json['language'] as String?,
      stars: json['stargazers_count'] as int? ?? 0,
      forks: json['forks_count'] as int? ?? 0,
    );
  }
}

class GithubService {
  GithubService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<GithubRepository>> fetchRepositories(String username) async {
    if (username.isEmpty || username == 'YOUR_GITHUB_USERNAME') {
      throw Exception('Add your GitHub username in portfolio_config.dart.');
    }

    final uri = Uri.https('api.github.com', '/users/$username/repos', {
      'sort': 'updated',
      'per_page': '6',
      'type': 'owner',
    });

    final response = await _client.get(uri, headers: {
      'Accept': 'application/vnd.github+json',
    }).timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      throw Exception('GitHub returned status ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Unexpected GitHub response.');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(GithubRepository.fromJson)
        .where((repo) => repo.htmlUrl.isNotEmpty)
        .toList();
  }

  void dispose() => _client.close();
}
