import Foundation

public enum ASN1 {}

// MARK: - ASN.1 Item
extension ASN1 {
    public class Item {
        // MARK: - Properties
        
        /// The tag of the item.
        public let tag: Tag
        /// The length of the item.
        public var length: Int {
            value.count
        }
        /// The value of the item.
        public let value: Data
        
        /// The parent of the item.
        public weak var parent: ASN1.ConstructedItem?
        
        // MARK: Initializers
        
        /// Construct the ASN.1 item from its components.
        /// The length will be extracted from the value.
        /// - Parameters:
        ///   - tag: The tag of the item.
        ///   - value: The value of the item.
        internal init(tag: Tag, value: Data) {
            self.tag    = tag
            self.value  = value
        }
        
        /// Initialize the item from encoded data.
        /// - Parameter data: The ASN.1 encoded data.
        internal convenience init(data: Data) {
            precondition(!data.isEmpty, "Cannot construct an ASN.1 item from empty data")
            var data = data
            let tag = Tag(data.remove(at: 0))

            let extraLengthBytes = Self.extraLengthBytes(for: data)
            let length = Self.decodeLength(data: &data, extraLengthBytes: extraLengthBytes)

            precondition(data.count >= length, "Invalid data, length field exceeds end of data")
            let value = data.subdata(in: 0 ..< length)
            self.init(tag: tag, value: value)
            
            if self is ConstructedItem {
                let constructed = self as! ConstructedItem
                var copy = value
                var children = [ASN1.Item]()
                
                while !copy.isEmpty {
                    let child = ASN1.Item.decode(data: copy)
                    child.parent = constructed
                    children.append(child)
                    copy.removeSubrange(0 ..< child.data.count)
                }
                constructed.children = children
            }
        }
        
        /// Decode ASN.1 data.
        /// - Parameter data: The data to decode.
        /// - Returns: The created ASN.1 item.
        public static func decode(data: Data) -> ASN1.Item {
            precondition(!data.isEmpty, "Cannot construct an ASN.1 item from empty data")
            let tag = ASN1.Tag(data.first!)
            
            switch tag {
            case .boolean:     	    return ASN1.Boolean(data: data)
            case .integer:          return ASN1.Integer(data: data)
            case .bitString:        return ASN1.BitString(data: data)
            case .octetString:      return ASN1.OctetString(data: data)
            case .null:             return ASN1.Null(data: data)
            case .objectIdentifier: return ASN1.ObjectIdentifier(data: data)
            case .utf8String:       return ASN1.UTF8String(data: data)
            case .sequence:         return ASN1.Sequence(data: data)
            case .set:              return ASN1.Set(data: data)
            case .printableString:  return ASN1.PrintableString(data: data)
            case .ia5String:        return ASN1.IA5String(data: data)
            case .bmpString:        return ASN1.BMPString(data: data)
            default:
                NSLog("[ASN1Kit] Warning: unimplemented dedicated class for tag (\(tag.data.hexadecimal))")
                return ASN1.Item(data: data)
            }
        }
    }
}

// MARK: Encoding
extension ASN1.Item {
    /// The encoded length value.
    private var encodedLength: Data {
        // Array conversion is required, otherwise the insert method is going to complain.
        var lengthBytes = Array(UInt(length).bigEndian.trimmedBytes)

        if length > 0b01111111 {                                                // Long form
            lengthBytes.insert(0b10000000 | UInt8(lengthBytes.count), at: 0)    // Insert length providing byte
        }
        return Data(lengthBytes)
    }

    /// The encoded item.
    public var data: Data {
        tag.data + encodedLength + value
    }
}

// MARK: Decoding
extension ASN1.Item {
    /// Calculate how many extra length bytes there are in the encoded data.
    /// - Parameter data: The encoded data starting at the length providing byte.
    /// - Returns: The amount of extra length bytes.
    private static func extraLengthBytes(for data: Data) -> Int {
        precondition(!data.isEmpty, "Invalid data, data is empty")
        let lengthProvidingByte = data.first!
        if (lengthProvidingByte & 0b10000000) == 0b10000000 {
            return Int(lengthProvidingByte & 0b01111111)
        }
        return 0
    }

    /// Decode the length of the encoded data.
    /// - Parameters:
    ///   - data: The encoded data to decode the length from. This data should
    ///   still contain the length providing byte.
    ///   - extraLengthBytes: The number of length bytes to decode.
    /// - Returns: The decoded length.
    private static func decodeLength(data: inout Data, extraLengthBytes: Int) -> Int {
        precondition(!data.isEmpty, "Invalid data, data is empty")
        precondition(data.first != 0x80, "Invalid data, unsupported BER length. Only definite DER lengths are supported")

        if extraLengthBytes == 0 {              // Short form
            return Int(data.remove(at: 0))
        } else {                                // Long form
            data.remove(at: 0)                  // Remove the length providing byte.
            var lengthBytes = data.remove(at: 0 ..< extraLengthBytes)
            while lengthBytes.count < MemoryLayout<Int>.size {
                lengthBytes.insert(0, at: 0)    // Required to load into memory; prepend leading zeros.
            }
            return lengthBytes.withUnsafeBytes { $0.load(as: Int.self) }.bigEndian
        }
    }
}

// MARK: Filtering
extension ASN1.Item {
    /// Returns the first element of the ASN.1 item that satisfies the given predicate.
    /// - Parameter predicate: A closure that takes an ASN.1 item as its argument and returns a Boolean value indicating whether the item is a match.
    /// - Returns: The first item of the ASN.1 item and its children that satisfies predicate, or `nil` if there is no item that satisfies predicate.
    public func first(where predicate: (ASN1.Item) -> Bool) -> ASN1.Item? {
        if predicate(self) { return self }
        if let constructed = self as? ASN1.ConstructedItem {
            return constructed.children.compactMap { $0.first(where: predicate) }.first
        }
        return nil
    }
    
    /// Returns an array containing, in order, the elements of the ASN.1 item that satisfy the given predicate.
    /// - Parameter isIncluded: A closure that takes an ASN.1 item as its argument and returns a Boolean value indicating whether the item should be included in the returned array.
    /// - Returns: An array of the items that `isIncluded` allowed.
    public func filter(_ isIncluded: (ASN1.Item) throws -> Bool) rethrows -> [ASN1.Item] {
        var filtered = [ASN1.Item]()
        if try isIncluded(self) { filtered.append(self) }
        if let constructed = self as? ASN1.ConstructedItem {
            filtered.append(contentsOf: try constructed.children.map { try $0.filter(isIncluded) }.reduce([], +))
        }
        return filtered
    }
}

// MARK: - ASN.1 constructed item
extension ASN1 {
    public class ConstructedItem: ASN1.Item {
        /// The children of this constructed item.
        internal(set) public var children: [ASN1.Item] = []
    }
}
