//
//  RUMenuItemManager.swift
//  Rutgers
//
//  Created by Open Systems Solutions on 6/7/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

import Foundation

/*
 
 +(NSArray <NSDictionary *>*)favorites;
 +(void)addFavorite:(NSDictionary *)favorite;
 +(void)removeFavorite:(NSDictionary *)favorite;
 
 */

protocol DictionaryConvertible {
    init?(dictionary: NSDictionary)
    func asDictionary() -> NSDictionary
}

struct VisibleObject {
    var visible: Bool
    var object: AnyObject

    init(visible: Bool, object: AnyObject) {
        self.visible = visible
        self.object = object
    }

    func asDict() -> Dictionary<String, AnyObject> {
        return ["visible": visible as AnyObject, "object": object]
    }

    static func fromDict(dict: Dictionary<String, AnyObject>) -> VisibleObject? {
        return (dict["visible"] as? Bool).flatMap { visible in
            dict["object"].map { VisibleObject(visible: visible, object: $0) }
        }
    }
}

open class RUFavorite: NSObject
{
    open let title: String
    open let url: URL
    
    public init(title: String, url: NSURL)
    {
        self.title = title
        self.url = url as URL
    }

    /*
         Equality for objc objects :
         If two things are equal then there hashes must be equal : but two hashes being equal does not mean that the objects are equal
     
      */
    
    open override func isEqual(_ object: Any?) -> Bool
    {
        guard let other = object as? RUFavorite else { return false }
        return self.title == other.title && self.url == other.url
    }
    
    open override var hash: Int {
        return title.hashValue &+ url.hashValue
    }
}

extension RUFavorite {
    public convenience init?(dictionary: NSDictionary) {
        guard let title = dictionary["title"] as? String,
            let urlString = dictionary["url"] as? String,
            let url = URL(string: urlString) else { return nil }
        
        self.init(title: title, url: url as NSURL)
    }
    
    public func asDictionary() -> NSDictionary {
        return [
            "title": title,
            "url": url.absoluteString
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

open class RUMenuItemManager: NSObject {
    static let sharedManager = RUMenuItemManager()
    
    public func addFavorite(favorite: RUFavorite) {
        var rawMenuItems = self.rawMenuItems
        let favoriteDict = favorite.asDictionary()

        let optionalIndex = rawMenuItems.index { $0.object.isEqual(favoriteDict) }
        if optionalIndex == nil {
            rawMenuItems.insert(VisibleObject(visible: true, object: favoriteDict), at: 0)
        }

        self.rawMenuItems = rawMenuItems
    }
    
    public func removeFavorite(favorite: RUFavorite) {
        var rawMenuItems = self.rawMenuItems
        
        let favoriteDict = favorite.asDictionary()
        let optionalIndex = rawMenuItems.index { $0.object.isEqual(favoriteDict) }
        if let index = optionalIndex {
            rawMenuItems.remove(at: index)
        }
        
        self.rawMenuItems = rawMenuItems
    }
    
    fileprivate func notifyMenuItemsDidChange() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: MenuItemManagerDidChangeActiveMenuItemsKey), object: self)
    }
    
