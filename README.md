# purchasepokemon

iOS App feature to purchase Pokemon using the PokeAPI

This is an assessment assignment using only Swift and native iOS libraries and frameworks.

Written by: Matt Kuhn (mattkuhn90@gmail.com, 805-901-0923) on May 18, 2021

For: Cascade Financial Technology Corp.


## Instructions

Launch the app and you will be presented with a form greeting you by your first name and showing your available cash balance (a.k.a. your Pokemon purchasing power).

The cost of each Pokemon is 1 percent of the "base_experience" times 6.

Enter a Pokemon name in the field provided and tap the "Review Purchase" button.

If the Pokemon is not found, an alert will be presented informing you.

If your available balance is insufficient, an alert will be presented informing you (and also of the cost of the Pokemon desired).

If your available balance is sufficient to purchase the Pokemon, you will be
presented with another form showing the price of your selected Pokemon and what would be your available balance after the purchase (should you decide to complete the purchase). 

Once sure, tap the "Complete Purchase" button -- which is "not connected to anything"  per the assessment specs :)


## Tech information

The code is written in Swift.
The forms are created using native Storyboards and Auto-Layout.
The Pokemon REST API call is done using native URLSession.
The JSON decoding is done using native JSONDecoder and Codable struct.


Matt Kuhn 
mattkuhn90@gmail.com
805-901-0923








