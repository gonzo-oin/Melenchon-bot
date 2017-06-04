//
//  Caption.swift
//  Melenchon_bot
//
//  Created by Géraud Vercasson on 04/06/2017.
//
//

import Foundation

class Caption {
    
    let id: String
    let subtitles : [Subtitle]
    let videoId: String
	var videoUrl: String { get {
		return "https://www.youtube.com/watch?v=" + videoId
		}
	}
	
    init?(id: String, subtitleRaw: String, videoId: String) {
        
        subtitles = Caption.extractSubtitles(subtitleRaw)
        self.id = id
        self.videoId = videoId
        if subtitles.isEmpty {return nil}
    }
    
    private static func extractSubtitles(_ subtitleRaw: String) -> [Subtitle] {
        
        
        let lines = subtitleRaw.components(separatedBy: "\n")
        var i = 0
        var lastIndex = 0
        var result = Array<Subtitle>()
        
        for line in lines {
            
            if line == "" {
                
                guard let id = lines.getOrNil(index: lastIndex) else { return result}
                
                guard let time = lines.getOrNil(index: lastIndex+1) else {return result}
                guard let startDate = time.components(separatedBy: " --> ").first, let endDate = time.components(separatedBy: " --> ").last else {return result}
            
                
                let text = lines[(lastIndex + 2)..<min(i, lines.count)]
                
                let subtitle = Subtitle(id: id, startDate: startDate, endDate: endDate, text: text.reduce("") { input, txt in
                    
                    input + " " + txt
                    
                })
                
                lastIndex = i+1
                result.append(subtitle)
                
            }
            
            
            i = i + 1
        }
        
        return result
        
    }
    
    public func countOfWord(_ word: String) -> Int{
        
        var count = 0
        
        for subtitle in subtitles {
            
            if subtitle.text.lowercased().contains(word.lowercased()){
                
                let wordInText = subtitle.text.components(separatedBy: word).count - 1
                
                count = count + wordInText
                
            }
            
        }
        return count

        
    }
    
    public func subtitlesWithWord (word: String) -> [Subtitle] {
    
        return subtitles.filter { (subtitle) -> Bool in
            subtitle.text.lowercased().contains(word.lowercased())
        }.sorted(by: { (subtitle1, subtitle2) -> Bool in
			(subtitle1.text.components(separatedBy: word).count - 1) > (subtitle2.text.components(separatedBy: word).count - 1)
		})
    }
    
}

class Subtitle {
	
    let id: String
    let startDate: String
    let endDate: String
    let text: String
	var youtubeStartTime: String { get {
			return startDate.substring(fromPosition: 3, toPosition: 4)! + "m" + startDate.substring(fromPosition: 6, toPosition: 7)!  + "s"
		}
	}
	var hour: String { get {
		return startDate.substring(fromPosition: 0, toPosition: 1)!
		}
	}
	var minute: String { get {
		return startDate.substring(fromPosition: 3, toPosition: 4)!
		}
	}
	var second: String { get {
		return startDate.substring(fromPosition: 6, toPosition: 7)!
		}
	}
    init (id: String, startDate:String, endDate:String, text: String) {
        
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.text = text
        
        
    }
}
