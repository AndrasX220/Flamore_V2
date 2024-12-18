//
//  Edzes.swift
//  Flamore
//
//  Created by Hoffer Andras on 2024. 12. 18..
//

import Foundation

struct Edzes: Codable, Identifiable {
    let id: Int
    let megnevezes: String
    let idopont: String
    let terem_id: Int
    let klub_id: Int
    let lezart: Bool
}
