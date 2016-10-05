//
//  RUMenuItemManager.swift
//  Rutgers
//
//  Created by Open Systems Solutions on 6/7/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//



import Foundation





protocol DictionaryConvertible {
    init?(dictionary: NSDictionary)
    func asDictionary() -> NSDictionary
}

;
public class RUFavorite: NSObject
{
    public let title: String
    public let url: NSURL
    
    public init(title: String, url: NSURL)
    {
        self.title = title
        self.url = url
    }
   
    /*
         Equality for objc objects :
         If two things are equal then there hashes must be equal : but two hashes being equal does not mean that the objects are equal
     
      */
    
    public override func isEqual(object: AnyObject?) -> Bool
    {
        guard let other = object as? RUFavorite else { return false }
        return self.title == other.title && self.url == other.url
    }
    
    public override var hash: Int {
        return title.hashValue &+ url.hashValue
    }
}

extension RUFavorite {
    public convenience init?(dictionary: NSDictionary) {
        guard let title = dictionary["title"] as? String,
            urlString = dictionary["url"] as? String,
            url = NSURL(string: urlString) else { return nil }
        
        self.init(title: title, url: url)
    }
    
    public func asDictionary() -> NSDictionary {
        
        
        
        return [
            "title": title,
            "url": RUGetAbsoluteString(url)
        ]
    }
}

extension RUFavorite {
    public var channelHandle: String? {
        /*
        let handle : String = url.absoluteString.stringByReplacingOccurrencesOfString("http://rumobile.rutgers.edu/link/", withString: "");
        var arr = handle.componentsSeparatedByString("/");
        return arr[0];
          */
        return url.host
    }
}

private let MenuItemManagerActiveMenuItemsKey = "MenuItemManagerFavoritesKey"
public let MenuItemManagerDidChangeActiveMenuItemsKey = "MenuItemManagerDidChangeActiveMenuItemsKey"

public class RUMenuItemManager: NSObject {
    static let sharedManager = RUMenuItemManager()
    
    public func addFavorite(favorite: RUFavorite) {
        var rawMenuItems = self.rawMenuItems
        let favoriteDict = favorite.asDictionary()
        
        let optionalIndex = rawMenuItems.indexOf { $0.isEqual(favoriteDict) }
        if optionalIndex == nil {
            rawMenuItems.insert(favoriteDict, atIndex: 0)
        }
        
        self.rawMenuItems = rawMenuItems
    }
    
    public func removeFavorite(favorite: RUFavorite) {
        var rawMenuItems = self.rawMenuItems
        
        let favoriteDict = favorite.asDictionary()
        let optionalIndex = rawMenuItems.indexOf { $0.isEqual(favoriteDict) }
        if let index = optionalIndex {
            rawMenuItems.removeAtIndex(index)
        }
        
        self.rawMenuItems = rawMenuItems
    }
    
    private func notifyMenuItemsDidChange() {
        NSNotificationCenter.defaultCenter().postNotificationName(MenuItemManagerDidChangeActiveMenuItemsKey, object: self)
    }
    
    private var rawMenuItems: [AnyObject] {
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: MenuItemManagerActiveMenuItemsKey)
            notifyMenuItemsDidChange()
        }
        get {
            return NSUserDefaults.standardUserDefaults().arrayForKey(MenuItemManagerActiveMenuItemsKey) ?? RUChannelManager.sharedInstance().contentChannels.flatMap { $0.channelHandle }
        }
    }
    
    public var menuItems: [AnyObject] {
        set {
            rawMenuItems = newValue.flatMap { menuItem in
                switch menuItem {
                case let favorite as RUFavorite:
                    return favorite.asDictionary()
                case let channel as NSDictionary:
                    return channel.channelHandle
                default: return nil
                }
            }
        }
        get {
            return rawMenuItems.flatMap { rawMenuItem in
                switch rawMenuItem {
                case let dictionary as NSDictionary:
                    return RUFavorite(dictionary: dictionary)
                case let string as String:
                    return RUChannelManager.sharedInstance().channelWithHandle(string)
                default: return nil
                }
            }
        }
    }
}
