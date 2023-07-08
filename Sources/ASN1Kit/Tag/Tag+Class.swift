//
//  Tag+Class.swift
//  
//
//  Created by Bram Kolkman on 08/07/2023.
//

extension ASN1.Tag {
    /// The tag class.
    /// The classes are the two first bits of the tags raw value.
    public enum Class: UInt8 {
        case universal       = 0b00000000
        case application     = 0b01000000
        case contextSpecific = 0b10000000
        case `private`       = 0b11000000
    }
}
