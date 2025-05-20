# SwiftRPC

[![GitHub Release](https://img.shields.io/github/v/release/darwinx64/SwiftRPC?include_prereleases)](https://github.com/darwinx64/SwiftRPC/releases)
[![GitHub Licence](https://img.shields.io/github/license/darwinx64/SwiftRPC)](https://github.com/darwinx64/SwiftRPC/blob/master/LICENCE)

A Swift package to interface with Discord's IPC sockets and display a rich presence activity.

## Usage
### Xcode project
Navigator > Project Name > *Add Package Dependencies...* > Add [SwiftRPC](https://github.com/darwinx64/SwiftRPC/).
### Swift package
Add SwiftRPC to your package's dependencies.
```swift
.package(url: "https://github.com/darwinx64/SwiftRPC.git", branch: "master")
```

## Example

```swift
import SwiftRPC
import AppKit

class PresenceDelegate: RichPresenceDelegate {

	/// A RichPresence instance that will get info
	/// from this delegate's methods.
	var rpc: RichPresence? = nil

	/// Make an `Activity` with a few of `Activity`'s
	/// overloads. There are more, such as `timestamps`
	static func makeActivity() -> Activity {
		Activity(
			details: "Working in a project",
			state: "In a file",
			assets: .init(
				largeImage: "appIcon"
			)
		)
	}

	/// Override default error handling with our own
	/// In this case, safely recover from any error
	///
	/// You can do things such as notify UI changes
	/// here, to tell the user something went wrong,
	/// or handle different errors differently
	override func richPresence(responseTo error: any Error) {
		print(error)
		self.rpc?.stop()
		do {
			try self.rpc?.start()
		} catch {
			richPresence(responseTo: error)
		}
	}
	
	required init() {
		super.init(id: "1234567890987654321", activity: Self.makeActivity())
		self.rpc = .init(delegate: self)
		do {
			try self.rpc?.start()
		} catch {
			richPresence(responseTo: error)
		}
	}
}
```
