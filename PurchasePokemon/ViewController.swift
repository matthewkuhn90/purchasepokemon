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
    var pokemon: RestPokemon?
    
    let kMaxPokemonNameOrIdLength = 32
    
    lazy var pokemonAPI = PokemonAPI()

    
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
        
            let trimmedPokemonNameOrId =  pokemonName.lowercased().components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.joined(separator: "")
            
            print(trimmedPokemonNameOrId)
            
            if (trimmedPokemonNameOrId.count == 0) {
                self.showErrorAlert(title: "", msg: "Enter a Pokemon name or id")
                return
            }
            
            if (trimmedPokemonNameOrId.count > kMaxPokemonNameOrIdLength) {
                self.showErrorAlert(title: "", msg: "Pokemon name or id too long")
                return
            }
            
            
            self.setUIState(isEnabled: false)
            self.setSpinnerState(isVisible: true)
            
            if let myBalance = self.userRecord?.balance {
                
                self.pokemonAPI.fetchPokemonWithNameOrId(trimmedPokemonNameOrId, currentBalance: myBalance)
                { [weak self] (pokemonVars, myError) in
                    
                    DispatchQueue.main.async {
                        
                        self?.setSpinnerState(isVisible: false)
                        self?.setUIState(isEnabled: true)
                  
                        if let thePokemonSuccessVars = pokemonVars {
                            
                            let storyboard = UIStoryboard(name: "ReviewPurchase", bundle: nil)
                                
                            if let reviewPurchaseVC = storyboard.instantiateViewController(withIdentifier: "reviewPurchaseVC") as? ReviewPurchaseViewController {
                                
                                reviewPurchaseVC.modalTransitionStyle = .crossDissolve
                                reviewPurchaseVC.modalPresentationStyle = .fullScreen
                                
                                reviewPurchaseVC.pokemonName = thePokemonSuccessVars.pokemonName
                                reviewPurchaseVC.pokemonPrice = thePokemonSuccessVars.pokemonPrice
                                reviewPurchaseVC.remainingBalance = thePokemonSuccessVars.remainingBalance
                                
   
                                self?.present(reviewPurchaseVC, animated: true, completion: nil)
                            }
                            
                        } else {
                            
                            if let theMyError = myError {
                     
                                if let theErrMsg = theMyError.translatedErrMsg {
                                    
                                    if let theErrTitle = theMyError.errTitle {
                                        
                                        self?.showErrorAlert(title: theErrTitle, msg: theErrMsg)
                                    } else {
                                        
                                        self?.showErrorAlert(title: "", msg: theErrMsg)
                                        
                                    }
                                }
      
                            } else {
                                self?.showErrorAlert(title: "", msg: "Unknown fetch pokemon error")
                            }
                        }
                        
                    } // end DispatchQueue.main.async
                    
                }
            }
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
    
    
}

