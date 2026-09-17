# Postboard - starter project

Open `Postboard.xcodeproj` and run it. It builds and launches, and shows an alert saying
*"fetchPosts is not written yet"*. That is where you start.

Needs Xcode 16 or later. No CocoaPods, no packages, no API key.

## First, open these in your browser

Look at the real responses before you write any Swift. Change the numbers in the address bar and
press Enter.

| What | URL |
|---|---|
| All 100 posts | <https://jsonplaceholder.typicode.com/posts> |
| First ten | <https://jsonplaceholder.typicode.com/posts?_page=1&_limit=10> |
| Next ten | <https://jsonplaceholder.typicode.com/posts?_page=2&_limit=10> |
| Five at a time | <https://jsonplaceholder.typicode.com/posts?_page=1&_limit=5> |
| One post | <https://jsonplaceholder.typicode.com/posts/1> |
| One that does not exist (404) | <https://jsonplaceholder.typicode.com/posts/99999> |
| Nested JSON (stretch task) | <https://jsonplaceholder.typicode.com/users/1> |

Three things to notice:

1. Posts have `"userId"`, not `authorID`. That is Task 1.
2. Page 1 gives ids 1-10, page 2 gives ids 11-20. Nothing in the body says there are 100 posts.
3. That total arrives in a response **header**, `X-Total-Count`. To see it, press F12, open the
   Network tab, reload, click the request and look under Response Headers.

The same list is in the comments at the top of `PostService.swift`.

## What is already written

Everything in `Postboard/App/` - the whole user interface is one file. You will not write any
UIKit code.

| File | What it is |
|---|---|
| `MainViewController.swift` | The only screen: download bar, list, log |
| `EventLog.swift` | A log that survives the app being killed |
| `AppDelegate` / `SceneDelegate` | App setup (one method in `AppDelegate` is part of Task 5) |
| `PostboardTests/FakeServer.swift` | A fake server for your tests |

## What you write

Five files, all with `TODO` comments telling you what is expected.

| File | Task |
|---|---|
| `Networking/Models.swift` | 1 - `CodingKeys` (and 7, the stretch) |
| `Networking/PostService.swift` | 2, 3, 4 - the GET, pagination and the POST |
| `Networking/BackgroundDownloader.swift` | 5 - the session, `startDownload()`, `urlSessionDidFinishEvents` |
| `App/AppDelegate.swift` | 5 - `handleEventsForBackgroundURLSession` only |
| `PostboardTests/PostServiceTests.swift` | 6 - unit tests |

`Networking/APIError.swift` is already complete. Read it - your job in Task 2 is to throw the
right case, not to write the type.

## Testing the background download (Task 5)

The file is 100 MB on purpose: a small one finishes before you can background the app.

1. Tap **Download 100 MB file**.
2. Press Cmd-Shift-H within a second or two to background the app.
3. Wait, then reopen it. The progress should have moved on.
4. The real test: start it again, background it, then press **Stop** in Xcode to kill the app.
   Launch it again from the home screen.
5. Look at the log at the bottom of the screen. `large.dat` should be listed under Documents, and
   you should see `handleEventsForBackgroundURLSession`, `didFinishDownloadingTo` and
   `urlSessionDidFinishEvents`.

Step 4 works on the simulator - you do not need a device.

Killing the app from Xcode is **not** the same as swiping it away in the app switcher. A user
force-quit cancels background transfers on purpose, and there is no way around that.

## Why the log exists

By the time the system relaunches your app, the Xcode console is gone, so `print()` output is
lost. `EventLog` writes to `UserDefaults` and the screen shows it. If it is not in the log, you
cannot prove it ran.
