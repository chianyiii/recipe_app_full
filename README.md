# Recipe App

A Flutter-based recipe management application that allows users to browse, create, and manage recipes. The app supports both local recipes and online search using the Spoonacular API.

---

## **Features**

- User authentication (register, login, logout) with hashed passwords.
- View a list of recipes filtered by category.
- Add new recipes with image, ingredients, and steps.
- View detailed recipe pages with update and delete options.
- Search online recipes via Spoonacular API.
- Save online recipes to local database.
- Persistent storage using SQLite (`sqflite`) to keep recipes across app restarts.
- Responsive UI adhering to Material Design.

---

## **Installation**

1. **Clone the repository:**

```bash
git clone <your-repo-url>
cd recipe_app
```

2. **Install dependencies:**

```bash
flutter pub get
```

3. **Run the app**

flutter run


---

## **Usage Guide**

1. Register & Login
- Open the app.
- Click Register to create a new account.
- Use the created account to login.

2. Browsing Recipes
- The Recipe List screen shows all recipes.
- Use the dropdown or filter options to view recipes by type.

3. Adding a New Recipe
- Click Add Recipe button.
- Fill in the recipe name, select category, upload an image, enter ingredients and steps.
- Save to store it in the local database.

4. Viewing and Editing Recipes
- Tap a recipe card to view details.
- Edit fields and click Save to update.
- Click Delete to remove the recipe.

5. Search Online Recipes
- Go to Search Online screen.
- Enter a keyword and click Search.
- Tap on a recipe to view details and optionally save it to your local database.

---

## Technical Details

Framework: Flutter
Language: Dart
Local Storage: SQLite (sqflite)
State Management: Provider
Networking: HTTP requests to Spoonacular API
Password Security: SHA-256 hashing with static salt
Reactive Programming: ChangeNotifier with Provider


---

## Notes

- Make sure your device/emulator has internet access for online search.
- Default recipes are preloaded when a new account is registered.
- All recipe data persists across app restarts using SQLite.

