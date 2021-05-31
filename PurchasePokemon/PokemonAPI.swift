//
//  PokemonAPI.swift
//  PurchasePokemon
//
//  Created by Matt Kuhn on 5/18/21.
//

import UIKit

struct PokemonFetchSuccesValues {
    var pokemonName: String?
    var pokemonPrice: String?
    var remainingBalance: String?
}

typealias pokeMonFetchCompletionCallback = (PokemonFetchSuccesValues?, MyError?) -> Void

let kBasePokemonAPIUrl = "https://pokeapi.co/api/v2/"
let kPokemonAPIUrl = kBasePokemonAPIUrl + "pokemon"


struct RestPokemon: Codable {
    
    var id: Int?
    var name: String?
    var base_experience: Int?
    
    // ...
    
    // https://pokeapi.co/api/v2/pokemon/{id or name}
    
}

class PokemonAPI {
    
    static func getMyError(title: String,
                           msg: String) -> MyError {
        let errMsg = msg
        let myError = MyError.init(translatedErrMsg: errMsg, errTitle: (title == "") ? nil : title)
        return myError
    }
    
    func fetchPokemonWithNameOrId(_ trimmedPokemonNameOrId: String,
                                  currentBalance: Double,
                                  completion: @escaping pokeMonFetchCompletionCallback ) {
        
        let urlStr = kPokemonAPIUrl + "/\(trimmedPokemonNameOrId)"

        if let url = URL(string: urlStr) {
     
            URLSession.shared.dataTask(with: url) { [weak self] data, response, err in
                          
                if let theData = data {
                                        
                    if err != nil {

                        completion(nil, PokemonAPI.getMyError(title: "", msg: "\(String(describing: err))"))
                    }
                
                    //if let jsonString = String(data: theData, encoding: .utf8) {
                    //  print(jsonString)
                    //}
          
                    if let responseData = try? JSONDecoder().decode(RestPokemon.self, from: theData) {

                        if let pokemonName = responseData.name,
                           let baseExperience = responseData.base_experience {
                           
                            let userBalance = currentBalance
                    
                            let pokemonPrice = Double(baseExperience)/100.0 * 6.0 // 1% of base experience times 6
                            
                            let formattedPokemonPrice = String(format:"%.2f", pokemonPrice)
                            
                            if pokemonPrice > userBalance {
                            
                                completion(nil, PokemonAPI.getMyError(title: "Insufficient funds", msg: "Pokemon '\(pokemonName)' price is $\(formattedPokemonPrice)"))
        
                                return
                            }
                          
                            
                            let remainingBalance = userBalance - pokemonPrice
                            let formattedRemainingBalance = String(format:"%.2f", remainingBalance)
                            
                            let pokemonSuccessVars = PokemonFetchSuccesValues.init(pokemonName: pokemonName,
                                    pokemonPrice: formattedPokemonPrice,
                                    remainingBalance: formattedRemainingBalance)
 
                            // Success
                            completion(pokemonSuccessVars, nil)
                            //
     
                        } else {
                            
                            completion(nil,  PokemonAPI.getMyError(title: "", msg: "Pokemon data is nil."))
                        }
                    } else {
                    
                        completion(nil,  PokemonAPI.getMyError(title: "", msg: "Pokemon not found."))
                        
                    }
                } else {
                  
                    completion(nil,  PokemonAPI.getMyError(title: "Pokemon fetch error", msg: "Response data is nil. Check internet connection."))
                }
            }.resume()
            
        } else {
           
            completion(nil,  PokemonAPI.getMyError(title: "Pokemon fetch error", msg: "Bad url."))
            
        }

    }
 
}

