# Dev.to News App

A Flutter news reader app that fetches articles from Dev.to API with bookmarking capability.

## Features

- Browse latest articles from Dev.to
- Read full article content with proper HTML rendering
- Bookmark articles for later reading (persisted locally)
- Pull to refresh
- Clean, modern UI design

## Tech Stack

- **Flutter** - UI framework
- **Riverpod** - State management
- **Dio** - HTTP client
- **SharedPreferences** - Local storage
- **flutter_html** - HTML content rendering
- **GoRouter** - Navigation

## Project Structure
```
lib/
├── main.dart
├── core/constants/          # API endpoints & configs
├── data/
│   ├── models/              # Article data model
│   └── services/            # API & storage services
├── presentation/
│   ├── home/                # Article list screen
│   ├── detail/              # Article detail screen
│   ├── bookmarks/           # Saved articles screen
│   └── widgets/             # Reusable components
└── providers/               # Riverpod state management
```

## Key Concepts

### State Management
Uses Riverpod with StateNotifier for real-time bookmark synchronization across all screens.

### Data Flow
1. Fetch articles list from API
2. Display in home screen with cached images
3. Tap article → fetch full content with HTML body
4. Bookmark button → save to local storage + update UI instantly

### HTML Rendering
Custom image extension to handle responsive images in article content:
- Maintains aspect ratio
- Prevents overflow
- Uses cached network images

## Getting Started

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

## API

Uses [Dev.to API](https://developers.forem.com/api) (no auth required):
- `GET /articles` - List articles
- `GET /articles/{id}` - Get article detail

## Todo

- [ ] Pagination / infinite scroll
- [ ] Search articles
- [ ] Filter by tags
- [ ] Dark mode
- [ ] Offline reading

## Screenshots

(Add screenshots here)

---

Built with Flutter 3.x