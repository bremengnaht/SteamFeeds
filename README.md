# SteamFeeds
This app part of udacity iOS Developer Nanodegree. This app allows users to fetch a list of games available on Steam. Users can then favorite a list of games to retrieve the latest news about their selected games.
 * [App Specification](https://docs.google.com/document/d/1CWsC1jszFEYX5EM3CE9sX88FuIZCim4fMNml-lUPKlo/pub)

## This project focused on

* Store News on the device file system
* Use Core Data for local persistence of an object structure
* Accessing networked data - Steam API
* Parsing JSON file using Codable (Decodable , Encodable)
* Creating user interfaces that are responsive using asynchronous requests
* Use Webkit framework and SafariServices to display HTML content

## App Structure
SteamFeeds is following the MVC pattern. 

<img src="https://github.com/bremengnaht/SteamFeeds/blob/main/Demo%20Images/AppStruct.png" alt="alt text" width="686" height="775" hspace=20 vspace=20 >

## Implementation
### Main Screen 
This screen will show all favorited games that you already selected.

<p align="center">
<img src="https://github.com/bremengnaht/SteamFeeds/blob/main/Demo%20Images/IMG_8929.PNG" alt="alt text" width="390" height="844" hspace=20 vspace=20> -> <img src="https://github.com/bremengnaht/SteamFeeds/blob/main/Demo%20Images/IMG_8932.PNG" alt="alt text" width="390" height="844" hspace=20 vspace=20>
</p>

### Find and add new game screen
User can type the name of game on Search bar then App will filter from Core data. And then User can select to make favorite that selected app.

<p align="center">
<img src="https://github.com/bremengnaht/SteamFeeds/blob/main/Demo%20Images/IMG_8930.PNG" alt="alt text" width="390" height="844" hspace=20 vspace=20> -> <img src="https://github.com/bremengnaht/SteamFeeds/blob/main/Demo%20Images/IMG_8931.PNG" alt="alt text" width="390" height="844" hspace=20 vspace=20>
</p>

### News screen
In this screen, the app will show all the news that already fetched before and call Steam API to check and get the latest News from server. They will be appended to the core data if they are not exist. User can refresh or scroll to the bottom to get more news from server.

<p align="center">
<img src="https://github.com/bremengnaht/SteamFeeds/blob/main/Demo%20Images/IMG_8933.PNG" alt="alt text" width="390" height="844" hspace=20 vspace=20 >
</p>

### View news detail screen
The content of fetched news will be display in this screen by WebKit framework by translate from Unicode format to HTML. If user want to see the full version of this News in original source, they can click on Arrow Up button on Navigation bar to open SFSafariViewController

<p align="center">
<img src="https://github.com/bremengnaht/SteamFeeds/blob/main/Demo%20Images/IMG_8934.PNG" alt="alt text" width="390" height="844" hspace=20 vspace=20> -> <img src="https://github.com/bremengnaht/SteamFeeds/blob/main/Demo%20Images/IMG_8935.jpeg" alt="alt text" width="390" height="844" hspace=20 vspace=20>
</p>

## Frameworks
UIKit, Core Data, WebKit, SafariServices
