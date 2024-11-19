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

Screenshots

<img width="458" alt="Снимок экрана 2024-11-19 в 18 57 34" src="https://github.com/user-attachments/assets/462f7713-bb59-4ed9-b367-e96363e58e33">
<img width="458" alt="Снимок экрана 2024-11-19 в 18 57 25" src="https://github.com/user-attachments/assets/9981d896-65fa-496e-9620-f53e11b139b8">
<img width="458" alt="Снимок экрана 2024-11-19 в 18 57 22" src="https://github.com/user-attachments/assets/29334026-afb3-401a-b16b-42fa72cb12c2">
<img width="458" alt="Снимок экрана 2024-11-19 в 18 57 17" src="https://github.com/user-attachments/assets/417863fb-1a36-4c83-a366-2196fb58b2cf">
<img width="458" alt="Снимок экрана 2024-11-19 в 18 56 45" src="https://github.com/user-attachments/assets/fc1eac7a-cbd1-46c8-9716-d3b9cc0691a3">
<img width="458" alt="Снимок экрана 2024-11-19 в 18 56 36" src="https://github.com/user-attachments/assets/db8b4b49-72c4-4e54-841e-8566d3d41ca8">
<img width="458" alt="Снимок экрана 2024-11-19 в 18 51 35" src="https://github.com/user-attachments/assets/548b5e95-b7e7-483a-b57a-b9e929b9c9b1">
<img width="458" alt="Снимок экрана 2024-11-19 в 18 51 31" src="https://github.com/user-attachments/assets/e0b3169d-64a8-49f8-84e7-79033e2def6d">
<img width="458" alt="Снимок экрана 2024-11-19 в 18 51 26" src="https://github.com/user-attachments/assets/0754f7a0-ea89-49b1-b57f-e5441dd3ad38">
<img width="458" alt="Снимок экрана 2024-11-19 в 18 51 20" src="https://github.com/user-attachments/assets/f59c39b6-734f-45c4-9233-043ed0a55b84">
<img width="458" alt="Снимок экрана 2024-11-19 в 18 51 17" src="https://github.com/user-attachments/assets/0c9a0587-ed0c-4e6e-894f-2c1d44dbd78e">


