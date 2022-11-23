//
//  Homemodel.swift
//  ImageUpload
//
//  Created by coder on 03.05.21.
//  Copyright © 2021 coder. All rights reserved.
//

import UIKit

protocol HomeModelDelegate {
    func itemsDownloaded(webmeals: [WebMeal])
}

class HomeModel {
    
    var delegate: HomeModelDelegate?
    
    func getItems() {
        
        //Hit web service url
        /*
        let serviceUrl = "https://www.wambutt.de/mobileapp/mysql/readUserTable.php"
        // Download the json data
        
        let url = URL(string: serviceUrl)
        if let url = url {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url, completionHandler: { (data, response, error)
        */
        
        var request = URLRequest(url: URL(string: "https://www.wambutt.de/mobileapp/mysql/readUserTable.php")! as URL)
        request.httpMethod = "POST"
        
        let postString = "a=\(selectUser.username)"
        
        // encoding the textvalues in utf8
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Session to share values and get the response
        
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        {data, response, error in
                if error == nil {
                    //succeeded
                    // Call the parse json function on the data
               /* if let data = data {
                        DispatchQueue.main.async { // Correct
                     */
                     self.parseJson(data!)
                    }
                else {
                    //error occured
                    
                }
                // Start zthe task
               
            }
        task.resume()
            
        }


        // Notify the view controller annd pass the data back

    func parseJson(_ data: Data) {
        
        var mealArray = [WebMeal]()
        
         //Parse it out into the meals structure
        do {
            let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as! [Any]
            
            for jsonResult in jsonArray {
                
                let jsonDict = jsonResult as! [String: String]
                
                let webmeals = WebMeal(name: jsonDict["name"]!,
                                photo: jsonDict["photo"]!,
                lessonsLearned: jsonDict["lessonsLearned"]!,
                                rating: jsonDict["rating"]!,
                                updated: jsonDict["updated"]!)
                
                
                mealArray.append(webmeals)
            }
            //ToDo: Pass the meals array back to the daelegate
            
            delegate?.itemsDownloaded(webmeals: mealArray)
           
        }
        catch {
            print("There was an error")
        }
        
        
    }

}
