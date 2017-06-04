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


let config = try Config()
try config.setup()

let Client_id = "<client_id>"
let Client_secret = "<client_secret>"
let Refresh_token = "<refresh_token>"
let API_Key = "<API_key>"
let Tmft = "srt"
var Access_token = "<Access Token>"
let drop = try Droplet(config)

let Token_refresh = try Droplet(config)

let test = try Droplet(config)



drop.get("/Token_refresh") { _ in

    return try Token_refresh.client.post("https://www.googleapis.com/oauth2/v4/token", query: ["client_id":Client_id,"grant_type":"refresh_token","client_secret":Client_secret, "refresh_token":Refresh_token],["Content-Type":"application/x-www-form-urlencoded"])
    
}

drop.get("/hello") { _ in
    return "Hello Vapor"
}

drop.get("/test") { _ in
    
    return try test.client.get("https://www.googleapis.com/youtube/v3/captions/nR2uYc0Woj92voYRsp_FapLspS9Bmvxq", query: ["key": API_Key,"tmft":Tmft], ["authorization":"Bearer "+Access_token])
   }

try drop.run()
