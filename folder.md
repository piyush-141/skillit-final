# SkillIt Project Structure

## 📱 Mobile Application (Flutter)
**Path:** `/Skillit`

- **lib/** - Core application logic
  - **data/** - Mock data and static content (e.g., `mock_roadmaps.dart`)
  - **models/** - Data structures/classes for Internships, Hackathons, etc.
  - **screens/** - All application views/pages
    - `login_screen.dart` / `register_screen.dart` - Authentication
    - `home_screen.dart` - Dashboard
    - `opportunities_screen.dart` - Internships & Hackathons
    - `companies_screen.dart` - Corporate Directory
    - `skills_screen.dart` - Learning & Projects
    - `roadmap_screen.dart` - Career Path UI
    - `resume_builder_screen.dart` - PDF Builder
    - `profile_screen.dart` / `edit_profile_screen.dart` - User Settings
  - **services/** - Logic for API calls and background tasks
    - `api_service.dart` - Backend connection logic
    - `auth_service.dart` - Token and session management
    - `bookmark_service.dart` - Saving items to DB
    - `resume_service.dart` - PDF generation logic
  - **widgets/** - Reusable UI components
  - `main.dart` - App entry point and global design tokens (`AppColors`)

- **assets/** - Images, icons, and local JSON fallbacks
- **android/** / **ios/** - Native platform configurations

---

## ⚙️ Backend Server (Node.js/Express)
**Path:** `/Skillit-Backend`

- **server.js** - Main entry point and server configuration
- **config/** - External service configs (MongoDB, Firebase)
- **controllers/** - Business logic for each feature
  - `authController.js` - Login, Register, Profile
  - `userController.js` - Saves and Progress tracking
  - `roadmapController.js` - Career path data
- **models/** - MongoDB Mongoose schemas
  - `User.js` - User profile and progress schema
- **routes/** - API endpoint definitions
  - `authRoutes.js`
  - `internshipRoutes.js`
  - `hackathonRoutes.js`
  - `roadmapRoutes.js`
- **services/** - Third-party integrations (e.g., Apify for web scraping)
- **.env** - Environment variables (Port, MongoDB URI)

---

## 📄 Documentation
- `folder.md` - (This file) Complete project structure
- `README.md` - Project overview and installation guide
