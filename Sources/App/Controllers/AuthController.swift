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
    private var refreshTokens: [RefreshToken] = []
    private let accessTokenExpiration: TimeInterval = 2*60
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
    func authorize(req: Request) async throws -> JwtResponse {
        try createJWTResponse(req: req)
    }
    
    func refreshToken(req: Request) async throws -> JwtResponse {
        let body = try req.content.decode(RefreshTokenRequest.self)
        
        guard let refreshToken = refreshTokens.first(where: { $0.refreshToken == body.refreshToken }) else {
            throw Abort(.badRequest)
        }
        
        guard refreshToken.expiresIn < Date() else {
            throw Abort(.unauthorized)
        }
        
        refreshTokens.removeAll(where: { $0.refreshToken == refreshToken.refreshToken })
        return try createJWTResponse(req: req)
    }
    
    func createJWTResponse(req: Request) throws -> JwtResponse {
        let payload = Payload(
            subject: "vapor",
            expiration: .init(value: Date().addingTimeInterval(accessTokenExpiration))
        )
        
        let accessToken = try req.jwt.sign(payload)
        let refreshToken = UUID().uuidString
        let expirationDate = Date().addingTimeInterval(accessTokenExpiration).timeIntervalSince1970
        
        /// Save refresh token data.
        refreshTokens.append(RefreshToken(
            refreshToken: refreshToken,
            expiresIn: Date().addingTimeInterval(refreshTokenExpiration)
        ))
        
        return JwtResponse(
            accessToken: accessToken,
            tokenType: "Bearer",
            refreshToken: refreshToken,
            expiresIn: expirationDate
        )
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
