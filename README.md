# Spotify Insights

A macOS Flutter app that analyzes your Spotify playlists and displays various insights through interactive charts.

## Features

- **Playlist Overlap Analysis**: Discover which pairs of playlists share the most songs, shown as a percentage of the smaller playlist
- **Tracks Added Over Time**: Histogram showing when tracks were added to your playlists, grouped by month
- **Most Common Tracks**: See which songs appear on the most playlists
- **Longest Playlists**: Ranked list of playlists by track count

## Setup

### 1. Spotify Developer Setup

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create a new application
3. Add redirect URI: `http://localhost:8888/callback`
4. Note your Client ID

### 2. Environment Configuration

Create a `.env` file in the project root:

```
SPOTIFY_CLIENT_ID=your_client_id_here
```

### 3. Run the App

```bash
flutter pub get
dart run build_runner build
flutter run -d macos
```

## Architecture

The app follows Domain-Driven Design with clean separation of concerns:

### Layers

- **UI Layer**: Cupertino widgets, screens, and chart components
- **State Layer**: Riverpod providers for reactive state management
- **Domain Layer**: Repository pattern, analytics engine, auth service
- **Data Layer**: Spotify API client, SQLite database, secure token storage

### Key Design Principles

- **Deep APIs (Ousterhout)**: Complex operations hidden behind simple interfaces
  - `PlaylistRepository.syncAndGetAll()` handles API pagination, caching, and storage internally
  - `AnalyticsEngine.computeAll()` returns all computed statistics in one call

- **DRY Implementation**:
  - `RankedListCard<T>`: Generic widget for displaying ranked lists
  - `AsyncDataBuilder<T>`: Handles loading/error/data states consistently
  - `ChartConfig`: Shared chart styling configuration

- **Clean Code**:
  - Classes are nouns (Playlist, AnalyticsEngine, SyncService)
  - Methods are verbs (computeOverlap, sync, fetchAll)
  - Single responsibility per class

## Project Structure

```
lib/
├── main.dart
├── models/              # Freezed data classes
├── services/            # Domain services and data layer
├── providers/           # Riverpod state management
├── screens/             # UI screens
├── widgets/             # Reusable UI components
└── theme/               # App theming
```

## OAuth Flow

The app uses Spotify's Authorization Code with PKCE flow:

1. User clicks "Sign in with Spotify"
2. App starts a local HTTP server on a random port
3. App opens browser to Spotify authorization URL with `http://localhost:{port}/callback`
4. User approves access in browser
5. Spotify redirects to localhost, app's server receives the callback
6. App exchanges code for access/refresh tokens
7. Browser shows success message, tokens stored securely

## Data Storage

- **Playlists and tracks**: SQLite database for offline access
- **Auth tokens**: Flutter Secure Storage (Keychain on macOS)
- **Last sync time**: Tracked for cache freshness
