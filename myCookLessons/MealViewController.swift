//
//  MealViewController.swift
//  TestmultiView
//
//  Created by coder on 28.12.20.
//  Copyright © 2020 coder. All rights reserved.
//

import UIKit
import os.log

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
   
    //MARK: Properties
    
  
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var ratingControl: RatingControl!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var lessonsLearnedTextView: UITextView!
    
    @IBOutlet weak var AddPhotoLabel: UILabel!
    
    
    /* This value is either passed by 'MealTableViewController' in 'prepare(for:sender:)' or constructed as part of adding a new meal. */
    
    var meal: Meal?
    var imageName: String!
    var permission: Bool!
    var name: String = ""
    var photo: String = ""
    var lessonsLearned: String = ""
    var rating: Int = 0
    var selectedImageData: Data?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field's and text View user input through delegate callbacks.
        
        nameTextField.delegate = self
        lessonsLearnedTextView.delegate = self
        
        //Mark: Intitialization
        
        //Setup username
        
        
        
        
       // Set up views if editing an existing Meal.
        
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text = meal.name
            
            let path = getDocumentsDirectory().appendingPathComponent(meal.photo)
            
            photoImageView.image = UIImage(contentsOfFile: path.path)
            ratingControl.rating = meal.rating
            lessonsLearnedTextView.text = meal.lessonsLearned
            imageName = meal.photo
            
            if photoImageView.image != nil {
                 AddPhotoLabel.isHidden = true
                } // end if
        
        } // end if let meal
        
        //Enable the Save button only if the text field has a valid Meal name
        
        updateSaveButtonState()
        
    }// end override func viewdidload
    
 
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
      
        //Disable the Save button while editing
        saveButton.isEnabled = false
        }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //Hide the keyboard.
       textField.resignFirstResponder()
       return true
        }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
        }
    
    
    // UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if lessonsLearnedTextView.text == "lessons learned" {lessonsLearnedTextView.text = "" }
    }
    
    //Mark: UIImagePickerControllerDelegate

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    // Dismiss the picker from the user canceled
        
        dismiss(animated: true, completion: nil)
        }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
    // The info dictionary may contain multiplr representations of the image. You want to use the original.
        
        guard let selectedImage = info [UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image,but was provided the following: \(info)")
        
            }// end of guard let selectedImage
        
       // Give the image a unique ID and a path to save
        
        imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        // Compress the image to 10 % size
        
        selectedImageData = selectedImage.jpegData(compressionQuality: 0.1)
        
        // Save the image in app directory
        
        try? selectedImageData?.write(to: imagePath)
        
        // Set photoImageView to display the selected image.
        
        photoImageView.image = UIImage(contentsOfFile: imagePath.path)
        
        AddPhotoLabel.isHidden = true
        
        //Dismiss the picker.
        
        dismiss(animated: true, completion: nil)
    
    }// end of func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
    
    
    // Finden des default Pfades für das app documents verzeichnis
    
    func getDocumentsDirectory() -> URL {
        
        let  paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
        
    }
    
    
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
    //Depending om style of presentation(modal or push presentation), this view controllr needs to be dismissed in two different ways.
        
        let  isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
        dismiss(animated: true, completion: nil)
        }
        else if let owningNaviagationController = navigationController {
      owningNaviagationController.popViewController(animated: true)
        }
        else {
           fatalError("The MealViewController is not inside a navigation controller")
        }
    
    }// end of IBAction func cancel
    
    
    //This method lets you configure a view contzroller before it's presented.
    
    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        permission = true
   
        if saveButton.isEnabled {
        permission = true
        } else {
        permission = false
        }
    
        //Configure the destination view controller only when the save button is pressed.
        
        
        guard let button = sender as? UIBarButtonItem, button === saveButton  else {
            os_log("The Save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
       
        
        name = nameTextField.text ?? ""
        photo = imageName ?? ""
        rating = ratingControl.rating
        lessonsLearned = lessonsLearnedTextView.text ?? ""
        
        
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        
        meal = Meal(name: name, photo: photo, rating: rating, lessonsLearned: lessonsLearned)
       
       //sendMealtoWeb((Any).self)
        
        if selectedImageData != nil {
        
        imageUpload(_sender: (Any).self)
            
        }
        
    } // end of override func prepare (for segue: UIStoryboardSegue, sender: Any?)
    
    
    // MARK: Actions
    
    @IBAction func selectImageFromLibrary(_ sender: UITapGestureRecognizer) {
       
        if lessonsLearnedTextView.isFirstResponder {
            lessonsLearnedTextView.resignFirstResponder()
            
            } else {
    
            // UIImagePickerCotroller is a view controller that lets a user pick media from their photo library.
    
            let imagePickerController = UIImagePickerController()
       
            // Only allow photos to be picked,not taken
    
            imagePickerController.sourceType = .photoLibrary
        
            // Make sure ViewController is notified when the user picks an image.
    
            imagePickerController.delegate = self
            present(imagePickerController,animated: true, completion: nil)
            
        } // end of else
    
    }// end of @IBAction func selectImageFromLibrary
    
    
    @IBAction func TappedToResignKeyboard(_ sender: UITapGestureRecognizer) {
        
        lessonsLearnedTextView.resignFirstResponder()
     
       }
    

    //MARK: private methods
    
    private func updateSaveButtonState() {
    
        //Disable the Save button if the text is empty.
    
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    
        }
   
    func imageUpload(_sender: Any) {
        
        // send meal data and image to the web
        
        
        
        let filename = meal!.photo
        
        // generate boundary string using a unique per-app string
        
        let boundary = UUID().uuidString
        let fieldName = "reqtype"
        let fieldValue = "fileToUpload"
        let fieldName2 = "userhash"
        let fieldValue2 = "caa3dce4fcb36cfdf9258ad9c"
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        
        var urlRequest = URLRequest(url: URL(string: "https://www.wambutt.de/mobileapp/upload.php")!)
        urlRequest.httpMethod = "POST"
        
        //Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        //And the boundary is also set here
        
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
       
        //Add the regtype field and its value to the raw http request data
        
        data.append("\r\n--\(boundary)\r\n" .data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName)\"\r\n\r\n" .data(using: .utf8)!)
        data.append("\(fieldValue)".data(using: .utf8)!)
        
        //Add the userhash field and its value to the raw http request data
        
        data.append("\r\n--\(boundary)\r\n" .data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName2)\"\r\n\r\n" .data(using: .utf8)!)
        data.append("\(fieldValue2)\r\n".data(using: .utf8)!)
        
        //Add the image data to the raw http request data
        
        data.append("\r\n--\(boundary)\r\n" .data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"fileToUpload\"; filename=\"\(filename)\"\r\n" .data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n" .data(using: .utf8)!)
        data.append(selectedImageData!)
        
        //End the raw http request data, note that there is 2 extra dash at the end, to indicate the end of the data
        
        data.append("\r\n--\(boundary)--\r\n" .data(using: .utf8)!)
        
        // Send a POST request to the url, with the data we created earlier
        
        session.uploadTask(with: urlRequest, from: data, completionHandler: {responseData, response, error in
            
            if (error != nil) {
                print("\(error!.localizedDescription)")
                }
            guard let responseData = responseData
                else {
                print("no reponse data")
                return
                } // end else
            if let responseString = String(data: responseData, encoding: .utf8) {
                print(" uploaded to: \(responseString)")
                } // end if let
            
            } // end completion handler
        
        ) // end session.uploadTask
        .resume()
        
    } // end of function imageuplöad

} // end of main
