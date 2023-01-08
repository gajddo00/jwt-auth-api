//
//  File.swift
//  
//
//  Created by Dominika Gajdová on 20.12.2022.
//

import Vapor

struct JwtResponse: Content {
    let accessToken: String
    let tokenType: String
    let refreshToken: String
    let expiresIn: Double
}
