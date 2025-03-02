# Family Choi Chronicles - App Documentation

## 🎮 Overview
Family Choi Chronicles is an interactive, RPG-style family project management app designed to make family history documentation and collaboration fun and engaging. The app gamifies the process of recording family history, completing family projects, and collaborating with family members through character creation, clan formation, and mission completion.

## 🌟 Key Features
- **Character Creation**: Create personalized RPG character profiles for family members
- **D&D-style Character Generation**: AI-powered character generation based on personality questions
- **Clan Management**: Form clans to group family members together for collaborative projects
- **Mission System**: Complete missions to earn experience and level up characters
- **Project Management**: Create and track family projects like genealogy research or photo organization
- **Achievement System**: Unlock achievements by completing project milestones
- **Skill Development**: Develop character skills through activity completion

## 📱 App Structure

### Screens
The app includes the following key screens:

1. **SplashScreen**
   - Entry point for the application
   - Displays app logo and initializes services
   - Transitions to LoginScreen

2. **LoginScreen**
   - Allows users to log in with email
   - Creates sample data for new users
   - Transitions to CharacterCreationScreen for new users or DashboardScreen for returning users

3. **CharacterCreationScreen**
   - Lets users input basic character information (name, email)
   - Generates a battle cry for the character
   - Transitions to CharacterQuestionnaireScreen

4. **CharacterQuestionnaireScreen**
   - Presents a series of personality questions to users
   - Uses responses to generate a D&D-style character profile
   - Displays the generated character with class, specialty, and skills
   - Saves character information and transitions to ClanSelectionScreen

5. **ClanSelectionScreen**
   - Allows users to join an existing clan or create a new one
   - Displays clan information and members
   - Transitions to DashboardScreen after selection

6. **DashboardScreen**
   - Central hub for app navigation
   - Displays character information, level, and experience
   - Shows active missions and projects
   - Provides access to other screens (Character, Clan, Projects)

7. **CharacterScreen**
   - Displays detailed character information
   - Shows skills, experience, and level progression
   - Allows skill upgrading and character customization

8. **ClanScreen**
   - Shows clan members and their roles
   - Displays clan level and achievements
   - Allows clan management for clan leaders

9. **ProjectsScreen**
   - Lists active and completed projects
   - Allows creation of new projects
   - Shows project progress and associated missions

10. **MissionScreen**
    - Displays mission details and requirements
    - Allows mission completion and progress tracking
    - Shows experience rewards

11. **AchievementsScreen**
    - Lists unlocked and locked achievements
    - Shows achievement requirements and rewards
    - Displays achievement progress

### Services

1. **MockDataService**
   - Manages data persistence using Hive storage
   - Provides CRUD operations for characters, clans, projects, missions
   - Generates sample data for new users
   - Acts as a temporary replacement for a full backend

2. **OpenAIService**
   - Interfaces with OpenAI API to generate content
   - Generates D&D character profiles based on questionnaire responses
   - Creates project names, missions, and achievements based on goals
   - Provides mock responses when API key is unavailable

3. **GameEffectsService**
   - Manages visual and audio effects throughout the app
   - Controls animation for level ups, achievements, and rewards
   - Handles sound effects for different game events

4. **TutorialManager**
   - Guides new users through the app's features
   - Displays tutorial tooltips and walkthroughs
   - Tracks tutorial completion status

### Models

1. **Character**
   - Core user representation in the app
   - Contains attributes like name, specialty, level, experience
   - Stores skills, completed missions, and clan affiliation
   - Includes D&D character profile data (class, specialty, skills)

2. **Clan**
   - Represents a family group
   - Contains member list and leadership structure
   - Tracks clan level, experience, and achievements
   - Stores clan projects and collaborative activities

3. **Project**
   - Represents a family undertaking (e.g., creating a family tree)
   - Contains project details, goals, and deadlines
   - Associated with missions and achievements
   - Tracks progress and completion status

4. **Mission**
   - Represents tasks within projects
   - Contains description, requirements, and reward information
   - Tracks status (todo, in progress, completed)
   - Associated with characters assigned to complete them

5. **Achievement**
   - Represents milestones and accomplishments
   - Contains unlock conditions and reward information
   - Tracks completion status and unlock date
   - Categorized by tiers (bronze, silver, gold, etc.)

6. **Skill**
   - Represents character abilities and talents
   - Contains level, experience, and specialty information
   - Develops through activity completion
   - Provides bonuses for related missions

## 💾 Data Flow

1. **User Registration/Login**
   - User enters email address
   - App checks for existing user data
   - Creates new character if no data exists
   - Loads existing character, clan, and project data if returning user

2. **Character Creation**
   - User enters basic character information
   - Takes personality questionnaire
   - AI generates D&D character profile
   - Character data is saved to local storage

