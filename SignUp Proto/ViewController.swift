//
//  ViewController.swift
//  SignUp Proto
//
//  Created by Ram Kumar on 30/07/21.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var genderTF: UITextField!
    @IBOutlet weak var dobTF: UITextField!
    @IBOutlet weak var mobileNumberTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var signUpBTN: UIButton!
    let picker = UIImagePickerController()
    let datePicker = UIDatePicker()
    let genderPicker = UIPickerView()
    let minValue = "1970-01-01"
    let maxValue = "2004-12-31"
    let genderArray = ["Male","Female","Other"]

    // MARK: -  viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        picker.delegate = self
        dobTF.delegate = self
        nameTF.delegate = self
        genderTF.delegate = self
        mobileNumberTF.delegate = self
        emailTF.delegate = self
        passwordTF.delegate = self
        genderPicker.delegate = self
        genderPicker.dataSource = self
        
        genderTF.inputView = genderPicker
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - ImagePicker Triggered

    @IBAction func imagePickerBTN(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true,completion: nil )
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
        }
        dismiss(animated: true,completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true,completion: nil)
    }
    
    // MARK: - DatePicker Triggered

     func dateChanged() {
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolBar.setItems([doneBtn], animated: true)
        dobTF.inputAccessoryView = toolBar
        dobTF.inputView = datePicker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let mindate = dateFormatter.date(from: minValue)
        let maxdate = dateFormatter.date(from: maxValue)
        datePicker.minimumDate = mindate
        datePicker.maximumDate = maxdate
    }
    
    // MARK: - Date Picker Done Pressed

    @objc func donePressed(){
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        dobTF.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    // MARK: - textFieldDidBeginEditing

    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if (textField == dobTF) {
            dateChanged()
        }
    }
            
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // For pressing return on the keyboard to dismiss keyboard
        for textField in self.view.subviews where textField is UITextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    
    // MARK: -  Validations

    var isValidEmail: Bool {
       let regularExpressionForEmail = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
       let testEmail = NSPredicate(format:"SELF MATCHES %@", regularExpressionForEmail)
        return testEmail.evaluate(with: emailTF.text)
    }
    
    var isValidPhone: Bool {
       let regularExpressionForPhone = "^\\d{10}$"
       let testPhone = NSPredicate(format:"SELF MATCHES %@", regularExpressionForPhone)
        return testPhone.evaluate(with: mobileNumberTF.text)
    }

    var isValidPassword: Bool {
        //Minimum 8 characters at least 1 Alphabet and 1 Number
       let regularExpressionForPassword = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
       let testPassword = NSPredicate(format:"SELF MATCHES %@", regularExpressionForPassword)
        return testPassword.evaluate(with: passwordTF.text)
    }

    // MARK: - SignUp

    @IBAction func signUp(_ sender: Any) {
        if((imageView.image != nil) && (nameTF.text?.count != 0) &&
            (genderTF.text?.count != 0) && (dobTF.text?.count != 0) && (mobileNumberTF.text?.count != 0) && (emailTF.text?.count != 0) &&
            isValidEmail && isValidPhone && isValidPassword){

            triggerSignUp()

        }else{
            if !isValidEmail && isValidPhone && isValidPassword {
                showAlert(title: "", message: "Not a valid Email")
                return
            }else if !isValidPhone && isValidEmail && isValidPassword {
                showAlert(title: "", message: "Not a valid Phone Number")
                return
            }else if !isValidPassword && isValidEmail && isValidPhone {
                showAlert(title: "Not a valid Password", message: "Password must be Minimum 8 characters at least 1 Alphabet and 1 Number")
                return
            }else{
                showAlert(title: "", message: "Some Fields are missing or Not Valid")
            }
        }

    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    // MARK: - SignUp - WebService

    func triggerSignUp(){
        //URL
        let url = URL(string: "http://localhost:3000/SignUp")
        guard url != nil  else {
            print("URL Error")
            return
        }
        //URL Request
        var request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        
        //Specify the Header
        let header = ["host" : "http://localhost:3000","accept" : "string","content-type":"application/json"]
        request.allHTTPHeaderFields = header
        
        let image : UIImage = imageView.image!
        let imageData = image.jpegData(compressionQuality: 1)
        let base64String = imageData?.base64EncodedString(options: .lineLength64Characters)
        
        //Specify the Body
        let jsonObject = ["name":nameTF.text!,
                          "gender":genderTF.text!,
                          "dob":dobTF.text!,
                          "mobile":mobileNumberTF.text!,
                          "email":emailTF.text!,
                          "password":passwordTF.text!,
                          "photo":base64String!] as [String : Any]
        do{
            let requestBody = try JSONSerialization.data(withJSONObject: jsonObject, options: .fragmentsAllowed)
            request.httpBody = requestBody
        }
        catch{
            print("Error in catching the data")
        }
        //Set the Request Type
        request.httpMethod = "POST"
        //Get the URL Session
        let session = URLSession.shared
        //Create the data Task
        let dataTask = session.dataTask(with: request) { (data, response, error )in
            
            //Check for Errors
            if error == nil && data != nil{
            
                //Try to Parse out the data
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    print(dictionary)
                        //Navigate to Login Screen
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "logInIdentifier", sender: nil)
                        }
                    }
                catch {
                    print("Error parsing Response Data")
                }
            }
        }
        //Fire off the data task
        dataTask.resume()
    }
}

// MARK: - Gender - PickerView

extension ViewController : UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTF.text = genderArray[row]
        genderTF.resignFirstResponder()
    }
    
    
}


