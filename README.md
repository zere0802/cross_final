# Personal Finance Tracker

A Flutter application for managing personal expenses using local database storage and modern state management.

## Features

- Add expenses
- Edit expenses
- Delete expenses
- View total balance
- Dark mode support
- Category selection
- Responsive GridView layout
- Local data persistence

---

## Technologies Used

### State Management
- Riverpod

### Local Database
- Drift (SQLite)

### Local Preferences
- SharedPreferences

### Architecture
- Clean Architecture
- Repository Pattern

---

## Project Structure

lib/
├── core/
├── features/
│ └── expenses/
│ ├── data/
│ │ ├── database/
│ │ ├── repositories/
│ ├── domain/
│ │ ├── repositories/
│ └── presentation/
│ └── providers/

---

## Implemented Requirements

- Responsive UI
- GridView layout
- Interactive Widgets
- Riverpod state management
- Drift local database
- SharedPreferences
- CRUD operations
- Clean Architecture
- Repository Pattern
- Loading states

---

## Screenshots

### Home Screen
- Expense cards
- Total balance
- Dark mode

### Add Expense
- Dialog form
- Dropdown categories

### Edit Expense
- Update existing expense

---

## Packages

```yaml
flutter_riverpod
drift
drift_flutter
sqlite3_flutter_libs
shared_preferences
path_provider