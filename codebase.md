# Skillit Codebase Deep Analysis

## 1. System Overview (REAL FLOW, NOT GENERIC)

The Skillit platform is architected as a **distributed data pipeline** designed to provide curated career opportunities to students with high availability.

### Intended Execution Flow:
**Apify Actor** → **MongoDB (Cache)** → **Backend APIs (Express)** → **Frontend (Flutter)** → **UI Rendering**

- **Data Writers**: 
  - **Apify Actors**: External scrapers that crawl platforms like Internshala and Devfolio. They act as the primary source of truth for "live" data.
  - **Admin/System (Intended)**: Logic in the backend services designed to trigger runs and sync dataset items into the MongoDB cache.
- **Data Readers**: 
  - **Node/Express Backend**: Reads from the MongoDB cache to serve RESTful JSON responses.
  - **Flutter Mobile App**: Consumes the JSON to render UI.
- **Frequency**: 
  - **Ingestion**: Intended to be periodic (daily/weekly) via scheduled Apify Actor runs.
  - **Consumption**: Real-time upon user navigation to specific tabs (Internships, Hackathons).

---

## 2. End-to-End Data Pipeline (CRITICAL)

### A. Data Ingestion Flow (Apify → DB) [Partially Implemented]
- **Mechanism**: The `apify.service.js` is designed to trigger actor runs (`run-sync-get-dataset-items`).
- **Transformation**: Raw JSON from Apify is passed through normalization functions (e.g., `normaliseInternship`) which map source-specific keys (`organisation`, `applyBy`) to internal standard keys (`company`, `deadline`).
- **Storage Logic (Intended)**: Data should be upserted into MongoDB based on a unique `sourceUrl`.
- **Status**: **NOT IMPLEMENTED**. Currently, data ingestion is bypassed by hardcoded arrays in controllers.

### B. Data Retrieval Flow (DB → Backend → UI)
1. **User opens app**: `SplashScreen` initializes and checks for auth state.
2. **Tab Navigation**: User clicks "Internships".
3. **Flutter calls API**: `api_service.dart` sends a GET request to `/api/internships`.
4. **Backend Logic**: `internshipController.js` is called.
5. **Data Fetching**: 
   - **Current**: Returns a hardcoded array of ~390 objects.
   - **Intended**: Query MongoDB `Internship` collection with filters (e.g., specific skills).
6. **Response sent**: JSON payload delivered to mobile device.
7. **UI renders list**: `ListView.builder` renders "Apple-style" cards.

### C. Real-Time / Interval Behavior
- **Polling**: Not implemented. The frontend fetches data on-demand during screen initialization.
- **Backend Caching**: MongoDB acts as the persistent cache. There is no in-memory cache (like Redis) between Node and MongoDB.
- **Staleness**: High risk of stale data if Apify actors are not triggered. The hardcoded data in the controllers is statically "frozen" in time.

---

## 3. Code-Level Responsibility Mapping

| Module Category | File Name | Responsibility | Input → Process → Output |
| :--- | :--- | :--- | :--- |
| **API Handler** | `authController.js` | User session mgmt | Credentials → Hash/Check → JWT |
| **Bridge Service** | `apify.service.js` | External data bridge | Config → Fetch/Normalize → Standard Objects |
| **Logic Layer** | `internshipController.js` | Data delivery | Request → Fetch Hardcoded → JSON Array |
| **Data Model** | `User.js` | Identity schema | Object → Mongoose Validation → Record |
| **Frontend Service** | `api_service.dart` | Resilience Layer | HTTP Request → Mock Fallback/Normalize → UI Props |

---

## 4. MongoDB as Cache (VERY IMPORTANT)

In this architecture, **MongoDB is NOT the primary source of truth**; it is a **Cache Layer** for external platform data.

