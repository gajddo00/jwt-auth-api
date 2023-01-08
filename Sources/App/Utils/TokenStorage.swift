//
//  File.swift
//  
//
//  Created by Dominika Gajdová on 08.01.2023.
//

actor TokenStorage {
    var refreshTokens: [RefreshToken] = []
    
    func get(_ token: String) -> RefreshToken? {
        refreshTokens.first(where: { $0.refreshToken == token })
    }
    
    func addToken(_ token: RefreshToken) {
        refreshTokens.append(token)
    }
    
    func removeToken(_ token: String) {
        refreshTokens.removeAll(where: { $0.refreshToken == token })
    }
}
