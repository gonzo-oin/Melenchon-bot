import Foundation
import App
import HTTP

/// We have isolated all of our App's logic into
/// the App module because it makes our app
/// more testable.
///
/// In general, the executable portion of our App
/// shouldn't include much more code than is presented
/// here.
///
/// We simply initialize our Droplet, optionally
/// passing in values if necessary
/// Then, we pass it to our App's setup function
/// this should setup all the routes and special
/// features of our app
///
/// .run() runs the Droplet's commands,
/// if no command is given, it will default to "serve"

// Declaring vars

let tfmt = "srt"


// Instantiate a Drop
let config = try Config()
try config.setup()
let drop = try Droplet(config)



// Declaring Methods
func refreshToken() -> String? {
	do {
		let response = try drop.client.post("https://www.googleapis.com/oauth2/v4/token",
		                                    query: [
												"client_id": Client_id,
												"grant_type": "refresh_token",
												"client_secret": Client_secret,
												"refresh_token": Refresh_token],
		                                    ["Content-Type":" application/x-www-form-urlencoded"])
		
		if let bodyBytes = response.body.bytes, let json = try? JSON(bytes: bodyBytes) {
			
			print("new access token:" + json["access_token"]!.string!)
			return json["access_token"]!.string!
		}
	} catch {
		// will print error catched in try calls
		print(error)
	}
	
	return nil
}

func getCaption(id: String) -> String? {
	do {
		let response = try drop.client.get("https://www.googleapis.com/youtube/v3/captions/" + id,
		                                   query: [
											"key": API_Key,
											"tfmt":tfmt],
		                                   ["authorization":"Bearer " + Access_token])
		
		if let bodyBytes = response.body.bytes, let captionString = String(bytes: bodyBytes, encoding: .utf8) {
			
			return captionString
		}
		
	} catch {
		// will print error catched in try calls
		print(error)
	}
	return nil
}


func getCaptionIds(videoId: String) -> [String]? {
	do {
		let response = try drop.client.get("https://www.googleapis.com/youtube/v3/captions/",
		                                   query: [
											"videoId":videoId,
											"part":"id",
											"key": API_Key,
											],
		                                   ["authorization":"Bearer " + Access_token])
		
		if let bodyBytes = response.body.bytes, let json = try? JSON(bytes: bodyBytes) {
			
			return json["items"]?.array?
				.filter{ $0["id"]?.string != nil }
				.map{ ($0["id"]?.string)! }        }
		
	} catch {
		// will print error catched in try calls
		print(error)
	}
	return nil
}

func getVideoIds(search: String) -> [String]? {
	do {
		let response = try drop.client.get("https://www.googleapis.com/youtube/v3/search",
		                                   query: [
											"q":search,
											"part":"snippet",
											"key": API_Key,
											"maxResults":"5",
											"type":"video",
											"videoCaption":"closedCaption"
			])
		
		if let bodyBytes = response.body.bytes, let json = try? JSON(bytes: bodyBytes) {
			
			return json["items"]?.array?
				.filter{ $0["id"]?.object?["videoId"]?.string != nil }
				.map{ ($0["id"]?.object?["videoId"]?.string)! }
		}
		
	} catch {
		// will print error catched in try calls
		print(error)
	}
	return nil
}


func getGfyCatToken() -> String? {
	do {
		let myJSON = try JSON(node:["grant_type":"client_credentials", "client_id":gfyCatClientId, "client_secret": gfyCatClientSecret])
		let response = try drop.client.post("https://api.gfycat.com/v1/oauth/token", ["": ""], myJSON)
		if let bodyBytes = response.body.bytes, let json = try? JSON(bytes: bodyBytes) {
			return json["access_token"]?.string
		}
		
	} catch {
		// will print error catched in try calls
		print(error)
	}
	return nil
}