3. **Clan Selection/Creation**
   - User joins existing clan or creates new one
   - Clan data is updated with new member
   - Character data is updated with clan affiliation

4. **Project Management**
   - User creates new project with goal
   - AI generates project name, missions, and achievements
   - Projects are saved and associated with clan and character
   - Progress is tracked through mission completion

5. **Mission Completion**
   - User marks missions as complete
   - Character gains experience
   - Mission status is updated
   - Project progress is recalculated
   - Achievements are checked for unlocking

6. **Achievement Unlocking**
   - System checks achievement conditions against progress
   - Unlocks achievements when conditions are met
   - Awards experience and other rewards
   - Updates achievement status in storage

## 🎨 UI/UX Design

### Theme
The app uses a vibrant, playful theme with:
- Primary Color: Vibrant purple (#5E60CE)
- Secondary Color: Sunny yellow (#FFBE0B)
- Background Color: Light sky blue (#F0F4FF)
- Text Color: Soft black (#333333)
- Accent Color: Bright teal (#64DFDF)

### Typography
- Primary Font: Baloo 2 (for headings and emphasis)
- Secondary Font: Quicksand (for body text and content)

### UI Components
- Custom animated buttons with ripple effects
- Character cards with level progress indicators
- Mission tiles with status indicators
- Achievement badges with tier-based styling
- Custom dialog boxes for character creation and rewards

## 🚀 Getting Started

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Add your OpenAI API key in the `.env` file (optional)
4. Run `flutter run` to launch the app

### First Run Experience
1. App initializes and shows splash screen
2. Enter your email to log in
3. Create your character by entering name and details
4. Answer personality questions for D&D character generation
5. Join or create a clan
6. Explore the dashboard and start your first project

### Demo Credentials
- Email: choi@familyquest.com
- Test characters: Arthur Kingsley (Leader), Luna Starweave (Mage)
- Sample clan: Choi Family
- Sample project: Family Chronicle Creation

## 🧩 Technical Implementation

### State Management
- Provider pattern for app-wide state
- Local state management using StatefulWidget where appropriate

### Data Persistence
- Hive for local data storage
- JSON serialization for models
- Future support for cloud syncing

### External APIs
- OpenAI API for content generation
- Mock implementations provided for development

### Performance Considerations
- Lazy loading of mission and project data
- Efficient rendering of list views with builder patterns
- Optimized asset loading

## 🔮 Future Enhancements
- Cloud synchronization for family collaboration
- Real-time updates between family members
- Media upload for photos and documents
- Voice recording for oral history preservation
- Timeline visualization for family history
- Expanded achievement and reward system
- More character customization options
- Enhanced AI interactions for story generation

---

## 🧪 Developer Notes

### Key Classes and Their Relationships
- `Character` relates to `Clan` through the clan ID reference
- `Project` contains lists of `Mission` and `Achievement` objects
- `Mission` references characters through assignedCharacterIds
- `Skill` is referenced by characters through skillIds

### Test Data Generation
- `MockDataService.generateSampleData()` creates initial test data
- Sample characters, clans, and projects are created on first login
- Test data is persistent between sessions

### Debugging
- Debug messages use emoji prefixes for easy filtering:
  - 👤 Character-related messages
  - 🛡️ Clan-related messages
  - 📋 Project-related messages
  - 🏆 Achievement-related messages
  - 🤖 AI-related messages

---

## 📝 API Documentation

### OpenAIService

#### Methods:
- `initialize()`: Set up the OpenAI service
- `generateProjectName(String goal)`: Generate a creative project name
- `generateMissions(String goal, String projectName, int count)`: Generate mission list
- `generateAchievements(String goal, String projectName)`: Generate achievement list
- `generateCharacterFromResponses(String prompt)`: Create character based on survey
- `generateDnDCharacter(List<String> responses)`: Generate D&D character profile

### MockDataService

#### Methods:
- `initialize()`: Set up the data service and storage
- `saveCharacter(Character character)`: Save character data
- `getCharacter(String userId)`: Retrieve character by user ID
- `saveClan(Clan clan)`: Save clan data
- `getClan(String clanId)`: Retrieve clan by ID
- `saveProject(Project project)`: Save project data
- `getProjects(String clanId)`: Get projects for a clan
- `generateSampleData(String userId)`: Create sample data for new users

### GameEffectsService

#### Methods:
- `initialize()`: Set up the effects service
- `playSound(GameSound sound)`: Play a sound effect
- `showLevelUpEffect(BuildContext context, int level)`: Display level up animation
- `showXpGainEffect(BuildContext context, int amount)`: Show experience gain
- `showAchievementUnlocked(BuildContext context, Achievement achievement)`: Display achievement unlock

---

This documentation provides a comprehensive overview of the Family Choi Chronicles app, its structure, and functionality. As the application evolves, this documentation should be updated to reflect new features and changes. 