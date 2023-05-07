//
//  Petition.swift
//  Articles
//
//  Created by Даниил Скибинский
//

import Foundation

struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
