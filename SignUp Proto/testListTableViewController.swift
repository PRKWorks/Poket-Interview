//
//  testListTableViewController.swift
//  SignUp Proto
//
//  Created by Ram Kumar on 03/08/21.
//

import UIKit

class testListTableViewCell: UITableViewCell {
    @IBOutlet weak var testListImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subTitleLabel: UILabel!
    
}

class testListTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var testListTV: UITableView!
    @IBOutlet weak var signOut: UIButton!
    
    // MARK: - Root
    struct Root: Codable {
        let status: String
        let statusCode: Int
        let data: DataClass

        enum CodingKeys: String, CodingKey {
            case status = "Status"
            case statusCode = "Status_Code"
            case data
        }
    }

    // MARK: - DataClass
    struct DataClass: Codable {
        let cars: [Car]

        enum CodingKeys: String, CodingKey {
            case cars = "Cars"
        }
    }

    // MARK: - Car
    struct Car: Codable {
        let name: String
        let url: String
        let price, carDESCRIPTION, carID: String

        enum CodingKeys: String, CodingKey {
            case name = "Name"
            case url = "URL"
            case price = "PRICE"
            case carDESCRIPTION = "DESCRIPTION"
            case carID = "car_id"
        }
    }
    
    var carArray = [Car]()
        
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        //Call TestList Service
        let url = "https://brandsuat.poket.com/main/Intrview/TestListViewCmd"
        getData(from: url)
    }
    
    // MARK: - Call TestListViewCmd

    func getData(from url: String) {

        let task = URLSession.shared.dataTask(with: URL(string: url)!) { [self] root, response, error in
         if let root = root {
            let root = try? JSONDecoder().decode(Root.self, from: root)
            carArray.append(contentsOf: (root?.data.cars)!)
            print(carArray)
                // Reload table view
                OperationQueue.main.addOperation({
                        self.testListTV.reloadData()
                })
         }
       }
       task.resume()
}
    
    // MARK: - TableView

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        carArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testCell",for: indexPath) as! testListTableViewCell
        cell.titleLabel.text = carArray[indexPath .row].name
        cell.subTitleLabel.text = carArray[indexPath .row].price
        cell.testListImageView.image = UIImage(named: carArray[indexPath.row].url)

        // Create URL
            let url = URL(string: carArray[indexPath.row].url)!

            DispatchQueue.global().async {
                // Fetch Image Data
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        // Create Image and Update Cell ImageView
                        cell.testListImageView.image = UIImage(data: data)
                    }
                }
            }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = carArray[indexPath.row]
        let  vc = storyboard?.instantiateViewController(identifier: "detailViewIdentifier") as! detailViewController
        vc.carNameStr = selectedRow.name
        vc.carPriceStr = selectedRow.price
        vc.CarDescriptionStr = selectedRow.carDESCRIPTION
        vc.setDetailImage(data: selectedRow.url)
        vc.title = "CarInfo"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - signOutTriggered

    @IBAction func signOutTriggered(_ sender: Any) {
            showLogOutAlert()
    }
    
    // MARK: - showLogOutAlert

    func showLogOutAlert() {
        let alert = UIAlertController(title: "SignOut", message: "Are you sure you want to Sign out", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {action in self.loggedOut()}))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    // MARK: - loggedOut

    func loggedOut(){
        signOutWebService()
    }
    
    // MARK: - signOutWebService

    func signOutWebService(){
        //URL
        let url = URL(string: "https://brandsuat.poket.com/main/Intrview/SignOutCmd")
        guard url != nil  else {
            print("URL Error")
            return
        }
        //URL Request
        var request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        
        //Specify the Header
        let header = ["host" : "brandsuat.poket.com","accept" : "string","content-type":"application/json"]
        request.allHTTPHeaderFields = header
        
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
                            self.navigationController?.popViewController(animated: true)
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

