# MBChallenge - News Articles App

A Swift iOS application that displays news articles from The Guardian API using MVVM architecture and Combine for reactive programming.

## Features

### 📱 Articles List Screen
- Fetches and displays a list of news articles from The Guardian API
- Shows article title, section, and publication date
- Loading indicator while fetching data
- Pull-to-refresh functionality
- Error handling with user-friendly messages
- Clean, modern UI with proper spacing and typography

### 📄 Article Detail Screen
- Displays full article details when an article is selected
- Shows article headline, body text, and publication date
- Loads and displays article images (if available)
- Responsive layout with scrollable content
- Loading indicator for images

## Technical Implementation

### 🏗️ Architecture
- **MVVM (Model-View-ViewModel)**: Clean separation of concerns
- **Combine Framework**: Reactive data binding between View and ViewModel
- **Protocol-Oriented Programming**: Testable and maintainable code

### 📦 Key Components

#### Models
- `Article`: Data model for news articles
- `ArticleFields`: Extended article information
- `GuardianResponse`: API response structure

#### ViewModels
- `ArticlesListViewModel`: Manages articles list business logic
- `ArticleDetailViewModel`: Handles article detail presentation

#### Views
- `ArticlesListViewController`: Main list screen with table view
- `ArticleDetailViewController`: Article detail screen
- `ArticleTableViewCell`: Custom table view cell

#### Services
- `NetworkService`: Handles API communication with error handling

### 🧪 Testing
- Unit tests for ViewModels using XCTest
- Mock network service for testing
- Comprehensive test coverage for business logic

## Setup Instructions

### 1. Prerequisites
- Xcode 12.0 or later
- iOS 14.0 or later
- Swift 5.0 or later

### 2. API Key Setup
The app uses The Guardian Open Platform API. To get your API key:

1. Visit [The Guardian Open Platform](https://open-platform.theguardian.com/)
2. Sign up for a free account
3. Request an API key
4. Add the API key to `Info.plist`:

```xml
<key>GuardianAPIKey</key>
<string>YOUR_API_KEY_HERE</string>
```

**Note**: The API key is now configured in `Info.plist` for better security and configuration management. See `Configuration.md` for detailed setup instructions.

### 3. Building and Running
1. Open `MBChallenge.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run the project (⌘+R)

## Project Structure

```
MBChallenge/
├── Models/
│   └── Article.swift
├── ViewModels/
│   ├── ArticlesListViewModel.swift
│   └── ArticleDetailViewModel.swift
├── Views/
│   ├── ArticlesListViewController.swift
│   ├── ArticleDetailViewController.swift
│   ├── ArticleTableViewCell.swift
│   └── LoadingTableViewCell.swift
├── Services/
│   └── NetworkService.swift
├── Utils/
│   ├── DateFormatter+Extensions.swift
│   └── Bundle+Extensions.swift
└── Supporting Files/
    ├── AppDelegate.swift
    ├── SceneDelegate.swift
    └── Info.plist

MBChallengeTests/
├── ArticlesListViewModelTests.swift
└── ArticleDetailViewModelTests.swift
```

## API Endpoints

The app uses The Guardian Content API:
- **Base URL**: `https://content.guardianapis.com`
- **Endpoint**: `/search`
- **Parameters**:
  - `api-key`: Your API key
  - `show-fields`: headline,trailText,bodyText,thumbnail,main,body
  - `page-size`: 20
  - `order-by`: newest

## Error Handling

The app handles various error scenarios:
- Network connectivity issues
- API errors
- Data parsing errors
- Missing content

Users are presented with clear error messages and can retry by pulling to refresh.

## Testing

Run the unit tests:
1. In Xcode, go to Product → Test (⌘+U)
2. Or run specific test classes in the test navigator

The tests cover:
- ViewModel initialization and state management
- Data binding and Combine publishers
- Error handling scenarios
- Date formatting
- Article content processing

## Future Enhancements

Potential improvements for the app:
- Offline caching with Core Data
- Search functionality
- Article bookmarking
- Dark mode support
- Accessibility improvements
- Pagination for large article lists
- Image caching and optimization

## License

This project is created for the MBChallenge coding assessment. 