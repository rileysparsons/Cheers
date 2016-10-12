//
//  Constants.swift
//  Cheers
//
//  Created by Riley Steele Parsons on 10/12/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

import Foundation

struct coffee {
    static let types = ["Americano",
                            "Breve",
                            "Latte",
                            "Mocha",
                            "Cappuccino",
                            "Cortado",
                            "Doppio",
                            "Espresso",
                            "Flat White",
                            "Macchiato",
                            "Long Black",
                            "Ristretto",
                            "Lungo",
                            "Vietnamese Iced Coffee",
                            "Thai Iced Coffee",
                            "Pour Over",
                            "Siphon",
                            "Cold Brew",
                            "Moka Pot"
    ].sorted(by: <)
    
    static let characteristics = ["Smooth (Low Acidity)", "Bright (High Acidity)", "Flat (No Acidity)", "Lemony", "Berry-like", "Citrusy", "Bitter", "Sour", "Acrid", "Chocolatey", "Caramel-like", "Smokey", "Spicy", "Alkaline", "Fruity", "Nutty", "Herbal", "Complex", "Floral", "Bland", "Buttery", "Syrupy", "Tangy"].sorted(by: <)
                            
}
