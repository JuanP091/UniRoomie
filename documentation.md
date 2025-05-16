Document Contents: meetings, decisions, issues, updated weekly.   
Google doc: [documentation \- Google Docs](https://docs.google.com/document/d/1Cs257VNccyX2ZphY6zYQAztMfx5LTOyhZOp391XJClg/edit?tab=t.0)

week 1(Jan.21-26)  
- Heald meeting to brainstorm ideas for our app  
- Agreed upon a name  
- Created a github  
- Decided we would want to publish on apple store   
- Decided on language “Swift” for ios  
- Decided to use “firebase” for our database.   
- Decided weekly meeting times would be 11:30  
- Decided to use jira to organise our project. 

Week 2(Jan. 27 \- Feb. 2\)  
- Heald meeting with Advisor. Tasks given: make a list of any features we would like to implement, assign roles to group mates(“who is responsible for what”), decide 3- 5 priority features.   
- Issue: Some groupmates did not have machines that run ios, thus could not comfortably program in swift, code had syntax errors as result, unsure if pushing would result in error as those teammates were using xcode instead of vscode. The Hackintosh emulator was suggested for them to use by our advisor.   
- Researched how to implement a map, concluded we may need an Api, like google maps.  
- Issue: First repo was compromised(Errors with database, pushed something incorrect) group decided it was early enough to simply begin again.  
- New repository was created on github, teemates added.    
- Made a database  
- Errors connecting to the database were resolved.   
- Create account screen pushed and visible, not functional  
- login view for return user was worked on, as well as researching hoe to write data to our database   
- Sign in feature now functional and linked to database(when user made they are added to  the database)  
- Decided to switch to flutter and vscode, abandoning ios and deciding to make it an android app, since it would be easier for all members to contribute from now on. 

Week 3(Feb.3 \- 7\)  
- Held a meeting to discuss features on the feature document, and came to a consensus that everyone would do something they’re comfortable with, rather than roles. We also discussed the color pallet for the app and the mascot.   
- Created feature document([UniRoomie Features](https://docs.google.com/document/d/1vobQ22JyAnm2-GWVllllg-p0cxPhBAV0m9cbqDtK7l8/edit?usp=sharing)).  
- Held meeting with advisor: We were given the task to assign roles but more of roles for the process to really for who does what. We were also asked to set due dates for ourselves.   
- Decided to add due date to tasks on jira for creating account/log in features by February 27\.   
- issues running android emulator, resolved by setting up flutter correctly.   
- Issue: One member received an error from the repository; “error downloading the database file”   
- Problem was resolved by naming said file "google-services.json," then adding it into the repo under android/app. The file was also put into a git ignore folder to not cause issues. Database was accessible.   
- made sure we were all using the same versions of java, flutter, and dart.   
- Now using flutter, “create account” page was created, and functional, taking the user to the create account page.

Week 4(Feb.10 \- 16\)  
- no meeting, our group simply discussed weekly progress.   
- added to “account decoration” feature, users can now select gender, university, major, if they are a night owl or a morning person, and if they are more extroverted or introverted(party animal or book worm)  
- merged our work on repo and made a “main” branch  
- Logo created(an owl, orange colors like Utrgv, and a scholar with blue colors)  
- Decided on the Owl with the UTRGV collie scheme.   
- Create account screen updated: background is now orange, and mascot is now on top of  the page. When the user fills in all boxes, our “create account” button will light up blue indicating it can be pressed now.   
- Protection added to the main branch to check if what is being pushed will conflict with the main branch. 

Week 5(Feb.17 \- 23\)  
- Tasks focussed on: perfecting the login page and the ability to recover account, updating the UI to implement our logo.   
- Held meeting with advisor, a suggestion was made to add an api for a database with university names for the university field.  
- Roles redefined as follows: Juan(Keeping everyone updated/on track), Oscar(presentation and schedule updating), Erick( in charge of documentation), Logan(in charge of repository)  
- separate branch created to work solely on UI and not interfere with other work.  
- UI for decoration screen completed.   
- Issue: Gender and university are required fields in the decoration page, nothing tells the3 user that.   
- solution: added red asterisk to words above text boxes to indicate they are required.   
- Added a button at the very top left that will take the user back to login page on the the create account page.   
- login feature updated  
- account recovery back end worked on.

Week 6(Feb.24 \- Mar.2)  
- Held a meeting with group members and discussed: making our code “Beautiful code”, as parts of it are repetitive; if we have time in our projects schedule. Discussed routes in code. Decided to push back end before front end to minimise potential errors and confusion.   
- Decided to start working on the feature to view others on the app, wanting to implement a swipe feature, and roommate chatting.   
- decided to get started on the poster board presentation dedicating time for it.   
- I’m working on the login feature i'll get it done by today if not tomorrow

Week 7(Mar.4 \- 9\)  
- Met with advisor and were told we should recommend profiles to a user based on location; using a zip code api
- Discussed amongst group members: how we wanted to tackle matchmaking in the app, we decided on a swipe feature. Weather pictures of the users would be required, we decided to make it optional. 
- link documentation sheet added to repo, along with text.
- main branch updated, app now lets a user login and view their profile. 

Week 8(Mar.10 - 16)
- No meeting
- Decided We needed mockup for how the swipe features would look 
- Progress made on adding the zip code api
- Worked on adding the swiping feature
- Started the poster board for the presentation(https://utrgv-my.sharepoint.com/:p:/g/personal/oscar_juarez03_utrgv_edu/EUp478kLpPdJrVAAeUHR4I8BIx91kKZfizkK3gnYN4LL-A?e=o3zhLL). 

Week 9(Mar.17 - 23)
Spring break
- No meeting
- Focus on presentation demo, and poster

Week 10(Mar.24 - 30)
- Held Meeting; our advisor approved our poster, Gave the idea that the apps color scheme should change depending on each universities distinked colors. 
- zip code api working
- Printed poster at University library 
- Demo ready for presentation
- Discussed adding things like leaving the zip code feature in the demo if we finish it before the presentation, and making demo student accounts, if time permits.  
- Issue discovered: we have a limited number of api calls(used to create accounts and show profiles)  10 an hour or so. Solution: while in development, just wait it out, this will slow us down but not to a great degree. 

Week 11(Mar.31- April.6)
- PR for swiping feature made
- Discussed chat feature

Week 12(April.7 - 13)
- meeting with advisor and all groups, to present how projects are coming along so far. 
- Began work on the creating matches in app, 
- worked on the feature to show profiles.

Week 13(April.14 - 20 )
- updated location services, whole group added api key for geocoding
- added ability to view profiles to swipe screen
- Discussed how to appeach welcome page ui

Week 14(April.21 - 27)
- UI for swiping page and welcome screens made
- Discussed weather feature for adding pictures should be added to the account decoration page.
- match list button added to welcome screen
- chat feature stores messages, doesnt automatically show new messages in chat.

Week 15(April.28 - May.4)
- Discussed what to focus on for the wrap up of the semester, and key points of presentation, as well as deciding on the date. 
- swipe feature updated users can now like each other.
- issue: swipe feature worked on, on outdated branch, fixed by redoing, adding missing logic. 
- issue: firestore rules changed for swiping feature, no when the user logs in they get a message stating they don't have permission, fixed by returning rules to previous state. 
- user now notified when a match happens, instead of just updating database, generic message” 
- matches are automatic, matching algorithm discussed. 
- chat feature finished, along with list of matches. 

Week 16(May.5 - 11)
- Finished powerpoint for final presentation, reviewed it. 
- Issue: with chat pr, conflicts with swiping feature, fixed swipe feature updated. 
- Swipe screen automatic match fixed, shown users with similar profiles. 
- matches made with automatic matches, removed from database.
- added remove chat feature in match list screen
- presented app in engineering building, got more feedback from students.
- notifications feature added using queued messages. 
- ui for match list and chat screen finished

Week 17(May.12 -18)
- Databases cleared of testing accounts and testing messages. 
- held another meeting to do a practice presentation and demo. 
- updated chat screen ui to show profile of the person user is chatting with. 
- view profile and welcome screen ui updated. 



