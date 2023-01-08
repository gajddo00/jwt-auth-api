//
//  File.swift
//  
//
//  Created by Dominika Gajdová on 12.12.2022.
//

import Vapor

struct RefreshTokenRequest: Content {
    let refreshToken: String
}
