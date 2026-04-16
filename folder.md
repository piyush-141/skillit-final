# SkillIt — Project Structure

## 📱 Mobile Application (Flutter)
**Path:** `/Skillit`

### `lib/`
Core application logic.

#### `data/`
Static/mock data used as local fallbacks.
- `mock_roadmaps.dart` — Hardcoded roadmap data for offline use

#### `models/`
Dart data classes / types used across the app.

#### `screens/`
All application views and pages.

| File | Purpose |
|---|---|
| `splash_screen.dart` | Animated launch screen with auth-state routing |
| `login_screen.dart` | Gmail-only login with validation |
| `register_screen.dart` | Registration with Gmail + password rules |
| `main_layout.dart` | Root shell with bottom nav + `IndexedStack` |
| `home_screen.dart` | Dashboard with search overlay and quick tools |
| `opportunities_screen.dart` | Tab router for Internships & Hackathons |
| `internship_screen.dart` | Filtered internship listing with apply links |
| `hackathon_screen.dart` | Hackathon listing with tags and links |
| `companies_screen.dart` | Corporate directory grid |
| `company_detail_screen.dart` | Detailed company profile view |
| `cold_outreach_screen.dart` | AI-assisted cold outreach message generator |
| `skills_screen.dart` | Tab switcher — Roadmaps / Projects |
| `roadmap_screen.dart` | Career roadmap viewer with timeline + resources |
| `projects_screen.dart` | Domain-based project explorer with difficulty filter |
| `resume_builder_screen.dart` | Multi-step PDF resume builder with autofill |
| `saved_items_screen.dart` | Bookmarked internships and hackathons |
| `profile_screen.dart` | User profile with domain and account info |
| `edit_profile_screen.dart` | Update name, domain, and password |

#### `services/`
Business logic and external integrations.

| File | Purpose |
|---|---|
| `api_service.dart` | All backend HTTP calls + local asset fallbacks |
| `auth_service.dart` | JWT token storage and session management |
| `bookmark_service.dart` | Save/unsave items to MongoDB via API |
| `hackathon_service.dart` | Hackathon-specific API helpers |
| `internship_service.dart` | Internship-specific API helpers |
| `resume_service.dart` | PDF generation logic using `pdf` package |

#### `widgets/`
Reusable UI components.

| File | Purpose |
|---|---|
| `glassmorphic_bottom_nav.dart` | Custom frosted-glass bottom navigation bar |

#### `main.dart`
App entry point. Defines `AppColors` (global design tokens), `MaterialApp`, theme, and named routes.

---

### `assets/`
Bundled assets compiled into the app binary.

```
assets/
├── images/          # App logo and icons
└── data/
    ├── projects.json   # Curated project ideas (source of truth / offline fallback)
    ├── roadmaps.json   # Career learning roadmaps (offline fallback)
    └── companies.json  # Corporate directory data (offline fallback)
```

> **Note:** The `assets/data/` JSON files serve as guaranteed offline fallbacks if the Render backend is unreachable (cold start, network timeout, etc.).

---

## ⚙️ Backend Server (Node.js / Express)
**Path:** `/Skillit-Backend`
**Live URL:** `https://skillit-backend-1.onrender.com/api`

### `server.js`
Main Express entry point — registers all routes under `/api`.

### `config/`
External service configuration.
- `serviceAccountKey.json` — Firebase service account (if used)

### `controllers/`
Business logic for each feature.

| File | Purpose |
|---|---|
| `authController.js` | Register, login, profile get/update, password change |
| `userController.js` | Save/unsave items, progress tracking |
| `roadmapController.js` | Serve roadmap data from DB or `data/roadmaps.json` |
| `projectController.js` | Serve project domains from DB or `data/projects.json` |
| `companyController.js` | Serve company list from DB or `data/companies.json` |
| `internshipController.js` | Internship listing (scraped via Apify or static) |
| `hackathonController.js` | Hackathon listing (scraped via Apify or static) |
| `searchController.js` | Global search across roadmaps, projects, companies |

### `models/`
MongoDB Mongoose schemas.

| File | Schema |
|---|---|
| `User.js` | Name, email, password (hashed), domain, saves, progress |
| `Roadmap.js` | Field ID, label, tagline, steps, resources |
| `Project.js` | Domain ID/label, level, title, skills, tech stack |
| `Company.js` | Company meta, roles, culture, tech stack |
| `Internship.js` | Title, company, stipend, skills, apply link |
| `Hackathon.js` | Title, organiser, prize, deadlines, link |

### `routes/`
API endpoint definitions.

| File | Base Path |
|---|---|
| `authRoutes.js` | `/api/auth` |
| `roadmapRoutes.js` | `/api/roadmaps` |
| `projectRoutes.js` | `/api/projects` |
| `companyRoutes.js` | `/api/companies` |
| `internshipRoutes.js` | `/api/internships` |
| `hackathonRoutes.js` | `/api/hackathons` |
| `searchRoutes.js` | `/api/search` |

### `data/`
Source-of-truth JSON files. Served by controllers when DB is empty.
- `projects.json` — All domain project ideas (6 domains × 9 projects)
- `roadmaps.json` — Career roadmap definitions
- `companies.json` — Company directory

### `services/`
Third-party integrations.
- `apify.service.js` — Web scraping integration for live internship/hackathon data

### `middleware/`
Express middleware (auth guards, error handlers).

### `scripts/`
Utility scripts.
- `seedDB.js` — Seeds MongoDB Atlas with data from the `/data` JSON files

### `.env`
Environment variables (not committed).
```
PORT=5000
MONGO_URI=<MongoDB Atlas connection string>
JWT_SECRET=<secret>
```

---

## 📄 Documentation
| File | Purpose |
|---|---|
| `folder.md` | This file — complete project structure reference |
| `codebase.md` | High-level architecture and feature summary |
| `README.md` | Installation and deployment guide |
