import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/portfolio_config.dart';
import '../services/github_service.dart';
import '../services/contact_service.dart';
import '../widgets/section_title.dart';
import '../widgets/skill_chip.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final _scroll = ScrollController();
  final _homeKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _skillsKey = GlobalKey();
  final _projectsKey = GlobalKey();
  final _githubKey = GlobalKey();
  final _contactKey = GlobalKey();

  final _github = GithubService();
  final _contact = ContactService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<List<GithubRepository>>? _repositories;
  bool _sending = false;
  String? _formMessage;
  bool _formSuccess = false;

  @override
  void initState() {
    super.initState();
    _repositories = _github.fetchRepositories(PortfolioConfig.githubUsername);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _github.dispose();
    _contact.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _goTo(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeInOutCubic,
      alignment: 0.04,
    );
  }

  Future<void> _open(String value) async {
    if (value.isEmpty) return;
    final uri = Uri.tryParse(value);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _downloadResume() async {
    await _open(PortfolioConfig.resumeAssetPath);
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _sending = true;
      _formMessage = null;
    });
    try {
      await _contact.send(
        endpoint: PortfolioConfig.formspreeEndpoint,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        message: _messageController.text.trim(),
      );
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
      setState(() {
        _formSuccess = true;
        _formMessage = 'Thanks! Your message has been sent.';
      });
    } catch (e) {
      setState(() {
        _formSuccess = false;
        _formMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          return Stack(
            children: [
              SingleChildScrollView(
                controller: _scroll,
                child: Column(
                  children: [
                    _navigation(compact),
                    _hero(compact, _homeKey),
                    _about(_aboutKey),
                    _skills(_skillsKey),
                    _projects(_projectsKey),
                    _githubSection(_githubKey),
                    _contactSection(_contactKey, compact),
                    _footer(),
                  ],
                ),
              ),
              Positioned(
                right: 22,
                bottom: 22,
                child: FloatingActionButton.small(
                  heroTag: 'backToTop',
                  backgroundColor: const Color(0xFFD6B56D),
                  foregroundColor: Colors.black,
                  onPressed: () => _goTo(_homeKey),
                  child: const Icon(Icons.arrow_upward_rounded),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _navigation(bool compact) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 7.5 * 16, vertical: 18),
      decoration: const BoxDecoration(
        color: Color(0xF5090909),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Text.rich(TextSpan(
            text: PortfolioConfig.initials,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: Colors.white),
            children: const [TextSpan(text: '.', style: TextStyle(color: Color(0xFFD6B56D)))],
          )),
          const Spacer(),
          if (compact)
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              color: const Color(0xFF1A1A1A),
              onSelected: _navAction,
              itemBuilder: (_) => ['Home', 'About', 'Skills', 'Projects', 'GitHub', 'Contact']
                  .map((e) => PopupMenuItem(value: e, child: Text(e)))
                  .toList(),
            )
          else ...[
            _navButton('Home', _homeKey),
            _navButton('About', _aboutKey),
            _navButton('Skills', _skillsKey),
            _navButton('Projects', _projectsKey),
            _navButton('GitHub', _githubKey),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: () => _goTo(_contactKey),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD6B56D),
                side: const BorderSide(color: Color(0xFFD6B56D)),
              ),
              child: const Text('Let’s talk'),
            ),
          ],
        ],
      ),
    );
  }

  void _navAction(String value) {
    final key = switch (value) {
      'Home' => _homeKey,
      'About' => _aboutKey,
      'Skills' => _skillsKey,
      'Projects' => _projectsKey,
      'GitHub' => _githubKey,
      _ => _contactKey,
    };
    _goTo(key);
  }

  Widget _navButton(String label, GlobalKey key) => TextButton(
        onPressed: () => _goTo(key),
        child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      );

  Widget _hero(bool compact, GlobalKey key) {
    return Container(
      key: key,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: compact ? 24 : 120, vertical: compact ? 76 : 112),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: compact
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: _heroContent())
              : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Expanded(flex: 6, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _heroContent())),
                  const SizedBox(width: 70),
                  Expanded(flex: 4, child: _heroVisual()),
                ]),
        ),
      ),
    );
  }

  List<Widget> _heroContent() => [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFD6B56D).withValues(alpha: .10),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFD6B56D).withValues(alpha: .35)),
          ),
          child: const Text('●  OPEN TO OPPORTUNITIES', style: TextStyle(color: Color(0xFFD6B56D), fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 28),
        Text('Hello, I’m ${PortfolioConfig.name}.', style: const TextStyle(color: Colors.white70, fontSize: 18)),
        const SizedBox(height: 12),
        const Text(
          'Building digital\nexperiences that\nmove people.',
          style: TextStyle(fontSize:  clampFont, height: 1.05, fontWeight: FontWeight.w900, letterSpacing: -1.5),
        ),
        const SizedBox(height: 20),
        const Text(
          'Mobile Application Developer specializing in Flutter, Dart and Android. I turn complex ideas into elegant, reliable mobile products.',
          style: TextStyle(color: Colors.white60, fontSize: 15, height: 1.8),
        ),
        const SizedBox(height: 28),
        Wrap(spacing: 12, runSpacing: 12, children: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD6B56D), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17)),
            onPressed: () => _goTo(_projectsKey),
            child: const Text('Explore projects  ↗'),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white30), padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17)),
            onPressed: _downloadResume,
            child: const Text('Download resume ↓'),
          ),
        ]),
        const SizedBox(height: 38),
        const Wrap(spacing: 26, runSpacing: 16, children: [
          _Stat(value: '3+', label: 'Years experience'),
          _Stat(value: 'Flutter', label: 'Cross-platform'),
          _Stat(value: 'Android', label: 'Native development'),
        ]),
      ];

  static const double clampFont = 54;

  Widget _heroVisual() {
    return Container(
      height: 390,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const RadialGradient(colors: [Color(0xFF302719), Color(0xFF17130D), Color(0xFF111111)]),
        border: Border.all(color: const Color(0xFFD6B56D).withValues(alpha: .25)),
      ),
      child: Stack(alignment: Alignment.center, children: [
        Container(
          width: 230, height: 230,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD6B56D).withValues(alpha: .45), width: 1.4),
          ),
        ),
        Container(
          width: 180, height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD6B56D).withValues(alpha: .08),
            border: Border.all(color: const Color(0xFFD6B56D).withValues(alpha: .22)),
          ),
          child: const Center(child: Icon(Icons.code_rounded, size: 82, color: Color(0xFFD6B56D))),
        ),
        const Positioned(left: 32, top: 45, child: _FloatingTag(icon: Icons.phone_android, text: 'Flutter')),
        const Positioned(right: 25, top: 110, child: _FloatingTag(icon: Icons.android, text: 'Android')),
        const Positioned(left: 45, bottom: 55, child: _FloatingTag(icon: Icons.cloud_outlined, text: 'Firebase')),
      ]),
    ).animate().fadeIn(duration: 900.ms).scale(begin: const Offset(.92, .92), end: const Offset(1, 1));
  }

  Widget _section(GlobalKey key, Widget child, {Color? color}) {
    return Container(
      key: key,
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 88),
      child: Center(
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1120), child: child),
      ),
    );
  }

  Widget _about(GlobalKey key) => _section(key, Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(eyebrow: 'A little about me', title: 'Engineering with purpose.',
            subtitle: 'I combine practical engineering with a product mindset to build mobile experiences that are useful, intuitive and dependable.'),
          const SizedBox(height: 34),
          LayoutBuilder(builder: (context, c) {
            final narrow = c.maxWidth < 700;
            final text = const Text(
              'With 3+ years of hands-on experience across Flutter and native Android development, I work across the mobile development lifecycle — from understanding requirements and planning architecture to API integration, debugging, optimization and store release.\n\n'
              'I value clean code, reusable components, thoughtful state management and clear communication. I enjoy learning new tools and taking on challenging problems that make applications better.',
              style: TextStyle(color: Colors.white60, height: 1.9, fontSize: 14),
            );
            final cards = const Column(children: [
              _InfoCard(icon: Icons.phone_iphone, title: 'Cross-platform', body: 'Android & iOS applications with Flutter.'),
              SizedBox(height: 14),
              _InfoCard(icon: Icons.architecture, title: 'Scalable code', body: 'MVVM, MVC and clean architecture practices.'),
              SizedBox(height: 14),
              _InfoCard(icon: Icons.rocket_launch, title: 'End-to-end delivery', body: 'Development, testing, optimization and publishing.'),
            ]);
            return narrow ? Column(children: [text, const SizedBox(height: 28), cards]) :
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: text), const SizedBox(width: 70), Expanded(child: cards)]);
          }),
        ],
      ));

  Widget _skills(GlobalKey key) => _section(key, Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(eyebrow: 'Technical toolkit', title: 'Skills & technologies',
            subtitle: 'A practical toolkit for building, integrating and shipping modern mobile applications.'),
          const SizedBox(height: 34),
          LayoutBuilder(builder: (context, c) {
            final columns = c.maxWidth > 850 ? 3 : c.maxWidth > 560 ? 2 : 1;
            return Wrap(
              spacing: 16, runSpacing: 16,
              children: PortfolioConfig.skills.entries.map((entry) => SizedBox(
                width: (c.maxWidth - (columns - 1) * 16) / columns,
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: _panelDecoration(),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(entry.key, style: const TextStyle(color: Color(0xFFD6B56D), fontWeight: FontWeight.w800)),
                    const SizedBox(height: 18),
                    Wrap(spacing: 8, runSpacing: 9, children: entry.value.map((s) => SkillChip(label: s)).toList()),
                  ]),
                ),
              )).toList(),
            );
          }),
        ],
      ), color: const Color(0xFF0E0E0E));

  Widget _projects(GlobalKey key) => _section(key, Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(eyebrow: 'Selected work', title: 'Projects built for the real world.',
            subtitle: 'A selection of application domains and product experiences. Replace the sample links with your published apps, demos and source repositories.'),
          const SizedBox(height: 34),
          LayoutBuilder(builder: (context, c) {
            final columns = c.maxWidth > 800 ? 2 : 1;
            return Wrap(spacing: 18, runSpacing: 18, children: PortfolioConfig.projects.map((p) => SizedBox(
              width: (c.maxWidth - (columns - 1) * 18) / columns,
              child: _ProjectCard(project: p, onOpen: _open),
            )).toList());
          }),
        ],
      ));

  Widget _githubSection(GlobalKey key) => _section(key, Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(eyebrow: 'Open source', title: 'Latest on GitHub',
            subtitle: 'Recent public repositories are loaded live from the GitHub API.'),
          const SizedBox(height: 28),
          FutureBuilder<List<GithubRepository>>(
            future: _repositories,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator(color: Color(0xFFD6B56D))));
              }
              if (snapshot.hasError) {
                return _GithubNotice(
                  message: snapshot.error.toString().replaceFirst('Exception: ', ''),
                  action: 'Open GitHub profile',
                  onPressed: () => _open(PortfolioConfig.githubUrl),
                );
              }
              final repos = snapshot.data ?? [];
              if (repos.isEmpty) return const _GithubNotice(message: 'No public repositories found yet.', action: 'Visit GitHub', onPressed: null);
              return LayoutBuilder(builder: (context, c) {
                final columns = c.maxWidth > 800 ? 3 : c.maxWidth > 560 ? 2 : 1;
                return Wrap(spacing: 14, runSpacing: 14, children: repos.map((r) => SizedBox(
                  width: (c.maxWidth - (columns - 1) * 14) / columns,
                  child: _RepoCard(repo: r, onTap: () => _open(r.htmlUrl)),
                )).toList());
              });
            },
          ),
          const SizedBox(height: 20),
          TextButton.icon(onPressed: () => _open(PortfolioConfig.githubUrl), icon: const Icon(Icons.open_in_new), label: const Text('View GitHub profile')),
        ],
      ), color: const Color(0xFF0E0E0E));

  Widget _contactSection(GlobalKey key, bool compact) => _section(key, Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(eyebrow: 'Get in touch', title: 'Let’s build something meaningful.',
            subtitle: 'Have a project, opportunity or idea? Send a message and I’ll get back to you.'),
          const SizedBox(height: 34),
          LayoutBuilder(builder: (context, c) {
            final narrow = c.maxWidth < 760;
            final details = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Contact details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 22),
              _ContactLine(icon: Icons.email_outlined, label: 'Email', value: PortfolioConfig.email, onTap: () => _open('mailto:${PortfolioConfig.email}')),
              const SizedBox(height: 18),
              _ContactLine(icon: Icons.location_on_outlined, label: 'Location', value: PortfolioConfig.location),
              const SizedBox(height: 18),
              _ContactLine(icon: Icons.link, label: 'LinkedIn', value: 'Connect professionally', onTap: () => _open(PortfolioConfig.linkedinUrl)),
              const SizedBox(height: 18),
              _ContactLine(icon: Icons.code, label: 'GitHub', value: 'Explore my code', onTap: () => _open(PortfolioConfig.githubUrl)),
            ]);
            final form = _contactForm();
            return narrow ? Column(children: [details, const SizedBox(height: 32), form]) :
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: details), const SizedBox(width: 70), Expanded(child: form)]);
          }),
        ],
      ));

  Widget _contactForm() => Container(
        padding: const EdgeInsets.all(24),
        decoration: _panelDecoration(),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Send a message', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Your name'), validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your name.' : null),
            const SizedBox(height: 14),
            TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email address'), validator: (v) {
              if (v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) return 'Enter a valid email address.';
              return null;
            }),
            const SizedBox(height: 14),
            TextFormField(controller: _messageController, minLines: 4, maxLines: 6, decoration: const InputDecoration(labelText: 'Tell me about your project'), validator: (v) => v == null || v.trim().length < 10 ? 'Please enter at least 10 characters.' : null),
            if (_formMessage != null) ...[
              const SizedBox(height: 14),
              Text(_formMessage!, style: TextStyle(color: _formSuccess ? Colors.greenAccent : Colors.orangeAccent, height: 1.4)),
            ],
            const SizedBox(height: 18),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: _sending ? null : _sendMessage,
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD6B56D), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 17)),
              child: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Text('Send message  ↗'),
            )),
          ]),
        ),
      );

  Widget _footer() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white10))),
        child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Wrap(alignment: WrapAlignment.spaceBetween, runSpacing: 12, children: [
            const Text('© 2026 Jayaprakash. Built with Flutter.', style: TextStyle(color: Colors.white38, fontSize: 12)),
            Row(mainAxisSize: MainAxisSize.min, children: [
              TextButton(onPressed: () => _open(PortfolioConfig.githubUrl), child: const Text('GitHub')),
              TextButton(onPressed: () => _open(PortfolioConfig.linkedinUrl), child: const Text('LinkedIn')),
              TextButton(onPressed: () => _open('mailto:${PortfolioConfig.email}'), child: const Text('Email')),
            ]),
          ]),
        )),
      );

  BoxDecoration _panelDecoration() => BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value, label;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(value, style: const TextStyle(color: Color(0xFFD6B56D), fontWeight: FontWeight.w900, fontSize: 22)),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
  ]);
}

