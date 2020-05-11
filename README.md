# iWall
(This is the final capstone project app for Udacity iOS Developer Nanodegree.)

Beautify your iPhone screen with iWall. An app that offers you hundreds of pictures for your device. Sign up now and download whatever you want. You can also add a photo to your like list and it will be saved. So, you can download or share it later.

iWall is an application that offers you a great variety of High-quality photos for your iPhone device. After signing up, users select their device and can easily search for specific collections. Also, user can add photos to his favourits’ list, share a photo and save it!

## This project focused on:
* Design and build an app from the ground up.
* Build sophisticated and polished user interfaces with UIKit components.
* Downloading data from network resources.
* Using Firebase Framework for Authenticationa, Real-Time Database and Firebase Storage.
* Using NSCache to reduce the need to download reused data.

## App Structure
iWall is following the MVC pattern.
<p align="center">
  <img src="images/mvc.png">
</p>

## Main Screen
- Allows the user to choose between Login or Sign Up. It’s animated with a background video.
<p align="center">
  <img src="images/MainView.png">
</p>

## Login Screen
- Allows the user to log in using their Email and password. 
- Authentication is done through Firebase Authentication.
- If the login does not succeed, an alert is presented specifying whether it was a failed network connection, or an incorrect Email and password. Also, It’s animated with a background video. 
<p align="center">
  <img src="images/login.png">
</p>

## Sign up Screen
- Give users the ability to sign up with Email and password, Pick their first and last name. 
- If the email is already registered with another account an alert is displayed.
- Email and password validation is added. Where password must be at least 6 characters, contains a special character and a number. It’s also animated with a background video.
<p align="center">
  <img src="images/signupView.png">
</p>

## Home Screen
### Device Select
- If it's the user first time to launch the App, they must select a device in order to perform search.
- If user already did a search before, He will find his device selected as it's stored in Firebase Database.
<p align="center">
  <img src="images/selectedDev.png">
</p>

### Searching with tags
- User can easily search for specific images.
<p align="center">
  <img src="images/yellow.png">
</p>

### Viewing image.
- By tapping an image, a new view appears containg the image a High-quality version and it's title.
- By tapping the like button (Heart), the user adds the image to his favorites’ list.
- By tapping share button, The user will be able to share image and download it.
<p align="center">
  <img src="images/liked.png">
</p>

## Favorite List Screen
- User can see all their likes by tapping on the user icon.
- All favorite images are stored in Firebase Storage. So, whenever a user login in any device anywhere he will find all his data saved and secured.
- Also, By tapping the favorite button again the image will be un-favorited and will be removed from Firebase Storage.
<p align="center">
  <img src="images/listLikes.png">
</p>

### User info.
- Users can also modify their first and last name using Firebase real time database.
<p align="center">
  <img src="images/favList.png">
</p>

## Persistent State.
- The App saves the users's data (email, password, device). So, when he re-launched the App this view will appear as it's automatically logging him to his account.
- The Main view won't appear as the users won't be asked to signin or signup, if there's a failed network connection the users will be re-moved to the Main View.
- After loggin, The User will be directed back to his Home view.
- Once opening, the user data will be fetched from the Firebase database. So, the users will found their favorite images and their name saved.
<p align="center">
  <img src="images/AutomaticLogin.png">
</p>

# Dependencies:
- Firebase Authentication.
- Firebase Realtime Database.
- Firebase Storage.
- Pixabay API.
- UIKit.
