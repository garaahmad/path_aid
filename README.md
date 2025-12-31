# PathAid - Ambulance Management System

PathAid is a comprehensive Flutter-based application designed to manage and coordinate ambulance transportation requests between various medical facilities. It provides a robust platform for dispatchers, drivers, and administrators to streamline the process of patient transfers.

## Key Features

- **Request Management:** Create and track transportation requests with detailed patient and facility information.
- **Dispatching System:** Efficiently assign vehicles and drivers to pending requests.
- **Real-time Status Tracking:** Monitor the progress of tasks from 'Pending' to 'Completed' with a sequential workflow.
- **Facility Management:** Manage medical facilities (hospitals, clinics, labs) across various regions.
- **Vehicle & Driver Management:** Administrative tools for managing the ambulance fleet and personnel.
- **Role-based Access:** Customized interfaces for Admin, Dispatcher, and Driver roles.

## Recent Standardizations

As part of our commitment to a consistent and premium user experience, we have standardized the following:

### Toast Notifications
All `MotionToast` alerts across the mobile and desktop applications have been unified with the following configuration:
- **Animation:** `slideInFromTop`
- **Duration:** 2 seconds
- **Alignment:** `topCenter`
- **Behavior:** No sidebar, minimal and clean aesthetic.

### Code Quality & UI Refinements
- **Linting:** Addressed unreferenced declarations and unused variables across multiple screens.
- **Consistency:** Removed redundant parameters from UI components to maintain a unified design system.

## Getting Started

To get started with development:
1. Ensure Flutter is installed on your system.
2. Run `flutter pub get` to install dependencies.
3. Use `flutter run` to launch the application on your preferred device.
