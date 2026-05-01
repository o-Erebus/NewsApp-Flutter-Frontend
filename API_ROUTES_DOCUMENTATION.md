# API Routes Documentation

**Base URL (Production):** `https://fyp-backend-dev-yoww.onrender.com`  
**Base URL (Development):** `http://10.0.0.4:8000`

---

## Table of Contents

1. [News/Articles API](#newsarticles-api)
2. [Podcasts API](#podcasts-api)
3. [AI Analysis API](#ai-analysis-api)
4. [User History API](#user-history-api)
5. [Authentication](#authentication)

---

## News/Articles API

### 1. Get All Articles (Paginated)

- **Endpoint:** `/articles/`
- **Method:** `GET`
- **Query Parameters:**
  - `page` (required): Page number for pagination
  - `limit` (required): Number of articles per page
  - `isMoodBoosterActivated` (optional): Boolean flag for mood booster feature
  - `tags` (optional): Category/tags filter
- **Authentication:** Bearer token (optional) or API key
- **Response:**
  - `data`: Array of article objects
  - `pagination`: Object containing `page` and `pages`
- **Used in:** `NewsProvider._fetchCategoryPage()`

**Example Request:**

```
GET /articles/?page=1&limit=10&isMoodBoosterActivated=false&tags=world
```

---

### 2. Get Featured Articles

- **Endpoint:** `/articles/featured`
- **Method:** `GET`
- **Query Parameters:**
  - `page` (optional): Page number
  - `limit` (optional): Number of articles
- **Authentication:** Bearer token (optional) or API key
- **Response:**
  - `data`: Array of featured article objects
  - `pagination`: Pagination information
- **Used in:** `NewsProvider.fetchFeaturedArticles()`
- **Default Size:** 5 articles (configurable via `Constants.featuredArticlesSize`)

**Example Request:**

```
GET /articles/featured
```

---

### 3. Get Global Articles

- **Endpoint:** `/articles/` (with global filter)
- **Method:** `GET`
- **Query Parameters:**
  - `page` (required): Page number
  - `limit` (required): Number of articles
- **Authentication:** Bearer token (optional) or API key
- **Response:**
  - `data`: Array of global article objects
  - `pagination`: Pagination info
- **Used in:** `NewsProvider._fetchGlobalPage()`

**Example Request:**

```
GET /articles/?page=1&limit=10
```

---

## Podcasts API

### Base Endpoint: `/api/podcasts`

### 1. Get Trending Podcasts

- **Endpoint:** `/api/podcasts/trending`
- **Method:** `GET`
- **Query Parameters:**
  - `limit` (optional): Default = 10
  - `offset` (optional): Default = 0
- **Authentication:** Bearer token (optional) or API key
- **Response:**
  ```json
  {
    "success": true,
    "podcasts": [...] // or "data": {"podcasts": [...]}
  }
  ```
- **Used in:** `PodcastApiService.getTrendingPodcasts()`

**Example Request:**

```
GET /api/podcasts/trending?limit=10&offset=0
```

---

### 2. Get Single Podcast

- **Endpoint:** `/api/podcasts/{podcastId}`
- **Method:** `GET`
- **Authentication:** Bearer token (optional) or API key
- **Response:**
  ```json
  {
    "success": true,
    "data": { ...podcast object... }
  }
  ```
- **Used in:** `PodcastApiService.getPodcast()`

**Example Request:**

```
GET /api/podcasts/507f1f77bcf86cd799439011
```

---

### 3. Get User's Podcasts

- **Endpoint:** `/api/podcasts/users/my-podcasts`
- **Method:** `GET`
- **Query Parameters:**
  - `limit` (optional): Default = 20
  - `offset` (optional): Default = 0
- **Authentication:** Required (Firebase Bearer token)
- **Response:**
  ```json
  {
    "success": true,
    "podcasts": [
      {
        "id": "string",
        "title": "string",
        "description": "string",
        "channel_name": "string",
        "image_url": "string",
        "audio_url": "string",
        "duration": "integer (seconds)",
        "listener_count": "integer",
        "created_time": "ISO datetime",
        "rating": "float (0-5)",
        "is_public": "boolean",
        "status": "string (completed|generating|failed)"
      }
    ]
  }
  ```
- **Status Field Values:**
  - `"completed"` - Podcast generation complete, ready to play
  - `"generating"` - Podcast is being generated, show loading spinner icon
  - `"failed"` - Podcast generation failed, show error icon
- **UI Behavior:**
  - `status: "generating"` → Show CircularProgressIndicator instead of play button
  - `status: "failed"` → Show error icon instead of play button
  - `status: "completed"` → Show play button (normal behavior)
- **Used in:** `PodcastApiService.getMyPodcasts()`, `PodcastProvider.fetchUserPodcasts()`

**Example Request:**

```
GET /api/podcasts/users/my-podcasts?limit=20&offset=0
Headers: Authorization: Bearer {firebaseToken}
```

**Example Response:**

```json
{
  "success": true,
  "podcasts": [
    {
      "id": "507f1f77bcf86cd799439011",
      "title": "AI Breakthroughs",
      "description": "Latest developments in AI",
      "channel_name": "Tech Daily",
      "image_url": "https://example.com/image.jpg",
      "audio_url": "https://example.com/audio.mp3",
      "duration": 3600,
      "listener_count": 150,
      "created_time": "2025-10-27T10:30:00Z",
      "rating": 4.5,
      "is_public": true,
      "status": "completed"
    },
    {
      "id": "507f1f77bcf86cd799439012",
      "title": "New Topic Podcast",
      "description": "Generating...",
      "channel_name": "User",
      "image_url": "https://example.com/placeholder.jpg",
      "audio_url": "",
      "duration": 0,
      "listener_count": 0,
      "created_time": "2025-10-27T11:00:00Z",
      "rating": 0,
      "is_public": true,
      "status": "generating"
    }
  ]
}
```

---

### 4. Search Podcasts

- **Endpoint:** `/api/podcasts/search`
- **Method:** `GET`
- **Query Parameters:**
  - `q` (required): Search query
  - `limit` (optional): Default = 20
  - `offset` (optional): Default = 0
- **Authentication:** Bearer token (optional) or API key
- **Response:**
  ```json
  {
    "success": true,
    "podcasts": [...]  // or "data": {"podcasts": [...]}
  }
  ```
- **Used in:** `PodcastApiService.searchPodcasts()`

**Example Request:**

```
GET /api/podcasts/search?q=technology&limit=20&offset=0
```

---

### 5. Create Podcast

- **Endpoint:** `/api/podcasts`
- **Method:** `POST`
- **Authentication:** Required (Firebase Bearer token)
- **Request Body:**
  ```json
  {
    "topic": "string (description/topic of the podcast to generate)",
    "is_public": "boolean"
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "podcast_id": "string" // or nested in "data"
  }
  ```
- **Used in:** `PodcastApiService.createPodcast()`, `PodcastProvider.createPodcast()`
- **Status Codes:** Accepts 200 or 201
- **Notes:** Backend generates audio based on the topic provided. No need to provide audio_url, image_url, title, or description - they are generated automatically.

**Example Request:**

```
POST /api/podcasts
Headers:
  Authorization: Bearer {firebaseToken}
  Content-Type: application/json
Body:
{
  "topic": "Latest breakthroughs in artificial intelligence",
  "is_public": true
}
```

---

### 6. Update Podcast

- **Endpoint:** `/api/podcasts/{podcastId}`
- **Method:** `PUT`
- **Authentication:** Required (Firebase Bearer token)
- **Request Body:** (All fields optional)
  ```json
  {
    "title": "string",
    "description": "string",
    "image_url": "string",
    "is_public": "boolean"
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": { ...updated podcast... } // Multiple response formats supported
  }
  ```
- **Used in:** `PodcastApiService.updatePodcast()`, `PodcastProvider.updatePodcast()`

**Example Request:**

```
PUT /api/podcasts/507f1f77bcf86cd799439011
Headers:
  Authorization: Bearer {firebaseToken}
  Content-Type: application/json
Body:
{
  "title": "Updated Podcast Title",
  "description": "Updated description"
}
```

---

### 7. Delete Podcast

- **Endpoint:** `/api/podcasts/{podcastId}`
- **Method:** `DELETE`
- **Authentication:** Required (Firebase Bearer token)
- **Response:**
  ```json
  {
    "success": true
  }
  ```
- **Used in:** `PodcastApiService.deletePodcast()`, `PodcastProvider.deletePodcast()`

**Example Request:**

```
DELETE /api/podcasts/507f1f77bcf86cd799439011
Headers: Authorization: Bearer {firebaseToken}
```

---

### 8. Add to Play History

- **Endpoint:** `/api/podcasts/play-history`
- **Method:** `POST`
- **Authentication:** Required (Firebase Bearer token)
- **Request Body:**
  ```json
  {
    "podcast_id": "string",
    "title": "string",
    "creator_name": "string",
    "image_url": "string",
    "position": "integer (milliseconds)",
    "duration": "integer (milliseconds)"
  }
  ```
- **Response:**
  ```json
  {
    "success": true
  }
  ```
- **Used in:** `PodcastApiService.addToPlayHistory()`

**Example Request:**

```
POST /api/podcasts/play-history
Headers:
  Authorization: Bearer {firebaseToken}
  Content-Type: application/json
Body:
{
  "podcast_id": "507f1f77bcf86cd799439011",
  "title": "Episode 1",
  "creator_name": "John Doe",
  "image_url": "https://example.com/image.jpg",
  "position": 45000,
  "duration": 3600000
}
```

---

### 9. Get Play History

- **Endpoint:** `/api/podcasts/play-history`
- **Method:** `GET`
- **Query Parameters:**
  - `limit` (optional): Default = 50
  - `offset` (optional): Default = 0
- **Authentication:** Required (Firebase Bearer token)
- **Response:**
  ```json
  {
    "success": true,
    "history": [...] // or "data": {"history": [...]}
  }
  ```
- **Used in:** `PodcastApiService.getPlayHistory()`, `MyPodcastProvider.fetchPlayHistory()`

**Example Request:**

```
GET /api/podcasts/play-history?limit=50&offset=0
Headers: Authorization: Bearer {firebaseToken}
```

---

## AI Analysis API

### 1. Generate Article Analysis

- **Endpoint:** `/ai/analyze`
- **Method:** `POST`
- **Authentication:** Bearer token (optional) or API key
- **Request Body:** (One of the following)
  ```json
  {
    "article_id": "string"
  }
  ```
  OR
  ```json
  {
    "article_text": "string"
  }
  ```
- **Response:**
  ```json
  {
    "summary": "string",
    "politicalBias": {
      "classification": "string",
      "justification": {
        "loadedLanguage": ["string"],
        "framingAndHeadline": ["string"],
        "sourceAndStorySelection": ["string"]
      }
    },
    "emotionalAnalysis": {
      "primaryEmotion": "string",
      "secondaryEmotion": "string",
      "justification": {
        "indicativeQuotes": ["string"],
        "overallTone": "string"
      }
    }
  }
  ```
- **Used in:** `AiProvider.generateAnalysis()`
- **Provides:**
  - High-fidelity summary (1-2 paragraphs)
  - Political bias detection (5-point scale)
  - Emotional analysis (primary and secondary emotions)
- **Minimum Loading Time:** 2 seconds (to preserve UX)

**Example Request:**

```
POST /ai/analyze
Headers:
  Authorization: Bearer {apiKey}
  Content-Type: application/json
Body:
{
  "article_id": "507f1f77bcf86cd799439011"
}
```

---

## User History API

### 1. Record Article Read

- **Endpoint:** `/users/history`
- **Method:** `POST`
- **Authentication:** Required (Firebase Bearer token)
- **Request Body:**
  ```json
  {
    "article_id": "string (24-hex ObjectId)",
    "article_title": "string"
  }
  ```
- **Response:**
  ```json
  {
    "success": true
  }
  ```
- **Used in:** `HistoryProvider.recordArticleRead()`
- **Validation:** Article ID must be a valid 24-character hexadecimal MongoDB ObjectId

**Example Request:**

```
POST /users/history
Headers:
  Authorization: Bearer {firebaseToken}
  Content-Type: application/json
Body:
{
  "article_id": "507f1f77bcf86cd799439011",
  "article_title": "Breaking News Article"
}
```

---

### 2. Get User's Read History

- **Endpoint:** `/users/history`
- **Method:** `GET`
- **Query Parameters:**
  - `page` (required): Page number for pagination
  - `limit` (required): Number of records per page
- **Authentication:** Required (Firebase Bearer token)
- **Response:**
  ```json
  {
    "success": true,
    "data": [...article read entries...],
    "pagination": {
      "page": "integer",
      "pages": "integer"
    }
  }
  ```
- **Used in:** `HistoryProvider.fetchReadHistory()`
- **Default Page Size:** 20 entries

**Example Request:**

```
GET /users/history?page=1&limit=20
Headers: Authorization: Bearer {firebaseToken}
```

---

## Authentication

### Authentication Types

1. **Firebase Authentication (Recommended for user-specific operations)**

   - Used for: Podcast management, history recording, user data operations
   - Header: `Authorization: Bearer {firebaseIdToken}`
   - Obtained from: `FirebaseAuth.instance.currentUser.getIdToken()`

2. **API Key Authentication (Fallback for public operations)**
   - Used for: Article fetching, trending data, public AI analysis
   - Header: `Authorization: Bearer {apiKey}`
   - Fallback Key: `sk_7b6a1f8c9d4e2f5a8b3c1e7d9f0a4b6c`

### Token Retrieval

All requests automatically use Firebase token if user is authenticated, otherwise fall back to API key.

```dart
// Implemented in RequestHandler
Future<String?> _getToken() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  } catch (e) {
    print('Error getting token: $e');
    return null;
  }
}
```

---

## Common Response Formats

### Success Response (200/201)

```json
{
  "success": true,
  "data": { ...payload... },
  "pagination": {
    "page": 1,
    "pages": 5
  }
}
```

### Error Response (4xx/5xx)

```json
{
  "success": false,
  "message": "Error description",
  "code": "ERROR_CODE"
}
```

### Status Codes

- `200 OK` - Request successful
- `201 Created` - Resource created successfully
- `400 Bad Request` - Invalid request parameters
- `401 Unauthorized` - Missing or invalid authentication
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

---

## Rate Limiting & Pagination

- **Default Page Size:** 10 articles, 20 podcasts, 20 history entries
- **Max Limit:** No documented max, but recommended 50-100
- **Offset/Page:** Use `page` + `limit` for news, `limit` + `offset` for podcasts
- **Cache Policy:** Implemented in `CacheHandler` for offline support

---

## Environment Variables

Located in `Constants.dart`:

- `baseUrlTest`: `http://10.0.0.4:8000` (Development)
- `baseUrlProd`: `https://fyp-backend-dev-yoww.onrender.com` (Production)
- `isProd`: `true` (Currently using production)
- `pageSize`: `10` (articles per page)
- `featuredArticlesSize`: `5` (featured articles)

---

## Implementation Details

### Request Handler

- **File:** `lib/utils/request_handler.dart`
- **Methods:** `get()`, `post()`, `put()`, `delete()`
- **Features:** Automatic token injection, JSON encoding, error handling

### URI Builder

- **File:** `lib/utils/uri_utils.dart`
- **Method:** `UriUtils.buildUri(endpoint, queryParams)`
- **Features:** Automatic scheme detection (HTTP/HTTPS)

### Cache Handler

- **File:** `lib/utils/cache_handler.dart`
- **Features:** Pagination caching, offline support

---

## Error Handling

All API calls include:

- **Socket Exception Handling** - Network connectivity issues
- **Timeout Exception Handling** - Request timeouts
- **HTTP Exception Handling** - Server errors
- **JSON Decode Errors** - Invalid response format

---

**Last Updated:** October 27, 2025