func createGifyMeme(gfyToken: String, startSecond: String, startMinute: String, startHour: String, captionText: String, videoURL: String) -> String? {
	do {
		let startSeconds = Int(startSecond)! + Int(startMinute)! * 60 + Int(startHour)! * 3600

		let myJSON = try JSON(node: [
			"private": true,
			"captions": [
				[
					"text": captionText.folding(options: .diacriticInsensitive, locale: .current),
					"fontHeight" : 35,
				]
			],
			"cut" : [
				"duration" : 5,
				"start" : startSeconds
			],
			"fetchUrl": videoURL,
			])

		let response = try drop.client.post("https://api.gfycat.com/v1/gfycats",
		                                    query: [:],
		                                    ["Authorization" : "Bearer " + gfyToken, "Content-Type" : "application/json"],
		                                    myJSON)
		
		if let bodyBytes = response.body.bytes, let json = try? JSON(bytes: bodyBytes) {
			return json["gfyname"]?.string
		}
		
	} catch {
		// will print error catched in try calls
		print(error)
	}
	return nil
}

func getStatus(gfyToken: String, gfycatId: String) -> String? {
	do {
		let response = try drop.client.get("https://api.gfycat.com/v1/gfycats/fetch/status/" + gfycatId,
		                                    query: [:], ["Authorization" : "Bearer " + gfyToken, "Content-Type" : "application/json"])
		
		if let bodyBytes = response.body.bytes, let json = try? JSON(bytes: bodyBytes) {
			return json["task"]?.string
		}
		
	} catch {
		// will print error catched in try calls
		print(error)
	}
	return nil
}

let queue = DispatchQueue(label: "bot.queue")

func tryUntilIsComplete(gfyToken: String, gfycatId: String) {
	queue.asyncAfter(deadline: .now() + 10) {
		if let status = getStatus(gfyToken: gfyToken, gfycatId: gfycatId) {
			if status == "complete" {
				print("\n\n\n🎁🎁🎁\nhttp://gfycat.com/\(gfycatId)\n🎁🎁🎁\n\n\n")
				print("\n\n\n🎁🎁🎁\nhttps://thumbs.gfycat.com/\(gfycatId)-size_restricted.gif\n🎁🎁🎁\n\n\n")
				
			} else if status == "encoding" {
				print("\n😒 video is encoding\n")
				tryUntilIsComplete(gfyToken: gfyToken, gfycatId: gfycatId)
			} else {
				print("\n\n💥 There is no video !\n\n")

			}
		}
	}
}

// Call methods
if let newToken = refreshToken() {
	Access_token = newToken
	let searchedText = "climat"
	var bestCaptions = [Caption]()
	if let videoIdArray = getVideoIds(search: "mélenchon " + searchedText){
		
		videoIdArray.forEach({ (my_videoId) in
			
			
			if let captionIds = getCaptionIds(videoId: my_videoId){
				
				captionIds.forEach{ (captionId) in
					
					if let captionString = getCaption(id: captionId) {
						
						if let caption = Caption(id: captionId, subtitleRaw: captionString, videoId: my_videoId){
							
							bestCaptions.append(caption)
							
							print (caption.countOfWord(searchedText))
						}
					}
				}
			}
		})
	}
	
	bestCaptions = bestCaptions.sorted(by: { (caption1, caption2) -> Bool in
		caption1.countOfWord(searchedText) > caption2.countOfWord(searchedText)
	})
	
	for bestCaption in bestCaptions {
		for bestSubtile in bestCaption.subtitlesWithWord(word: searchedText) {
			print(bestSubtile.text)
			print(bestCaption.videoUrl + "&t=" + bestSubtile.youtubeStartTime)
			
		}
	}
	
	// Create MEME for first Captions 
	let randomIndex = Int(arc4random_uniform(UInt32(bestCaptions.count)))
	let bestCaption = bestCaptions[randomIndex]
	let bestSubtile = bestCaption.subtitlesWithWord(word: searchedText).first!
	if let gfyToken = getGfyCatToken() {
		if let memeName = createGifyMeme(gfyToken: gfyToken, startSecond: bestSubtile.second, startMinute: bestSubtile.minute, startHour: bestSubtile.hour, captionText: bestSubtile.text, videoURL: bestCaption.videoUrl) {
			print("\n\n\n ✋ Meme will be ready soon ✋ http://gfycat.com/\(memeName)\n\n\n")
			tryUntilIsComplete(gfyToken: gfyToken, gfycatId: memeName)
		}
	}

}


// Start HTTP Server with no routes
try drop.run()


