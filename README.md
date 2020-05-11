# iWall
(This is the final capstone project app for Udacity iOS Developer Nanodegree.

Beautify your iPhone screen with iWall.
An app that offers you hundreds of pictures for your device. Sign up now and download whatever you want. You can also add a photo to your like list and it will be saved. So, you could download or share it later.

iWall is an application that offers you a great variety of High-quality photos for your iPhone device. 
After signing up on the application, user selects his device and can easily search for specific collections.
Also, adding photos to his like list, share it and save it!

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
- Allows the user to log in using their email and password. 
- Authenticate is done through Firebase Authenticate. 
- If the login does not succeed, an alert is presented specifying whether it was a failed network connection, or an incorrect email and password. Also, It’s animated with a background video. 
<p align="center">
  <img src="images/login.png">
</p>

## Sign up Screen
- Gives users the ability to sign up with email and password, Pick his first and last name. 
- If the email is already regiestered with another account an alert is displayed.
- Email and password validation is added where password must be at least 6 charcters, contains a special character and a number. It’s also animated with a background video.
<p align="center">
  <img src="images/signupView.png">
</p>

## Home Screen
### Device Select
- If user first time launching the App, He must select a device in order to perfourm search.
- If user already did a search before, He will found his device selcted as it's stored in Firebase Database.
<p align="center">
  <img src="images/selectedDev.png">
</p>

### Searching with tags
- User can easily search for specific images.
<p align="center">
  <img src="images/yellow.png">
</p>

### Viewing image.
- By tapping an image, a new view appears containg the image in a Higher Quality and it's label.
- By tapping the like button (Heart), the user adds the image to his likes list.
- By tapping share button, The user will be able to share image and download it.
<p align="center">
  <img src="images/liked.png">
</p>
