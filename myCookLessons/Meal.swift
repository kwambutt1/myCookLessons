//
//  Meal.swift
//  TestmultiView
//
//  Created by coder on 29.12.20.
//  Copyright © 2020 coder. All rights reserved.
//

import UIKit
import os.log

class Meal: NSObject, NSCoding {
    
// MARK: Properties

    var name: String
    var photo: String
    var rating: Int
    var lessonsLearned: String
    
    //Mark: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
    
    
    
    //MARK: Types
    
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let rating = "rating"
        static let lessonsLearned = "lessonsLearned"
    }

//MARK: Initialization

    init? (name: String, photo: String, rating: Int, lessonsLearned: String ) {
    
// The name must not be empty
    
    guard !name.isEmpty else {
        return nil
    }
    
// The rating must be between 0 and 5 inclusively
    
    guard (rating >= 0) && (rating <= 5) else {
        return nil
    }
    
// Initialize stored properties.
    
    self.name = name
    self.photo = photo
    self.rating = rating
    self.lessonsLearned = lessonsLearned
    
                                                        }

    //Mark: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(rating, forKey: PropertyKey.rating)
        aCoder.encode(lessonsLearned, forKey: PropertyKey.lessonsLearned)    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        //The name is requiered. If we cannot decode a name string, the initializer should fail.
        
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        //Because photo is an optional property of Meal, just use conditional cast.
        
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? String ?? ""
        
        let rating = aDecoder.decodeInteger(forKey: PropertyKey.rating)
        
        let lessonsLearned = aDecoder.decodeObject(forKey: PropertyKey.lessonsLearned) as? String ?? ""
        
        //Must call designated initializer
        
        self.init(name: name, photo: photo, rating: rating, lessonsLearned: lessonsLearned)
    }
            }