- **Why Cache?**: Scraping platforms in real-time is slow and prone to IP blocks. MongoDB allows the app to serve data instantly (sub-100ms) while the scrapers work in the background.
- **Resilience**: If the Apify token expires or actors fail, the system serves the last successfully cached items from MongoDB.
- **Freshness Issues**: Currently severe. Since the sync logic is missing, the "cache" is essentially the code itself (hardcoded arrays), leading to 0% freshness.
- **Duplicate Risks**: Without a strict "Source URL" or "External ID" index in MongoDB, the system is prone to duplicate entries during re-syncs.

---

## 5. API Layer Breakdown

| Route | Method | Data Source | Response Structure | Failure Scenario |
| :--- | :--- | :--- | :--- | :--- |
| `/api/internships` | GET | Hardcoded Array | `[{title, company, ..., link}]` | Connection Timeout / 500 |
| `/api/hackathons` | GET | Hardcoded Array | `[{title, organizer, tags}]` | Empty list if data corrupted |
| `/api/auth/login` | POST | `User` Collection | `{token, user: {name, email}}` | 400 (Invalid Credentials) |

---

## 6. Frontend Data Handling (Flutter)

- **Fetch Trigger**: Mostly `initState()` in screen widgets calls the `ApiService`.
- **State Management**: Uses simple `FutureBuilder` or class-level variables. Logic is baked into the classes rather than a reactive state engine like Riverpod.
- **Resilience Logic**: **High**. `api_service.dart` contains ~500 lines of hardcoded mock data. If the backend IP is incorrect or unreachable, the app seamlessly switches to internal data to prevent a "empty screen" experience.

---

## 7. UI/UX Flow

1. **Splash**: Validates local storage for tokens.
2. **Auth**: Standard Register/Login screen.
3. **Dashboard**: Loads `projects.json` and `roadmaps.json` from local assets (fastest possible load).
4. **Data Screens**: Shows shimmer/loading state, then pulls from `api_service` (Backend -> Fallback).
5. **Edge States**: "Offline fallback activated" is printed to logs when the backend connection fails.

---

## 8. Failure Points (CRITICAL)

1. **Hardcoded IP (`api_service.dart:10`)**: The backend URL is hardcoded to a local network IP (`192.168.x.x`). The app will fail to reach the server on any other network.
2. **Module System Conflict**: `apify.service.js` uses `import`, which is incompatible with the `require`-based `server.js`. This prevents current integration.
3. **Missing Models**: There are no Mongoose schemas for `Internship` or `Hackathon`. Data cannot be saved to MongoDB even if Apify works.
4. **Zombified Services**: `apify.service.js` is standalone and never called, making the primary data pipeline inactive.

---

## 9. Edge Cases

- **Partial Data**: Scrapers often fail to find a "deadline" or "stipend". `normaliseInternship` handles this by mapping to `"Not specified"`.
- **Invalid API Responses**: Frontend `_normalizeInternship` uses null-aware operators (`??`) to prevent `type 'null' is not a subtype of 'String'` crashes.
- **Duplicate Entries**: Currently not handled at the data level.

---

## 10. Testing Gaps

- **Integration Testing**: No tests to verify that `apify.service` can actually talk to Apify.
- **Auth Flow**: No end-to-end testing of the JWT lifecycle.
- **Database Validation**: No tests to ensure `User` data is correctly indexed and unique in MongoDB.

---

## 11. Performance Analysis

- **Large Payloads**: Sending 300+ internships in a single JSON response (~100KB+) is inefficient for mobile data.
- **Query Redundancy**: The backend re-creates and serves the entire hardcoded array for every request.

---

## 12. Architecture Weaknesses

- **Tight Coupling**: The frontend is too aware of the backend's potential failure (containing 500+ lines of fallback data). This suggests an untrusted backend infrastructure.
- **Scalability**: Hardcoding data into `.js` files is the ultimate scalability bottleneck. It prevents dynamic updates without code deployments.
- **Broken Pipeline**: The most critical part of the system design (Apify → DB) is currently a "ghost" implementation (files exist but are disconnected).
