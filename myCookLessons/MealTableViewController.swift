            //
//  MealTableViewController.swift
//  TestmultiView
//
//  Created by coder on 29.12.20.
//  Copyright © 2020 coder. All rights reserved.
//

import UIKit
import os.log

    class MealTableViewController: UITableViewController,URLSessionDataDelegate,  HomeModelDelegate{
               
                
                
                
    
    // MARK: Properties
    
    var meals = [Meal]()
    var filteredMeal: [Meal] = []
    let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    var permission: Bool!
    var webmeals = [WebMeal]()
    var homeModel = HomeModel()
    //var savedMeals: [Meal]?
    var meal: Meal?
    var check: Bool = true
    var name: String?
    var photo: String = ""
    var lessonsLearned: String?
    var rating: Int?
    var action: Bool = false
    var delname: String = ""
    var i: Int = 0
    var newRating: Int = 0
    static var nc = NotificationCenter.default
        
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // Mark: Initialization
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        homeModel.getItems()
        homeModel.delegate = self
        
        
        //Use the edit button item provided by the table view controller
    
        navigationItem.leftBarButtonItem = editButtonItem
        self.navigationItem.leftBarButtonItem?.title = "Delete"
        
        //Load any saved meals, otherwise load sample data.
        
        if let savedMeals = loadMeals() {
            meals += savedMeals
        } // end if
    
        /*  else {
        //Load the sample data
         loadSampleMeals()
         } //end else  */
    
       
        // Configure SearchController
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        /*
        let  appDelegate:AppDelegate = UIApplication.shared.delegate! as! AppDelegate
        appDelegate.MealTableViewControler = self
        */
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
    
    }// end override func viewdidload
        
        deinit {
            NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        }
        @objc fileprivate func willEnterForeground() {
            
            homeModel.getItems()
            homeModel.delegate = self
            if let savedMeals = loadMeals() {
                meals += savedMeals
            } // end if
            
        }// end willEnetrForeground
  
    
        //compareWithWeb()
    
    func  itemsDownloaded(webmeals: [WebMeal]) {
        
        //Initiate webmeals
                
        self.webmeals = webmeals
        
        DispatchQueue.main.async{
            
        // check if there are deleted meals on the web
                
               for eachMeal in self.meals {
                   
                        let a = self.meals.firstIndex(of: eachMeal)
                    
                        for eachWebmeal in webmeals {
                            if eachWebmeal.name.contains("\(eachMeal.name)") {
                            } //end if eachWebmeal.name
                            else {
                                self.action = true
                            }// end else
                        } //end for eachWebmeals in webmeals
        
        // delete meals on phone which are not at the web
                    
                        if self.action == true {
                        self.meals.remove(at: a!)
                        self.saveMeals()
                        }// end if self.action == true
                }// end for eachmeal in self.meals
            
        // check if there are additional meals or updated meals at the web
            
        for eachWebMeal in webmeals {
                       
            self.check = false
                        
            for eachMeal in self.meals {
                        
                if  eachMeal.name == eachWebMeal.name {
            
                self.check = true
                
                    if eachWebMeal.updated.contains("yes"){
                    
                    eachMeal.photo = eachWebMeal.photo
                    eachMeal.lessonsLearned = eachWebMeal.lessonsLearned
                    let ratingString = eachWebMeal.rating
                    eachMeal.rating = Int(ratingString)!
                        print("\(eachMeal.rating)")
                    self.saveMeals()
                        
                    }// end of eachWebMeal.updated
                    }// end of eachMeal
                } // end for eachMeal in self.meals
        
        // if there are new meals at the web create na new meal at the phone
                    
                            if self.check == false {
                            
                                let name = eachWebMeal.name
                                let photo = eachWebMeal.photo
                                let lessonslearned = eachWebMeal.lessonsLearned
                                let ratingString = eachWebMeal.rating
                                let rating = Int(ratingString)
                          
                                self.meal  = Meal(name: name, photo: photo, rating: rating!, lessonsLearned: lessonslearned)
                                self.meals.append(self.meal!)
                                self.saveMeals()
                 
                                print(self.meal!.name)
                                print(photo)
                        
        // download the photo for the new meal
                                
                                let url = URL(string:"https://www.wambutt.de/mobileapp/uploads/\(photo)")!
                            
                                let dataTask = URLSession.shared.downloadTask(with: url) { urlOrNil, responseOrNil, errorOrNil in
                                
                                    guard let fileURL = urlOrNil else {return}
                            
                                    do {
                                        let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                                        let savedURL = documentsURL.appendingPathComponent(photo)
                                        try FileManager.default.moveItem(at: fileURL, to: savedURL)
                                
                                
                                        } catch {
                                            print ("file error: \(error)")
                                
                                        } // end catch
                            
                                } // end data task
                                dataTask.resume()
                            
                            } // end of if self.check == false 
                    
                    }// end fpr echwebwebMail
            
        // delete "yes" in all updated columns at the user table in the web
            
            var request = URLRequest(url: URL(string: "https://www.wambutt.de/mobileapp/mysql/deleteYesInUpdated.php")! as URL)
            request.httpMethod = "POST"
            
            let postString = "e=\(selectUser.username)"
            
            // encoding the textvalues in utf8
            
            request.httpBody = postString.data(using: String.Encoding.utf8)
            
            //Session to share values and get the response
            
            let task = URLSession.shared.dataTask(with: request as URLRequest)
            {data, response, error in
                
                if error != nil {
                    print("error=\(String(describing: error))")
                    return
                }
                print("response = \(String(describing: response))")
                
                let responseString = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                print("responseString = \(String(describing: responseString))")
                
            }// end data task
            task.resume()
            
        // present the new table view
                
                    self.tableView.reloadData()
                    
        }//end Dispatchque.main.async
            
    }//end itemsDownloaded
   
    
  
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
               return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering { return filteredMeal.count}
        return meals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        func getDocumentsDirectory() -> URL {
            let  paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        } // end getDocumentsDirectory
        
        //Table view cells are reused and should be dequeued using a cell identifier
        
        let  cellIdentifier = "MealTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell")
                }
        //Fetches the appropriate meal for the dat source layout.
        
        let  meal: Meal
        
        if isFiltering {
            meal = filteredMeal[indexPath.row]
        } else {
            meal = meals[indexPath.row]
        }
        
        cell.nameLabel.text = meal.name
        let  path = getDocumentsDirectory().appendingPathComponent(meal.photo)
        
        cell.photoImageView.image = UIImage(contentsOfFile: path.path)
        cell.ratingControl.rating  = meal.rating
        
        return cell
    } // end tableView(_ tableView: UITableView, cellForRowAt

    
    // Override to support conditional editing of the table view.
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
    // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        //Delete the row from the web data source
        
        if editingStyle == .delete {
     
            // connection with web server passing the values in POST
                
            var request = URLRequest(url: URL(string: "https://www.wambutt.de/mobileapp/mysql/deletequeryUserTable.php")! as URL)
            request.httpMethod = "POST"
                
            //collect the name of the row
                
            let postString = "a=\(meals[indexPath.row].name)&e=\(selectUser.username)"
            
            // encoding the textvalues in utf8

            request.httpBody = postString.data(using: String.Encoding.utf8)
                
            //Session to share values and get the response
                
            let task = URLSession.shared.dataTask(with: request as URLRequest)
                {data, response, error in
                    
                    if error != nil {
                        print("error=\(String(describing: error))")
                        return
                    }
                    print("response = \(String(describing: response))")
                    
                    let responseString = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                    print("responseString = \(String(describing: responseString))")
            }
            task.resume()
          
            //remove meal from meals
            
            meals.remove(at: indexPath.row)
            
            // save meals
            
            saveMeals()
        
            // delete meal from the table view
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            }
    }// end of override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     //if editingStyle == .delete

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
        
        case "AddItem": os_log("Adding a new meal.", log:OSLog.default, type: .debug)
        
        case "ShowDetail":
            
        guard let mealDetailViewController = segue.destination as? MealViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
            
           
        }
        guard let selectedMealCell = sender as? MealTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
                }
        guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
                }
        if isFiltering {
            
            mealDetailViewController.meal = filteredMeal[indexPath.row]
        } else {
            
            mealDetailViewController.meal = meals[indexPath.row]
            }
        
        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier)")
            
           
        }
    
    }
    
    //MARK: Actions
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? MealViewController,
            
            let meal = sourceViewController.meal {
         
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
            
    //Update an existing meal
            
                    meals[selectedIndexPath.row] = meal
                    tableView.reloadRows(at: [selectedIndexPath], with: .none)
            
    // send changes to the web
            
                    var request = URLRequest(url: URL(string: "https://www.wambutt.de/mobileapp/mysql/updateUserTable.php")! as URL)
                    request.httpMethod = "POST"
            
                    let postString = "a=\(meal.name)&b=\(meal.photo)&c=\(meal.lessonsLearned)&d=\(meal.rating)&e=\(selectUser.username)&f=yes"
            
                    // encoding the textvalues in utf8
            
                    request.httpBody = postString.data(using: String.Encoding.utf8)
            
                    //Session to share values and get the response
            
                            let task = URLSession.shared.dataTask(with: request as URLRequest)
                            {data, response, error in
                
                                if error != nil {
                                print("error=\(String(describing: error))")
                                return
                                }
                                print("response = \(String(describing: response))")
                
                                let responseString = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                                print("responseString = \(String(describing: responseString))")
            
                            }// end data task
                            task.resume()
        
                } // end if let selected index path
        
                else {
                    // Add a new meal.
            
                    let newIndexPath = IndexPath(row: meals.count, section: 0)
            
                    name = meal.name
                    photo = meal.photo
                    rating = meal.rating
                    lessonsLearned = meal.lessonsLearned
                
                    // connection with web server passing the values in POST
                
                    var request = URLRequest(url: URL(string: "https://www.wambutt.de/mobileapp/mysql/writeToUserTable.php")! as URL)
                    request.httpMethod = "POST"
                
                    //collect the values from Text Fields
                
                    let postString = "a=\(name!)&b=\(photo)&c=\(lessonsLearned!)&d=\(rating!)&e=\(selectUser.username)"
                
                    // encoding the textvalues in utf8
                
                    request.httpBody = postString.data(using: String.Encoding.utf8)
           
                    //Session to share values and get the response
                
                        URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
                    
                            if error != nil {
                                print("error=\(String(describing: error))")
                                return
                            } // end if error
                    
                            print("response = \(String(describing: response))")
                    
                            let responseString = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                            print("responseString = \(String(describing: responseString))")
                        
                            } // end data task
                            .resume()
            
                // Add the meal to meals
                
                meals.append(meal)
                    
                // Add the meal to tableView
                    
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                
                } // end else
            
            //Save the meals
        
            saveMeals()
      
        }// end if let sourceViewController = sender.source as? MealViewController,let meal = sourceViewController.meal
        
    } // end @IBAction func unwindToMealList
    
    
    
    //MARK: Private Methods
    
    /* private func loadSampleMeals() {
        
        let photo1 = "meal1"
        let photo2 = "meal2"
        let photo3 = "meal3"
        
       
        
        guard let meal1 = Meal(name: "Steak", photo: photo1, rating: 4, lessonsLearned: "") else { fatalError("Unable to instantiate meal1")}
            
        guard let meal2 = Meal(name: "Potato", photo: photo2, rating: 5,lessonsLearned: "") else { fatalError("Unable to instantiate meal2")}
          
        guard let meal3 = Meal(name: "Tomato", photo: photo3, rating: 3, lessonsLearned: "") else { fatalError("Unable to instantiate meal3")}
        
        meals += [meal1, meal2, meal3]
        
            } */
    
    // save meals
    
    private func saveMeals() {
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: Meal.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
        }
   
    }
  

    // load meals
    
    private func loadMeals() -> [Meal]? {
        
        return NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
    
    } // end of private func loadMeals
    
    
    func filterContentForSearchText(_searchText: String) {
        
        filteredMeal = meals.filter {
            
            (meal: Meal) -> Bool in return meal.name.lowercased().contains(_searchText.lowercased())
        }
        tableView.reloadData()
        
    } // end func filterContentForSearchText
    
    
    /* opening the alert at the end of the task
         
         let alertContoller = UIAlertController(title: "meal", message: "Successfully Added", preferredStyle: UIAlertController.Style.alert)
         alertContoller.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
         
         self.present(alertContoller, animated: true, completion: nil)
     
    */
    

        
    } // end of main
    
    
            
            
    extension MealTableViewController: UISearchResultsUpdating {
        
        func updateSearchResults ( for searchController: UISearchController) {
            
            //TODO
            
            let searchBar = searchController.searchBar
            filterContentForSearchText(_searchText: searchBar.text!)
            
        } // end func updateSearchResults
        
    }// end extension MealTableViewController: UISearchResultsUpdating
            
  
