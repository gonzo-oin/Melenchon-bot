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
let Client_id = "<client_id>"
let Client_secret = "<client_secret>"
let Refresh_token = "<refresh_token>"
let API_Key = "<API_key>"
let Tmft = "srt"
var Access_token = "<Access Token>"

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
											"tmft":Tmft],
		                                   ["authorization":"Bearer " + Access_token])
		
		if let bodyBytes = response.body.bytes, let captionString = String(bytes: bodyBytes, encoding: .utf8) {
			print("captionString:\n" + captionString)
			return captionString
		}
		
	} catch {
		// will print error catched in try calls
		print(error)
	}
	return nil
}


// Call methods
if let newToken = refreshToken() {
	Access_token = newToken

	let captionString = getCaption(id: "nR2uYc0Woj92voYRsp_FapLspS9Bmvxq")
}

// Start HTTP Server with no routes
try drop.run()
