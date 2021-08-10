//
//  logInViewController.swift
//  Poket Interview
//
//  Created by Ram Kumar on 03/08/21.
//

import UIKit

class logInViewController: UIViewController {
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var signInBTN: UIButton!
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.setHidesBackButton(true, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        userNameTF.text = ""
        passwordTF.text = ""
        userNameTF.resignFirstResponder()
        passwordTF.resignFirstResponder()
    }
    // MARK: - signInBTN

    @IBAction func signInBTN(_ sender: Any) {
        //SignIn Validation
        if((userNameTF.text?.count != 0)&&(passwordTF.text?.count != 0)){
                self.triggerLogIn()
        }else{
            showAlert(title: "", message: "Enter Valid Username or Password")
        }

    }
    
    // MARK: - showAlert

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    // MARK: - triggerLogIn

    func triggerLogIn(){
        //URL
        let url = URL(string: "https://brandsuat.poket.com/main/Intrview/TestLoginCmd")
        guard url != nil  else {
            print("URL Error")
            return
        }
        //URL Request
        var request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        
        //Specify the Header
        let header = ["host" : "brandsuat.poket.com","accept" : "string","content-type":"application/json"]
        request.allHTTPHeaderFields = header
        
        //Specify the Body
        let jsonObject = ["user_name":userNameTF.text,"password":passwordTF.text]
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
                    
                        //Navigate to ListScreen
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "testListIdentifier", sender: nil)
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
