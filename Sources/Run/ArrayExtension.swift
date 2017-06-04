//
//  ArrayExtension.swift
//  Melenchon_bot
//
//  Created by Géraud Vercasson on 04/06/2017.
//
//

import Foundation


extension Array {
    
    func getOrNil(index: Int) -> Element? {
        
        if index >= 0 && index < count {
            
            return self[index]
        }
        
        return nil
        }
    }



