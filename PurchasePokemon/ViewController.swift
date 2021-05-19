//
//  ViewController.swift
//  PurchasePokemon
//
//  Created by Matt Kuhn on 5/18/21.
//
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var inquiryLabel: UILabel!
    @IBOutlet weak var pokemonNameTextField: UITextField!
    @IBOutlet weak var reviewPurchaseButton: UIButton!
    @IBOutlet weak var spinner: UIView!
    
    var userRecord: UserRecord?
    var pokemon: Pokemon?
    
    let kMaxPokemonNameOrIdLength = 32

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // For the purposes of this assessment app, I'll populate the user data here:
        var userRec = UserRecord()
        userRec.firstName = "Ivan"
        userRec.lastName = "Minier"
        userRec.accountNumber = 11133344556433443
        userRec.balance = 12.34
        self.userRecord = userRec
        
        
        // Personalize the form
        if let firstName = userRec.firstName,
           let balance = userRec.balance {
            self.greetingLabel.text = "Hello, \(firstName)! You have $\(balance) in Pokemon purchasing power."
        }
        // ^ In production for localization I would use NSLocalizedString(...) and string table
        
        
        // Round the corners of the form view and button
        self.formView.layer.cornerRadius = CGFloat(kCornerRadius)
        self.reviewPurchaseButton.layer.cornerRadius = CGFloat(kCornerRadius)
        
        
        // Nicety - tap view to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onTap))
        self.view.addGestureRecognizer(tap)
   
    }
    
    // MARK: - Actions
    
    @objc func onTap(sender: UITapGestureRecognizer) {
        
        self.view.endEditing(true) // true = force
        
    }
    
    @IBAction func onTapReviewPurchaseButton(_ sender: Any) {
        
        if let pokemonName = self.pokemonNameTextField.text {
            
            let trimmedPokemonNameOrId = pokemonName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            if (trimmedPokemonNameOrId.count == 0) {
                self.showErrorAlert(title: "", msg: "Enter a Pokemon name or id")
                return
            }
            
            if (trimmedPokemonNameOrId.count > kMaxPokemonNameOrIdLength) {
                self.showErrorAlert(title: "", msg: "Pokemon name or id too long")
                return
            }
            
            self.fetchPokemonWith(trimmedPokemonNameOrId)
            
        }
    }
    
    
    // MARK: - Error msg
    
    func showErrorAlert(title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
        self.setSpinnerState(isVisible: false)
        self.setUIState(isEnabled: true)
        
    }
    
    
    // MARK: - UI state
    
    func setUIState(isEnabled: Bool) {
        
        self.pokemonNameTextField.isEnabled = isEnabled
        self.reviewPurchaseButton.isEnabled = isEnabled
        
    }
    
    func setSpinnerState(isVisible: Bool) {
        
        self.spinner.isHidden = !isVisible
        
    }
    
    
    // MARK: - Pokemon API call
    
    func fetchPokemonWith(_ trimmedPokemonNameOrId: String) {
        
        setUIState(isEnabled: false)
        setSpinnerState(isVisible: true)
        
        let errMsgTitle = "Fetch Pokemon error"
        let urlStr = kPokemonAPIUrl + "/\(trimmedPokemonNameOrId)"

        if let url = URL(string: urlStr) {
     
            URLSession.shared.dataTask(with: url) { [weak self] data, response, err in
                          
                if let theData = data {
                                        
                    if err != nil {
                        
                        DispatchQueue.main.async {
                            let errMsg = "\(String(describing: err))"
                            self?.showErrorAlert(title: errMsgTitle, msg: errMsg)
                        }
                        return
                    }
                
                    //if let jsonString = String(data: theData, encoding: .utf8) {
                    //  print(jsonString)
                    //}
          
                    if let responseData = try? JSONDecoder().decode(Pokemon.self, from: theData) {
                        
                        //print(responseData)
                        
                        if let pokemonName = responseData.name,
                           let baseExperience = responseData.base_experience,
                           let userBalance = self?.userRecord?.balance {
                    
                            let pokemonPrice = Double(baseExperience)/100.0 * 6.0 // 1% of base experience times 6
                            
                            let formattedPokemonPrice = String(format:"%.2f", pokemonPrice)
                            
                            if pokemonPrice > userBalance {
                            
                                DispatchQueue.main.async {
                                    self?.showErrorAlert(title: "Insufficient funds", msg: "Pokemon '\(pokemonName)' price is $\(formattedPokemonPrice)")
                                    self?.setSpinnerState(isVisible: false)
                                    self?.setUIState(isEnabled: true)
                                }
        
                                return
                            }
                          
                            
                            let remainingBalance = userBalance - pokemonPrice
                            let formattedRemainingBalance = String(format:"%.2f", remainingBalance)
                            
                            DispatchQueue.main.async {
                                
                                let storyboard = UIStoryboard(name: "ReviewPurchase", bundle: nil)
                                    
                                if let reviewPurchaseVC = storyboard.instantiateViewController(withIdentifier: "reviewPurchaseVC") as? ReviewPurchaseViewController {
                                    
                                    reviewPurchaseVC.modalTransitionStyle = .crossDissolve
                                    reviewPurchaseVC.modalPresentationStyle = .fullScreen
                                    
                                    reviewPurchaseVC.pokemonName = pokemonName
                                    reviewPurchaseVC.pokemonPrice = formattedPokemonPrice
                                    reviewPurchaseVC.remainingBalance = formattedRemainingBalance
                                    
                                    self?.setSpinnerState(isVisible: false)
                                    self?.setUIState(isEnabled: true)
                                    
                                    self?.present(reviewPurchaseVC, animated: true, completion: nil)
                            
                                }
                            
                            }
                            
                        } else {
                            DispatchQueue.main.async {
                                self?.showErrorAlert(title: "", msg: "Pokemon data is nil.")
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.showErrorAlert(title: "", msg: "Pokemon not found.")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.showErrorAlert(title: errMsgTitle, msg: "Response data is nil. Check internet connection.")
                    }
                }
            }.resume()
            
        } else {
            self.showErrorAlert(title: errMsgTitle, msg: "Bad url.")
    
        }

    }
    
}

