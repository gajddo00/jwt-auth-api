//
//  File.swift
//  
//
//  Created by Dominika Gajdová on 12.12.2022.
//

import Vapor

struct Song: Content {
    let title: String
    let artist: String
}

extension Song {
    static let all = [
        Song(title: "Hey", artist: "Pixies"),
        Song(title: "Skinny Ape", artist: "Gorillaz"),
        Song(title: "Baby", artist: "Justin Bieber")
    ]
}
