//
//  selectUser.swift
//  my foods
//
//  Created by coder on 07.12.21.
//  Copyright © 2021 coder. All rights reserved.
//

import UIKit


class selectUser: UIViewController, UITextFieldDelegate,UINavigationControllerDelegate{

    // Properties
    
    var check: String = ""
    var newUser: String = ""
    var newUserPassword: String = ""
    static var username: String = ""
    var Password: String = ""
    var test: String = ""
    
    
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var password: UITextField!
   
    @IBOutlet weak var newUserName: UITextField!
    
    @IBOutlet weak var newPassword: UITextField!
    
    @IBOutlet weak var showAppVersion: UILabel!
    
    
    @IBOutlet weak var userAlreadyexists: UILabel!
   
    @IBOutlet weak var incorrectPasswordOrUser: UILabel!
    
    
    @IBOutlet weak var youAreNotConnectedWith: UILabel!
    
    @IBOutlet weak var youAreNotConnected: UILabel!
    
    
  
    
    //Mark: load view
    
    override func viewDidLoad() {
        super.viewDidLoad()

    // Do any additional setup after loading the view.
     
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        self.showAppVersion.text = "myCookLessons v \(String(describing: appVersion))"
        
        userName.delegate = self
        password.delegate = self
        newUserName.delegate = self
        newPassword.delegate = self
        userAlreadyexists.isHidden = true
        incorrectPasswordOrUser.isHidden = true
        youAreNotConnected.isHidden = true
        youAreNotConnectedWith.isHidden = true
        
    }// end override func viewDidLoad
    
    
    @IBAction func logIn(_ sender: UIButton) {
   
        
    // check on the web username and password are correct
        
        selectUser.username = userName.text!
        Password = password.text!
       
        var request = URLRequest(url: URL(string: "https://www.wambutt.de/mobileapp/mysql/checkusernameAndpassword")! as URL)
        
        request.httpMethod = "POST"
        
        //collect the values fom Text Fields
        
        let postString1 = "a=\(selectUser.username)&b=\(Password)"
        
        // encoding the textvalues in utf8
        
        request.httpBody = postString1.data(using: String.Encoding.utf8)
        
        //Session to share values and get the response
        
        let task = URLSession.shared.dataTask(with: request as URLRequest){data, response, error in
            
            if error != nil {
                print("error=\(String(describing: error))")
                self.youAreNotConnected.isHidden = false
                return
            }
            print("response = \(String(describing: response))")
            
            let responseString = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            print("responseString = \(String(describing: responseString))")
            
            DispatchQueue.main.async {
                
    // if password is correct navigate to the user table view
                
                if (responseString!.contains("true")) {
                
                    //if responseString! == self.password.text {
                    /*
                    let defaults = UserDefaults.standard
                    defaults.set(self.username, forKey: "USER")
                    
                    if let test = defaults.string(forKey: "USER") {
                    let users = test
                    }
                    */
                    
                    print("\(selectUser.username)")
        
                    self.performSegue(withIdentifier: "showMealTableView", sender: nil)
                } else {
                    
                    self.incorrectPasswordOrUser.isHidden = false                }
                
            }// end Dispatchqueu
            
            
        }// end of data task
        task.resume()
        
     
        
        /*
        if userName.text == "Klaus" && password.text == "Klaus" {
            performSegue(withIdentifier: "showMealTableView", sender: nil)
       
        }//end if
        */
        
    } // end IBaction logIn

    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if userName.isFirstResponder {userName.text = ""}
        if password.isFirstResponder {password.text = ""}
        if newUserName.isFirstResponder {newUserName.text = ""}
        if newPassword.isFirstResponder {newPassword.text = ""}
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //Hide the keyboard.
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
       
        
    }
    
    
    @IBAction func registerNow(_ sender: UIButton) {
    
     
    newUser = newUserName.text!
    newUserPassword = newPassword.text!
        
    //Check if username already exists
        
    var request1 = URLRequest(url: URL(string: "https://www.wambutt.de/mobileapp/mysql/checkusername2")! as URL)
        request1.httpMethod = "POST"
        
    //collect the values fom Text Fields
        
    let postString1 = "a=\(newUser)&b=\(newUserPassword)"
        
    // encoding the textvalues in utf8
        
    request1.httpBody = postString1.data(using: String.Encoding.utf8)
        
        //Session to share values and get the response
        
       
          
        let task1 = URLSession.shared.dataTask(with: request1 as URLRequest){data, response, error in
            
        if error != nil {
                print("error=\(String(describing: error))")
                self.youAreNotConnectedWith.isHidden = false
            return
        }
        print("response = \(String(describing: response))")
            
        let responseString = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        print("responseString = \(String(describing: responseString))")
        if (responseString!.contains("false")) {
            
            self.createNewRecordandNewTable()
            
        } else if (responseString!.contains("true")) {
            DispatchQueue.main.async {
                
            self.userAlreadyexists.isHidden = false
            }// end Dispatchqueu
        }
           
        }// end of data task
        task1.resume()
       
         
   
        
    }//end of register now
    
    
    
    
    func createNewRecordandNewTable () {
        
        // sendi newUserName and password to the table userName
        
        // connection with web server passing the values in POST
        
        var request2 = URLRequest(url: URL(string: "https://www.wambutt.de/mobileapp/mysql/writeTousername.php")! as URL)
        request2.httpMethod = "POST"
        
        //collect the values fom Text Fields
        
        let postString2 = "a=\(newUser)&b=\(newUserPassword)"
        
        // encoding the textvalues in utf8
        
        request2.httpBody = postString2.data(using: String.Encoding.utf8)
        
        //Session to share values and get the response
        
        let task2 = URLSession.shared.dataTask(with: request2 as URLRequest){data, response, error in
            
            if error != nil {
                print("error=\(String(describing: error))")
                return
            }
            print("response = \(String(describing: response))")
            
            let responseString = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            print("responseString = \(String(describing: responseString))")
        
        }// end of data task
        task2.resume()
        
        
        // creating a new table with the newUserName
        
        // connection with web server passing the values in POST
        
        var request3 = URLRequest(url: URL(string: "https://www.wambutt.de/mobileapp/mysql/createNewTable.php")! as URL)
        request3.httpMethod = "POST"
        
        //collect the values fom Text Fields
        
        let postString3 = "a=\(newUser)"
        
        // encoding the textvalues in utf8
        
        request3.httpBody = postString3.data(using: String.Encoding.utf8)
        
        //Session to share values and get the response
        
        let task3 = URLSession.shared.dataTask(with: request3 as URLRequest){data, response, error in
            
            if error != nil {
                print("error=\(String(describing: error))")
                return
            }
            print("response = \(String(describing: response))")
            
            let responseString = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            print("responseString = \(String(describing: responseString))")
            
        }// end of data task
        task3.resume()
        
    }// end func createnewRecordandNewTable
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
