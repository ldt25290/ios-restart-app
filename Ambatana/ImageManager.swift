//
//  ImageManager.swift
//  Ambatana
//
//  Created by Nacho on 19/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

// private singleton instance
private let _singletonInstance = ImageManager()

// constants
private let maxImageCacheSize = 104857600.0 // 100 MB

/**
 * The ImageManager class is in charge of retrieving and caching images from URLs.
 * It implements a really simple internal cache.
 * ImageManager follows the Singleton design scheme, so it must be accessed by means of the sharedInstance class property.
 */
class ImageManager: NSObject {
    
    // data
    var imageCache: [String:UIImage] = [:]
    var currentCacheSize = 0.0
    
    /** Shared instance */
    class var sharedInstance: ImageManager {
        return _singletonInstance
    }
    
    /** Asynchronously retrieves a image from a URL. If the image is in the cache, it retrieves if from the cache first */
    func retrieveImageFromURLString(urlString: String, completion: (success: Bool, image: UIImage?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            // try the cache first
            if let cachedImage = self.imageCache[urlString] {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(success: true, image: cachedImage)
                })
            }
            // if the image is not in the cache, retrieve it.
            else {
                if let url = NSURL(string: urlString) {
                    if let imageData = NSData(contentsOfURL: url) {
                        // generate the image
                        let newImage = UIImage(data: imageData)
                        // store in the cache if enough space.
                        if (self.currentCacheSize + Double(imageData.length)) < maxImageCacheSize {
                            self.currentCacheSize += Double(imageData.length)
                            self.imageCache[urlString] = newImage
                        }
                        // call the completion handler
                        completion(success: true, image: newImage)
                    } else { completion(success: false, image: nil) } // error. Unable to retrieve image.
                } else { completion(success: false, image: nil) } // error, malformed URL.
            }
        })
    }
 
    // clears the cache
    func clearCache() {
        imageCache = [:]
        currentCacheSize = 0.0
    }
}
