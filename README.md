# Vibe
[![Ask DeepWiki](https://devin.ai/assets/askdeepwiki.png)](https://deepwiki.com/Kyaw-Min-Khant/vibe)

Vibe is a cross-platform real-time messaging application built with Flutter. It provides core chat functionalities including text, image, and audio messaging, user authentication, and friend management, all powered by a custom backend, Socket.IO, Firebase, and Appwrite.

## Features

-   **User Authentication**: Secure sign-up, login, and logout functionality.
-   **Real-time Chat**: Instant one-on-one messaging using WebSockets (Socket.IO).
-   **Multimedia Messaging**: Send and receive images and voice messages.
-   **Message Status**: Track message status with indicators for `sent`, `delivered`, and `seen`.
-   **Typing Indicator**: See when your friend is typing a message.
-   **Presence System**: View user online status and last seen time.
-   **Friend Management**:
    -   Discover and add new friends from a suggestions list.
    -   Manage incoming friend requests.
    -   View a list of all friends to start conversations.
-   **User Profiles**: View user profile information including avatar, username, and email.
-   **Push Notifications**: Integrated with Firebase Cloud Messaging to notify users of new messages.
-   **Persistent State**: User sessions are persisted locally for a seamless experience.

## Tech Stack

-   **Framework**: Flutter
-   **State Management**: Provider
-   **Backend Communication**:
    -   **Real-time Engine**: `socket_io_client` for WebSocket communication.
    -   **API Calls**: `http` for RESTful API interaction (authentication, user data).
-   **Backend Services**:
    -   **File Storage**: Appwrite Cloud Storage for handling image and audio file uploads.
    -   **Push Notifications**: Firebase Cloud Messaging (FCM).
-   **Local Storage**: `shared_preferences` for storing session tokens and user data.
-   **Key Libraries**:
    -   `image_picker` for camera and gallery access.
    -   `record` & `audioplayers` for voice message functionality.
    -   `permission_handler` for managing device permissions.
    -   `jiffy` for date and time formatting.
    -   `flutter_dotenv` for managing environment variables.

## Project Structure

The application's core logic is organized within the `lib` directory, following a feature-driven structure:

```
lib/
├── main.dart             # App entry point, initialization, and routing
├── components/           # Reusable widgets (e.g., custom audio player, message input)
├── models/               # Data models for API responses
├── providers/            # State management with Provider
├── routes/               # Custom navigation logic (e.g., BottomNavigationBar)
├── screens/              # UI for each feature (Login, Chat Room, Profile, etc.)
├── services/             # Business logic for interacting with external services
│   ├── api.dart          # Base API configuration
│   ├── appwrite_service.dart # Appwrite file upload service
│   ├── auth_service.dart   # Authentication services
│   ├── message_service.dart# Fetching historical messages
│   ├── socket_service.dart # WebSocket connection and event handling
│   └── user_service.dart   # User and friend management
└── utils/                # Utility functions
```

## Setup and Installation

### Prerequisites

-   Flutter SDK installed.
-   An editor like VS Code or Android Studio.
-   A configured Firebase project for push notifications.
-   A configured Appwrite project for file storage.
-   A running instance of the compatible backend server.

### Configuration

1.  **Clone the repository**:
    ```sh
    git clone https://github.com/Kyaw-Min-Khant/vibe.git
    cd vibe
    ```

2.  **Set up the backend URL**:
    The backend API endpoint is configured in `lib/services/api.dart`. Modify the `baseUrl` to point to your server instance.

    ```dart
    // lib/services/api.dart
    static const String baseUrl = "http://<YOUR_SERVER_IP>:<PORT>";
    ```

3.  **Create an environment file**:
    Create a `.env` file in the root of the project and add your Firebase and Appwrite project credentials. The required keys are used in `lib/firebase_options.dart` and `lib/services/appwrite_service.dart`.

    ```env
    # Appwrite
    APP_WRITE_ENDPOINT=https://cloud.appwrite.io/v1
    APP_WRITE_PROJECT_ID=<YOUR_APPWRITE_PROJECT_ID>
    APP_WRITE_BUCKET_ID=<YOUR_APPWRITE_BUCKET_ID>

    # Firebase - Android
    API_KEY_ANDROID=<YOUR_API_KEY>
    APP_ID_ANDROID=<YOUR_APP_ID>
    MESSAGING_SENDER_ID_ANDROID=<YOUR_MESSAGING_SENDER_ID>
    PROJECT_ID_ANDROID=<YOUR_PROJECT_ID>
    STORAGE_BUCKET_ANDROID=<YOUR_STORAGE_BUCKET>

    # Firebase - iOS
    API_KEY_IOS=<YOUR_API_KEY>
    APP_ID_IOS=<YOUR_APP_ID>
    MESSAGING_SENDER_ID_IOS=<YOUR_MESSAGING_SENDER_ID>
    PROJECT_ID_IOS=<YOUR_PROJECT_ID>
    STORAGE_BUCKET_IOS=<YOUR_STORAGE_BUCKET>
    IOS_BUNDLE_ID=<YOUR_IOS_BUNDLE_ID>

    # Add other platform keys (Web, macOS, Windows) as needed
    ```

4.  **Install dependencies**:
    ```sh
    flutter pub get
    ```

5.  **Run the application**:
    ```sh
    flutter run
