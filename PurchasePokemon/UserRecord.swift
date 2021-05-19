//
//  UserRecord.swift
//  PurchasePokemon
//
//  Created by Matt Kuhn on 5/18/21.
//

struct UserRecord: Codable {
    var firstName: String?
    var lastName: String?
    var accountNumber: UInt64? // 0 to 18446744073709551615, preferable to use a String type however.
    var balance: Double?
    var email: String?
}

