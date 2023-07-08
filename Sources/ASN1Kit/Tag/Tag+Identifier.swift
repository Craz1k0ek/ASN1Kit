//
//  Tag+Identifier.swift
//  
//
//  Created by Bram Kolkman on 08/07/2023.
//

extension ASN1.Tag {
    /// The tag value.
    /// The value is the last five bits of the tags raw value.
    public enum Identifier: UInt8 {
        case endOfContent     = 0b00000000
        case boolean          = 0b00000001
        case integer          = 0b00000010
        case bitString        = 0b00000011
        case octetString      = 0b00000100
        case null             = 0b00000101
        case objectIdentifier = 0b00000110
        case objectDescriptor = 0b00000111
        case external         = 0b00001000
        case real             = 0b00001001
        case enumerated       = 0b00001010
        case embeddedPDV      = 0b00001011
        case utf8String       = 0b00001100
        case relativeOID      = 0b00001101
        case time             = 0b00001110
        //   reserved         = 0b00001111
        case sequence         = 0b00010000
        case set              = 0b00010001
        case numericString    = 0b00010010
        case printableString  = 0b00010011
        case t61String        = 0b00010100
        case videotexString   = 0b00010101
        case ia5String        = 0b00010110
        case utcTime          = 0b00010111
        case generalizedTime  = 0b00011000
        case graphicString    = 0b00011001
        case visibleString    = 0b00011010
        case generalString    = 0b00011011
        case universalString  = 0b00011100
        case characterString  = 0b00011101
        case bmpString        = 0b00011110
        case date             = 0b00011111
        //   timeOfDay        = 0b00100000
        //   dateTime         = 0b00100001
        //   duration         = 0b00100010
        //   oidIRI           = 0b00100011
        //   relativeOIDIRI   = 0b00100100
    }
}
