# Narrative - Personalized News Feed
A modern mobile news aggregator built with Flutter, focused on delivering a personalized, category-based news feed. It employs the MVVM (Model-View-ViewModel) architecture, leverages Firebase Authentication for user management, and uses NewsAPI as the primary data source.

## Features

* **Personalized News Feed:** Dynamically filters and displays news articles based on categories selected by the user (e.g., Technology, Sports).
* **Firebase authentication:** Detailed forecast view to help users plan ahead.
* **MVVM Architecture:** Clean, scalable, and maintainable codebase structure using the MVVM pattern.
* **Persistent preference:** User-selected categories are stored locally using sqflite for fast access and retention.
* **State Management:** Utilizes **Provider** for robust and efficient state handling.
* **Daily sync:** The news feed refreshes daily or upon app open to ensure the latest articles are presented.

## Architecture Overview

The project is structured following the MVVM pattern for clear separation of concerns:

| Layer | Responsibility | Key Folders/Files |
| :--- | :--- | :--- |
| **Model** | Data structures and business entities. | `lib/models/` |
| **View** | UI components, screens, and user interaction. | `lib/views/` |
| **ViewModel** | Business logic, state management, and interaction with the Repository. | `lib/viewmodels/` |
| **Data** | API communication, authentication, and storage logic. | `lib/services/` |

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

* **Flutter SDK** (stable channel)
* **Dart SDK**
* **An IDE** (VS Code or Android Studio) with Flutter/Dart plugins

### Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/your-username/auracast.git](https://github.com/your-username/auracast.git)
    cd narrative
    ```

2.  **Install dependencies:**
    ```bash
    flutter clean
    flutter pub get
    ```

3.  **Set up API Keys:**
    ```dart
    const String NEWS_API_KEY = "YOUR_NEWS_API_KEY";
    ```
4.  **Run the App:**
    ```bash
    flutter run
    ```

## Key Dependencies

| Package | Purpose |
| :--- | :--- |
| `provider`| State Management (connecting View and ViewModel). |
| `http` | Handling network requests to both APIs. |
| `firebase_auth & firebase_core` | User authentication and Firebase initialization. |
| `flutter_local_notifications` | Scheduling and displaying daily, personalized messages. |
| `sqflite` | Local database. |
