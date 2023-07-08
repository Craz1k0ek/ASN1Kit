//
//  Tag.swift
//  
//
//  Created by Bram Kolkman on 08/07/2023.
//

import Foundation

extension ASN1 {
    public struct Tag {
        /// The class of the tag.
        public let `class`: Class
        /// The form of the tag.
        public let form: Form
        /// The encoded identifier of the tag.
        public let identifier: Identifier

        /// The encoded tag.
        public var data: Data {
            Data([self.class.rawValue | form.rawValue | identifier.rawValue])
        }

        /// Boolean value indicating whether or not the tag is a primitive.
        public lazy var isPrimitive: Bool = {
            form == .primitive
        }()
        /// Boolean value indicating whether or not the tag is constructed.
        public lazy var isConstructed: Bool = {
            form == .constructed
        }()

        /// Construct the tag from its raw byte.
        /// - Parameter encoded: The byte that makes up the tag.
        public init(_ rawValue: UInt8) {
            `class` = Class(rawValue: rawValue & 0b11000000)!
            form = Form(rawValue: rawValue & 0b00100000)!
            identifier = Identifier(rawValue: rawValue & 0b00011111)!
        }

        /// Construct the tag from its required components.
        /// - Parameters:
        ///   - c: The class of the tag.
        ///   - form: The form of the tag.
        ///   - identifier: The value of the tag.
        public init(class c: Class, form: Form, identifier: Identifier) {
            self.init(class: c, form: form, identifier: identifier.rawValue)
        }

        /// Construct the tag from its required components.
        /// - Parameters:
        ///   - c: The class of the tag.
        ///   - form: The form of the tag.
        ///   - identifier: The value of the tag.
        public init(class c: Class, form: Form, identifier: UInt8) {
            self.init(c.rawValue | form.rawValue | identifier)
        }

        public static let boolean = ASN1.Tag(class: .universal, form: .primitive, identifier: .boolean)
        public static let integer = ASN1.Tag(class: .universal, form: .primitive, identifier: .integer)
        public static let bitString = ASN1.Tag(class: .universal, form: .primitive, identifier: .bitString)
        public static let octetString = ASN1.Tag(class: .universal, form: .primitive, identifier: .octetString)
        public static let null = ASN1.Tag(class: .universal, form: .primitive, identifier: .null)
        public static let objectIdentifier = ASN1.Tag(class: .universal, form: .primitive, identifier: .objectIdentifier)
        public static let utf8String = ASN1.Tag(class: .universal, form: .primitive, identifier: .utf8String)
        public static let sequence = ASN1.Tag(class: .universal, form: .constructed, identifier: .sequence)
        public static let set = ASN1.Tag(class: .universal, form: .constructed, identifier: .set)
        public static let printableString = ASN1.Tag(class: .universal, form: .primitive, identifier: .printableString)
        public static let ia5String = ASN1.Tag(class: .universal, form: .primitive, identifier: .ia5String)
        public static let bmpString = ASN1.Tag(class: .universal, form: .primitive, identifier: .bmpString)
    }
}

extension ASN1.Tag: Equatable {
    public static func == (lhs: ASN1.Tag, rhs: ASN1.Tag) -> Bool {
        lhs.data.first! == rhs.data.first!
    }
}

extension ASN1.Tag: Comparable {
    public static func < (lhs: ASN1.Tag, rhs: ASN1.Tag) -> Bool {
        lhs.data.first! < rhs.data.first!
    }
}
