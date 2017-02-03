//
//  OrderedContent.swift
//  Rutgers
//
//  Created by cfw37 on 2/1/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import Unbox

struct Channel {
    let handle : String
    let title : Title
    let icon : String
    let view : String
    let api : String?
    let url : String?
    let grouped : Bool?
}

enum Title {
    case constant(title: String)
    case variable(homeCapus: String, homeTitle: String, foreignTitle: String)
}

extension Channel: Unboxable {
    init(unboxer: Unboxer) throws {
        self.handle = try unboxer.unbox(key: "handle")
        do {
            let title = try unboxer.unbox(key: "title") as String
            
            self.title = .constant(title: title)
        } catch {
            let homeCampus = try unboxer.unbox(keyPath: "title.homeCampus") as String
            let homeTitle = try unboxer.unbox(keyPath: "title.homeTitle") as String
            let foreignTitle = try unboxer.unbox(keyPath: "title.foreignTitle") as String
            
            self.title = .variable(homeCapus: homeCampus, homeTitle: homeTitle, foreignTitle: foreignTitle)
        
        }
        self.icon = try unboxer.unbox(key: "icon")
        self.view = try unboxer.unbox(key: "view")
        self.api = try? unboxer.unbox(key: "api")
        self.url = try? unboxer.unbox(key: "url")
        self.grouped = try? unboxer.unbox(key: "grouped")
        
    }
}



