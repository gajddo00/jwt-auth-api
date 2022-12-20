//
//  File.swift
//  
//
//  Created by Dominika Gajdová on 12.12.2022.
//

import Vapor
import JWT
import Foundation

class AuthController: RouteCollection {
    private var tokens: [String: String] = [:]
    private let accessTokenExpiration: TimeInterval = 60
    private let refreshTokenExpiration: TimeInterval = 10*60
    
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("api", "auth")
        auth.post("authorize", use: authorize)
        auth.post("refresh", use: refreshToken)
        auth.get("status", use: checkIfAuthorized)
    }
}

// MARK: Private Handlers
private extension AuthController {
    func authorize(req: Request) async throws -> [String: String] {
        try createJWTResponse(req: req)
    }
    
    func refreshToken(req: Request) async throws -> [String: String] {
        guard let bearerHeader = req.headers.first(name: "Authorization") else {
            throw Abort(.badRequest)
        }
        
        let parts = bearerHeader.components(separatedBy: " ")
        
        guard parts.count == 2 else {
            throw Abort(.badRequest)
        }
        
        let accessToken: String = parts[1]
        let body = try req.content.decode(RefreshTokenRequest.self)
        
        if tokens[accessToken] != body.refreshToken {
            throw Abort(.unauthorized)
        }
        
        return try createJWTResponse(req: req)
    }
    
    func createJWTResponse(req: Request) throws -> [String: String] {
        let payload = Payload(
            subject: "vapor",
            expiration: .init(value: Date().addingTimeInterval(accessTokenExpiration))
        )
        
        let accessToken = try req.jwt.sign(payload)
        let refreshToken = UUID().uuidString
        let expirationDate = Int(Date().addingTimeInterval(accessTokenExpiration).timeIntervalSince1970)
        tokens[accessToken] = refreshToken
        
        return [
            "access_token": accessToken,
            "token_type": "Bearer",
            "expires_in": "\(expirationDate)",
            "refresh_token": refreshToken
        ]
    }
    
    func checkIfAuthorized(req: Request) throws -> HTTPStatus {
        do {
            _ = try req.jwt.verify(as: Payload.self)
            return .ok
        } catch {
            return .unauthorized
        }
    }
}
