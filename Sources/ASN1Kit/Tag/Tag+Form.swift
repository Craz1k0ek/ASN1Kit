//
//  Tag+Form.swift
//  
//
//  Created by Bram Kolkman on 08/07/2023.
//

extension ASN1.Tag {
    /// The tag form.
    /// The form is the third bit of the tags raw value.
    public enum Form: UInt8 {
        case primitive   = 0b00000000
        case constructed = 0b00100000
    }
}