    private var rawMenuItems: [VisibleObject] {
        set {
            UserDefaults.standard.set(newValue.map { $0.asDict() }, forKey: MenuItemManagerActiveMenuItemsKey)
            notifyMenuItemsDidChange()
        }
        get {
            let contentChannels = RUChannelManager.sharedInstance().contentChannels as [AnyObject]
            if let oldDefaults = UserDefaults.standard
                .array(forKey: MenuItemManagerActiveMenuItemsKey)
            {
                // Since we changed storage formats, we need to check to be sure
                // we have things in the new format. Older objects are converted
                let dictDefaults = oldDefaults.filterMap { x -> Dictionary<String, AnyObject>? in
                    if let channel = x as? String {
                        // Old channels are stored as strings
                        // Convert them to visible objects first
                        return VisibleObject(visible: true, object: channel as AnyObject)
                            .asDict()
                    }
                    if let dict = x as? Dictionary<String, AnyObject> {
                        // Old favorites were stored directly as dictionaries
                        // convert them to visible objects
                        if let _ = RUFavorite(dictionary: dict as NSDictionary) {
                            return VisibleObject(visible: true, object: dict as AnyObject)
                                .asDict()
                        }
                        // Leave new dictionaries the same
                        return dict
                    }
                    return nil
                }
                let channelHandles = contentChannels.flatMap { $0.channelHandle }
                let validHandle = { handle in
                    channelHandles.contains { $0 == handle }
                }
                let defaults = dictDefaults.filter {
                    // throw out any values where we have a handle that no
                    // longer exists in ordered_content
                    //
                    // can't do this for favorites because we might be using
                    // ordered content from the bundle, and it would trash links
                    // if it was too old (and didn't have some new handles)
                    //
                    // assume that bad handles will not crash and can be removed
                    // by the user if they don't want them
                    ($0["object"] as? String).map(validHandle) ?? true
                }.filterMap { VisibleObject.fromDict(dict: $0) }

                // get saved channels (no favorites) and make sure they're valid
                let defaultHandles: [String] = defaults.filterMap {
                    // we only store the channel handle, not the whole thing
                    $0.object as? String
                }.filter(validHandle)

                // find contentChannels that are not in our defaults at all
                let newChannels = channelHandles.filter { handle in
                    !defaultHandles.contains { $0 == handle }
                }
                // put those new channels at the top and make them visible
                return newChannels.map {
                    VisibleObject(visible: true, object: $0 as AnyObject)
                } + defaults
            } else {
                // If this is the first launch, just make all channels visible
                return contentChannels.map {
                    VisibleObject(visible: true, object: $0.channelHandle as AnyObject)
                }
            }
        }
    }

    private func rawVisible() -> [VisibleObject] {
        return rawMenuItems.filter { $0.visible }
    }

    private func rawHidden() -> [VisibleObject] {
        return rawMenuItems.filter { !$0.visible }
    }

    private func serializedItem(object: AnyObject) -> AnyObject? {
        switch object {
        case let favorite as RUFavorite:
            return favorite.asDictionary()
        case let channel as NSDictionary:
            return channel.channelHandle as AnyObject?
        default: return nil
        }
    }

    private func fullItem(object: AnyObject) -> AnyObject? {
        switch object {
        case let dictionary as NSDictionary:
            return RUFavorite(dictionary: dictionary)
        case let string as String:
            return RUChannelManager.sharedInstance().channel(withHandle: string) as AnyObject?
        default: return nil
        }
    }

    private func serializeNew(objects: [AnyObject], visible: Bool) -> [VisibleObject] {
        return objects.flatMap(serializedItem).map {
            VisibleObject(visible: visible, object: $0)
        }
    }

    private func deserializeOld(objects: [VisibleObject]) -> [AnyObject] {
        return objects.map { $0.object }.flatMap(fullItem)
    }

    // Use this to atomically set both visible and hidden items at once.
    // Setting them seperately can cause problems because we can't distinguish
    // between items dropped that will be added back to the other list
    // immediately and items that we don't have that are new in ordered_content
    public func updateItems(visible: [AnyObject], hidden: [AnyObject]) {
        rawMenuItems = serializeNew(objects: visible, visible: true) + serializeNew(objects: hidden, visible: false)
    }

    public var menuItems: [AnyObject] {
        set {
            rawMenuItems = serializeNew(objects: newValue, visible: true) + rawHidden()
        }
        get {
            return deserializeOld(objects: rawVisible())
        }
    }

    public var hiddenItems: [AnyObject] {
        set {
            rawMenuItems = rawVisible() + serializeNew(objects: newValue, visible: false)
        }
        get {
            return deserializeOld(objects: rawHidden())
        }
    }
}
