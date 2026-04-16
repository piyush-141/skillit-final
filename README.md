# Skillit

## 1. Overview

Skillit is a comprehensive student career development platform designed to bridge the gap between academic learning and professional opportunities. It aggregates verified internships, hackathons, and curated skill roadmaps into a single, high-fidelity mobile experience.

Targeted at students and early-career seekers, Skillit's key value proposition is **reliability and speed**. By using a sophisticated caching layer for external data, the platform ensures that users always have access to career opportunities without the latency of real-time web scraping.

---

## 2. Features

- **User Authentication**: Secure signup and login using JWT and password hashing.
- **Curated Internships**: A massive database of verified internship listings from platforms like Internshala.
- **Hackathon Tracker**: Real-time tracking of upcoming hackathons with details on prizes, team size, and deadlines.
- **Skill Roadmaps**: Structured career paths for roles like Full Stack Developer, Data Scientist, and UI/UX Designer.
- **Offline Resilience**: Mobile app includes local fallbacks to ensure core information is accessible even without a backend connection.
- **Apple-Inspired UI**: A premium, high-fidelity interface built with Flutter, focusing on smooth transitions and micro-animations.

---

## 3. Tech Stack

- **Frontend (Flutter)**: Cross-platform mobile development using Dart.
- **Backend (Node.js / Express)**: RESTful API server handling logic and authentication.
- **Database (MongoDB)**: Used via Mongoose for user persistence and as a cache for external listings.
- **External Services**: **Apify** for data scraping/ingestion;
- **Google Fonts** for typography.

---

## 4. System Architecture

Skillit uses a **tiered data pipeline** to ensure data availability:

**Apify Actors** → **MongoDB (Cache)** → **Backend APIs (Express)** → **Flutter App**

1. **Who writes data**: Apify Actors periodically crawl external job boards. The backend service layer is designed to ingest this data into MongoDB.
2. **Who reads data**: The Node/Express backend reads from the MongoDB cache. The Flutter app consumes these endpoints.
3. **Update Frequency**: Designed for periodic updates (e.g., once daily) to keep the cache fresh without slamming source platform servers.

---

## 5. Folder Structure

```text
skillit-final/
├── Skillit/                  # Frontend (Flutter)
│   ├── assets/               # Data (projects.json, roadmaps.json) & Images
│   ├── lib/
│   │   ├── models/           # Dart data models
│   │   ├── screens/          # UI pages (Login, Dashboard, etc.)
│   │   ├── services/         # API logic (api_service.dart)
│   │   └── widgets/          # Reusable UI components
│   └── pubspec.yaml          # Flutter dependencies
│
└── Skillit-Backend/          # Backend (Node/Express)
    ├── controllers/          # Business logic & Route handlers
    ├── models/               # MongoDB (Mongoose) schemas
    ├── routes/               # API endpoint definitions
    ├── services/             # External integrations (Apify)
    ├── server.js             # Entry point
    └── package.json          # Node dependencies
```

---

## 6. Getting Started (CRITICAL)

### Prerequisites

- **Flutter SDK** (3.0.0 or higher)
- **Node.js** (v16.x or higher)
- **npm** or **yarn**
- **MongoDB** (Atlas account or local instance)
- **Apify Account** (For tokens)

### Installation

1. **Clone the repository**:

   ```bash
   git clone https://github.com/piyush-141/skillit-final.git
   ```

2. **Install Backend Dependencies**:

   ```bash
   cd Skillit-Backend
   npm install
   ```

3. **Install Frontend Dependencies**:

   ```bash
   cd ../Skillit
   flutter pub get
   ```

4. **Setup Environment Variables**:
   In `Skillit-Backend/`, create a `.env` file based on the section below.

5. **Start the Backend**:

   ```bash
   cd ../Skillit-Backend
   npm run dev
   ```

6. **Run the Frontend**:
   Ensure an emulator or physical device is connected.
   ```bash
   cd ../Skillit
   flutter run
   ```

---

## 7. Environment Variables

Create a `.env` file in the `Skillit-Backend/` directory:

- `MONGO_URI`: Your MongoDB connection string.
- `JWT_SECRET`: Secret key for JWT token generation.
- `PORT`: Port the server runs on (default: 5000).
- `APIFY_TOKEN`: Your API token from Apify.
- `APIFY_ACTOR_ID`: The ID of the primary scraper actor.
- `APIFY_TASK_ID`: The ID of the specific scraping task.

---

## 8. Running the Project

### Backend

- **Command**: `npm run dev` (starts server with nodemon).
- **Expected Output**: `✅ MongoDB Connected` and `🚀 Server running on port 5000`.

### Frontend

- **Command**: `flutter run`
- **Known Issue**: The `baseUrl` in `lib/services/api_service.dart` is currently hardcoded to a local IPv4 address. You **must** update this to your machine's current IP address or `localhost` (for simulators) to connect to the backend.

---

## 9. Data Flow (VERY IMPORTANT)

1. **User opens app**: Flutter initializes and calls `ApiService.login()` or data fetch methods.
2. **Flutter calls API**: Request is sent to the Node backend via HTTP.
3. **Backend fetches from MongoDB**: The backend queries the MongoDB cache for the latest listings.
4. **Cache Layer**: MongoDB contains data previously pushed by Apify Actors.
5. **Response Sent**: Full JSON payload is delivered to the app.
6. **UI Updates**: The app renders listing cards.

- **Refresh Logic**: Data is designed to be synced via the `apify.service.js` (currently disconnected).
- **Stale Data**: If the scrapers fail, the app serves stale data from the cache (or its internal hardcoded fallbacks) to maintain a functional experience.

---

## 10. API Endpoints

| Route                | Method | Purpose                           |
| :------------------- | :----- | :-------------------------------- |
| `/api/auth/register` | POST   | Create new user account           |
| `/api/auth/login`    | POST   | Get auth token and user info      |
| `/api/internships`   | GET    | Fetch list of curated internships |
| `/api/hackathons`    | GET    | Fetch list of upcoming hackathons |
| `/api/roadmaps`      | GET    | Fetch career skill roadmaps       |
| `/api/companies`     | GET    | Fetch top hiring companies        |

---

## 11. Known Issues / Limitations

- **Hardcoded Data**: Backend controllers currently serve hardcoded arrays rather than querying MongoDB directly for listings.
- **Module Mismatch**: `apify.service.js` uses ES Modules (`import`), but the backend is configured as CommonJS (`require`). This prevents the sync logic from running.
- **Frontend IP**: Backend URL is hardcoded to a specific local IP address in the Flutter code.
- **Incomplete Pipeline**: The automated sync from Apify to MongoDB is documented but not fully integrated into the API controller logic.

---

## 12. Future Improvements

- **Database Migration**: Move all hardcoded listings into MongoDB collections.
- **Automated Syncing**: Fix the backend module conflict and automate Apify Actor triggers.
- **Environment Management**: Implement `flutter_dotenv` to remove hardcoded IPs from the frontend.
- **Real-time Notifications**: Notify users when a new high-salary internship is cached.

---

## 13. Contributing

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

---

## 14. License

This project is currently unlicensed. All rights reserved.
