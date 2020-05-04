# playersMeet

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
This app lets you have fun with sports you enjoy, while also meeting new people. It allows you to choose a particular sport and team up with people nearby.

### App Evaluation
- **Category:** Social Networking
- **Mobile:** This is developed for mobile due to its efficiency and accessibility, but its functions can also be transfered over to a website application as well.
- **Story:** Allows users to select groups and meetup with people beased on location and sport specification. 
- **Market:** Any individual interested in sports can use this app.
- **Habit:** This app can be used anytime based on the user's liking and preference for a particular sport. 
- **Scope:** It will start off with a few people, but once the users grow it will allow for a better interaction/matching among users based on the type of sport and location. 

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

- [x] User can sign up.
- [x] User can login.
- [x] User can logout. 
- [ ] User can choose sport.
- [x] User can choose location.
- [x] User can form/join a team.
- [ ]  Profile pages for each user
- [ ] Settings (Accesibility, Notification, General, etc.)

**Optional Nice-to-have Stories**

* User can choose location from map.
* User can add friends.
* User can rate location.
* User can use app as a guest.

### 2. Screen Archetypes

* Login
* Register
* Profile Screen
* Start a Game Screen - User can choose their preferences/sport.
* Select a Team Screen - User sees a list of teams and choose one.
* Settings Screen

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Profile 
* Game
* Settings

**Flow Navigation** (Screen to Screen)

* Forced Log-in -> Account creation if no log in is available
* Profile -> Settings

## Wireframes
<img src = "Screen Shot 2020-04-16 at 1.43.44 PM.png">
<img src = "Screen Shot 2020-04-16 at 1.43.50 PM.png">
<img src = "Screen Shot 2020-04-16 at 1.45.46 PM.png">

## Progress GIF

**Sign Up/Sign In/Logout**                       

<img src="http://g.recordit.co/1mn1phDDOz.gif" width=250>

**Sign Up/Sign In/Logout & Show Locations & Join/Leave Team**

<img src="http://g.recordit.co/8UAe3HouHL.gif" width=250><br>

## Schema 
### Models
#### User

| Property   | Type          | Description |
| ---------- | ------------- | ----------- |
| userId     | Number  | unique id for the user |
| username   | String  | unique username for the user |
| profilePic | File    | profile picture for the user |
| bio        | String  | profile description for the user  |

#### Game

| Property | Type   | Description |
| -------- | ------ | ----------- |
| gameId   | Number | unique id for game |
| location | String | location of the meetup place |
| sport    | String | sport to be played

#### Team

| Property   | Type   | Description |
| ---------- | ------ | ----------- |
| teamId     | Number | unique id for team |
| noUsers    | Number | number of users in the team |
| createdBy  | Pointer to User | team creator |

### Networking
#### List of network requests by screen
   - Profile Screen
      - (Read/GET) Get logged in user information
        ```swift
        guard let user = PFUser.current() else {
            print("Failed to get user")
        }
        let username = user["profilePic"] as? String
        let bio = user["bio"] as? String
        let profilePicFile = user["profilePic"] as! PFFileObject
        ```
      - (Update/PUT) Update user information
        ```swift
        guard let user = PFUser.current() else {
            print("Failed to get user")
        }
        user["username"] = "michaeljordan23"
        user["bio"] = "I love basketball!"

        let profilePicData = photoView.image?.pngData()
        let file = PFFileObject(name: "profile.png", data: profilePicData!)
        user["profilePic"] = file

        user.save()
        ```
   - Game Screen
      - (Read/GET) Get games
        ```swift
        let query = PFQuery(className:"Game")
        query.whereKey("sport", equalTo: sport)
        query.findObjectsInBackground { (games: [PFObject]?, error: Error?) in
           if let error = error {
              print(error.localizedDescription)
           } else if let games = games {
              print("Successfully retrieved \(games.count) games.")
              // TODO: Do something with games...
           }
        }
        ```
      - (Read/GET) Get game by id
        ```swift
        let query = PFQuery(className:"Game")
        query.whereKey("gameId", equalTo: gameId)
        query.findObjectsInBackground { (games: [PFObject]?, error: Error?) in
           if let error = error {
              print(error.localizedDescription)
           } else if let games = games {
              print("Successfully retrieved \(games.count) games.")
              // TODO: Do something with games...
           }
        }
        ```
   - Team Screen
      - (Read/GET) Get teams
        ```swift
        let team1query = PFQuery(className:"Team")
        team1query.whereKey("teamId", equalTo: teamId1)
        
        let team2query = PFQuery(className:"Team")
        team2query.whereKey("teamId", equalTo: teamId2)
        
        let query = PFQuery.orQuery(withSubqueries: [team1query, team2query])    
        query.findObjectsInBackground { (teams: [PFObject]?, error: Error?) in
           if let error = error {
              print(error.localizedDescription)
           } else if let teams = teams {
              print("Successfully retrieved \(teams.count) teams.")
              // TODO: Do something with teams...
           }
        }
        ```
      - (Create/POST) Create team
        ```swift
        guard let user = PFUser.current() else {
            print("Failed to get user")
        }
        let team = PFObject(className: "Team")
        team["createdBy"] = user
        team["noUsers"] = 1
        
        team.saveInBackground { (success, error) in
            if success {
                print("Successfully created team!")
            }
            else {
                print("Failed to create team!")
            }
        }
        ```
#### [OPTIONAL:] Existing API Endpoints
##### Yelp API
- Base URL - https://api.yelp.com/v3

| HTTP  | Endpoint  |Description |
| ------------- | ------------- | -------- |
| `GET` | /businesses/search | search businesses |
| `GET` | /businesses/search?location=location | search businesses by location (i.e. city) |
| `GET` | /businesses/search?latitude=latitude&longitude=longitude | search businesses by latitude & longitude coordinates (i.e. current location) |
| `GET` | /businesses/search?location=location&categories=categories | search businesses by location (i.e. city) and categories (i.e. basketballcourts) |
| `GET` | /businesses/{id} | return specific business by id |
