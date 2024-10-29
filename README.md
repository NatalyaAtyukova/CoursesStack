CoursesStack

CoursesStack is an educational and course management app designed for bloggers and users. Developed using SwiftUI and Firebase for seamless data handling, it supports localization in multiple languages.

Key Features

	•	For Bloggers:
	•	Create and manage courses
	•	Control access rights for user courses
	•	Add and edit lessons with file attachments and assignments
	•	View user reviews and ratings
	•	For Users:
	•	Browse and purchase available courses
	•	Access lessons, complete tests, and assignments
	•	Leave reviews and rate courses

Technologies Used

	•	SwiftUI: For UI design
	•	Firebase: For data management and user authentication
	•	AsyncImage: For asynchronous image loading
	•	Localization: Supports both Russian and English

Screenshots

Getting Started

	1.	Clone the Repository

git clone https://github.com/NatalyaAtyukova/CoursesStack.git
cd CoursesStack


	2.	Set Up Firebase
	•	Go to Firebase Console, create a new project, and add an iOS app.
	•	Download GoogleService-Info.plist and add it to the project.
	•	Enable necessary APIs like Authentication and Firestore Database.
	3.	Run the Project
	•	Open the project in Xcode.
	•	Select the correct scheme and target.
	•	Press Run to launch the app on a simulator or connected device.

Localization

The app supports both Russian and English. Russian is the default language; however, it automatically switches to English when the system language is set to English.

How to Add a New Language

	1.	Go to Info.plist and add a new language in localization settings.
	2.	Add new .strings files for each language in the appropriate folders.
	3.	Use NSLocalizedString to translate all textual elements.

Project Structure

	•	View: UI components like CoursePurchaseView, MyCourseDetailView, and more.
	•	ViewModel: Handles data processing and business logic.
	•	Model: Data structures like Course, Lesson, and Assignment.
	•	Resources: Localization files and images.
	•	Services: Firebase integration and services.

Contributing

We welcome contributions! If you have ideas or suggestions, here’s how to contribute:

	1.	Fork the project.
	2.	Create a new branch (git checkout -b feature/my-feature).
	3.	Commit your changes (git commit -am 'Add some feature').
	4.	Push to the branch (git push origin feature/my-feature).
	5.	Open a Pull Request.

License

This project is licensed under the MIT License. For more details, see LICENSE.

This README offers a structured overview that allows others to understand the app’s features, architecture, and setup, and easily start contributing.