class _FloatingTag extends StatelessWidget {
  const _FloatingTag({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
    decoration: BoxDecoration(color: const Color(0xFF242018), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFD6B56D).withValues(alpha: .3))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 15, color: const Color(0xFFD6B56D)), const SizedBox(width: 8), Text(text, style: const TextStyle(color: Colors.white70, fontSize: 11))]),
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title, body;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(color: const Color(0xFF151515), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white10)),
    child: Row(children: [
      Icon(icon, color: const Color(0xFFD6B56D), size: 22),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(body, style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
      ])),
    ]),
  );
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, required this.onOpen});
  final Project project;
  final ValueChanged<String> onOpen;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: const Color(0xFF151515), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 54, height: 54, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFD6B56D).withValues(alpha: .10), borderRadius: BorderRadius.circular(15)), child: Text(project.icon, style: const TextStyle(fontSize: 25))),
        const Spacer(),
        Text(project.category.toUpperCase(), style: const TextStyle(color: Color(0xFFD6B56D), fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w800)),
      ]),
      const SizedBox(height: 22),
      Text(project.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
      const SizedBox(height: 9),
      Text(project.description, style: const TextStyle(color: Colors.white54, height: 1.7, fontSize: 13)),
      const SizedBox(height: 18),
      Wrap(spacing: 7, runSpacing: 7, children: project.stack.map((s) => SkillChip(label: s)).toList()),
      const SizedBox(height: 18),
      Wrap(spacing: 16, children: [
        if (project.demoUrl.isNotEmpty) TextButton.icon(onPressed: () => onOpen(project.demoUrl), icon: const Icon(Icons.open_in_new, size: 15), label: const Text('Live demo')),
        if (project.sourceUrl.isNotEmpty) TextButton.icon(onPressed: () => onOpen(project.sourceUrl), icon: const Icon(Icons.code, size: 15), label: const Text('Source')),
      ]),
    ]),
  ).animate().fadeIn(duration: 450.ms).slideY(begin: .08, end: 0);
}

class _RepoCard extends StatelessWidget {
  const _RepoCard({required this.repo, required this.onTap});
  final GithubRepository repo;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(15),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xFF151515), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.folder_open, color: Color(0xFFD6B56D)), const Spacer(), const Icon(Icons.north_east, size: 16, color: Colors.white38)]),
        const SizedBox(height: 16),
        Text(repo.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(repo.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.6)),
        const SizedBox(height: 16),
        Wrap(spacing: 14, children: [
          if (repo.language != null) Text(repo.language!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          Text('★ ${repo.stars}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
          Text('⑂ ${repo.forks}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ]),
      ]),
    ),
  );
}

class _GithubNotice extends StatelessWidget {
  const _GithubNotice({required this.message, required this.action, this.onPressed});
  final String message, action;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: const Color(0xFF151515), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(message, style: const TextStyle(color: Colors.white60)),
      const SizedBox(height: 12),
      TextButton(onPressed: onPressed, child: Text(action)),
    ]),
  );
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.label, required this.value, this.onTap});
  final IconData icon;
  final String label, value;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Row(children: [
      Icon(icon, color: const Color(0xFFD6B56D), size: 20),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ])),
    ]),
  );
}
