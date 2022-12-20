import Vapor
import JWT

// configures your application
public func configure(_ app: Application) throws {
    app.jwt.signers.use(.hs256(key: "361115ae-a9b8-4219-93d5-05b8c0ba63be"))
    
    // register routes
    try routes(app)
}
