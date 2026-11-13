# JP Portfolio — Flutter Web

A responsive, single-page professional portfolio for a Flutter / Android developer.

## Features
- Premium black, white and gold visual system
- Responsive navigation and layouts
- Scroll-to-section navigation
- Entrance and hover animations
- GitHub public repository integration
- Project showcase with demo/source links
- Resume download
- Contact form integration through Formspree
- SEO metadata and deployment notes

## 1. Configure your details

Edit `lib/config/portfolio_config.dart`:
- `name`, `email`, `githubUsername`, `linkedinUrl`
- `resumeAssetPath`
- `formspreeEndpoint`
- project details and social links

Put your real PDF resume at `assets/resume.pdf`. If you do not have it ready yet, remove the resume asset from `pubspec.yaml` until you add it.

For the contact form, create a form at https://formspree.io/ and paste its endpoint into `formspreeEndpoint`. Do not put private API keys in Flutter Web source code. Formspree's public form endpoint is designed for browser submissions.

## 2. Run locally

```bash
flutter create . --platforms web
flutter pub get
flutter run -d chrome
```

## 3. Build for production

```bash
flutter analyze
flutter test
flutter build web --release --base-href /
```

Deploy the contents of `build/web` to GitHub Pages, Firebase Hosting, Netlify, or another static host.

## 4. GitHub Pages

For a repository named `username.github.io`, use:

```bash
flutter build web --release --base-href /
```

For a project repository such as `portfolio`, use:

```bash
flutter build web --release --base-href /portfolio/
```

Enable GitHub Pages in repository Settings → Pages and publish the `build/web` output using your preferred GitHub Actions workflow.

## 5. Important production checklist
- Replace all sample project links with real repositories and live demos.
- Add your actual resume PDF at `assets/resume.pdf`.
- Set your Formspree endpoint and test form submissions.
- Update page title, description and social links in `web/index.html`.
- Use HTTPS on the deployed site.
- Verify mobile layout and keyboard accessibility before publishing.

The GitHub section uses GitHub's public REST API without a token, so public unauthenticated rate limits apply. The app handles loading, empty and error states.
