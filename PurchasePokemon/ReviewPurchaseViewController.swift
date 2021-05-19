//
//  ReviewPurchaseViewController.swift
//  PurchasePokemon
//
//  Created by Matt Kuhn on 5/18/21.
//
import UIKit

class ReviewPurchaseViewController: UIViewController {

    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var completePurchaseButton: UIButton!
    
    var pokemonName: String?
    var pokemonPrice: String?
    var remainingBalance: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fill out the labels
        if let thePokemonName = self.pokemonName,
           let thePokemonPrice =  self.pokemonPrice,
           let theRemainingBalance = self.remainingBalance {
        
            self.priceLabel.text = "The '\(thePokemonName)' Pokemon price is $\(thePokemonPrice)"
        
            self.balanceLabel.text = "You'll have a balance of $\(theRemainingBalance) after completing this purchase."
            
            // ^ In production for localization I would use NSLocalizedString(...) and string table
           
        }
       
        // Round the corners of the form view and buttons
        self.formView.layer.cornerRadius = CGFloat(kCornerRadius)
        self.cancelButton.layer.cornerRadius = CGFloat(kCornerRadius)
        self.completePurchaseButton.layer.cornerRadius = CGFloat(kCornerRadius)

    }

    // MARK: - Actions
    
    @IBAction func onTapCancelButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
}
