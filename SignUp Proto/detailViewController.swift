//
//  detailViewController.swift
//  SignUp Proto
//
//  Created by Ram Kumar on 08/08/21.
//

import UIKit

class detailViewController: UIViewController {

    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var carPriceLabel: UILabel!
    @IBOutlet weak var carDescriptionTV: UITextView!
    @IBOutlet weak var carImageView: UIImageView!
    var carNameStr:String = ""
    var carPriceStr:String = ""
    var CarDescriptionStr:String = ""

    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        carNameLabel.text = carNameStr
        carPriceLabel.text = carPriceStr
        carDescriptionTV.text = CarDescriptionStr
    }
    
    // MARK: - setDetailImage

    func setDetailImage(data: String)
    {
        print("Data received: \(data)")
        // Create URL
        let url = URL(string: data)!

            DispatchQueue.global().async {
                // Fetch Image Data
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        // Create Image and Update Image View
                        self.carImageView.image = UIImage(data: data)
                    }
                }
            }
    }
}
