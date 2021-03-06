import XCTest
import ASN1Kit

final class ASN1KitTests: XCTestCase {
    func testStaticTags() {
        let encoded: [UInt8] = [
            0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x0C, 0x30, 0x31, 0x13, 0x16, 0x1e
        ]
        let tags = [
            ASN1.Tag.boolean, ASN1.Tag.integer, ASN1.Tag.bitString, ASN1.Tag.octetString, ASN1.Tag.null,
            ASN1.Tag.objectIdentifier, ASN1.Tag.utf8String, ASN1.Tag.sequence, ASN1.Tag.set, ASN1.Tag.printableString,
            ASN1.Tag.ia5String, ASN1.Tag.bmpString]
        
        for item in zip(encoded, tags) {
            XCTAssertEqual(item.0, item.1.data.first!)
        }
    }
    
    func testItem() {
        let boolData = Data([0x01])
        let bool = ASN1.Boolean(bool: true)
        let boolEncoded = Data([0x01, 0x01, 0x01])
        XCTAssertEqual(bool.tag, .boolean)
        XCTAssertEqual(bool.length, boolData.count)
        XCTAssertEqual(bool.data, boolEncoded)
        
        let boolFromData = ASN1.Item.decode(data: bool.data)
        XCTAssertEqual(boolFromData.tag, .boolean)
        XCTAssertEqual(boolFromData.length, boolData.count)
        XCTAssertEqual(boolFromData.data, boolEncoded)
    }
    
    func testBoolean() {
        let booleanTrue = ASN1.Boolean(bool: true)
        XCTAssertEqual(booleanTrue.tag, .boolean)
        XCTAssertEqual(booleanTrue.value, Data([0x01]))
        
        let booleanFalse = ASN1.Boolean(bool: false)
        XCTAssertEqual(booleanFalse.tag, .boolean)
        XCTAssertEqual(booleanFalse.value, Data([0x00]))
        
        let booleanDecoded = ASN1.Item.decode(data: booleanTrue.data)
        XCTAssertTrue(booleanDecoded is ASN1.Boolean)
        XCTAssertEqual(booleanDecoded.tag, .boolean)
        XCTAssertEqual(booleanDecoded.value, Data([0x01]))
    }
    
    func testUnsignedInteger() {
        let a: UInt8 = 0x12
        let itemA = ASN1.Integer(a)
        XCTAssertEqual(itemA.tag, .integer)
        XCTAssertEqual(itemA.length, 1)
        XCTAssertEqual(itemA.data, Data([0x02, 0x01, 0x12]))
        XCTAssertEqual(itemA.uint, UInt(a))
        
        let b: UInt16 = 0x1234
        let itemB = ASN1.Integer(b)
        XCTAssertEqual(itemB.tag, .integer)
        XCTAssertEqual(itemB.length, 2)
        XCTAssertEqual(itemB.data, Data([0x02, 0x02, 0x12, 0x34]))
        XCTAssertEqual(itemB.uint, UInt(b))
        
        let c: UInt32 = 0x12345678
        let itemC = ASN1.Integer(c)
        XCTAssertEqual(itemC.tag, .integer)
        XCTAssertEqual(itemC.length, 4)
        XCTAssertEqual(itemC.data, Data([0x02, 0x04, 0x12, 0x34, 0x56, 0x78]))
        XCTAssertEqual(itemC.uint, UInt(c))
        
        let d: UInt64 = 0x1234567887654321
        let itemD = ASN1.Integer(d)
        XCTAssertEqual(itemD.tag, .integer)
        XCTAssertEqual(itemD.length, 8)
        XCTAssertEqual(itemD.data, Data([0x02, 0x08, 0x12, 0x34, 0x56, 0x78, 0x87, 0x65, 0x43, 0x21]))
        XCTAssertEqual(itemD.uint, UInt(d))
        
        let e = UInt(a)
        let itemE = ASN1.Integer(e)
        XCTAssertEqual(itemE.tag, .integer)
        XCTAssertEqual(itemE.length, 1)
        XCTAssertEqual(itemE.data, Data([0x02, 0x01, 0x12]))
        XCTAssertEqual(itemE.uint, e)
        
        let integerDecoded = ASN1.Item.decode(data: itemE.data)
        XCTAssertTrue(integerDecoded is ASN1.Integer)
        XCTAssertEqual(integerDecoded.tag, .integer)
        XCTAssertEqual(integerDecoded.value, Data([0x12]))
    }
    
    func testSignedInteger() {
        let a: Int8 = 0x12
        let itemA = ASN1.Integer(a)
        XCTAssertEqual(itemA.tag, .integer)
        XCTAssertEqual(itemA.length, 1)
        XCTAssertEqual(itemA.data, Data([0x02, 0x01, 0x12]))
        XCTAssertEqual(itemA.int, Int(a))
        
        let b: Int16 = 0x1234
        let itemB = ASN1.Integer(b)
        XCTAssertEqual(itemB.tag, .integer)
        XCTAssertEqual(itemB.length, 2)
        XCTAssertEqual(itemB.data, Data([0x02, 0x02, 0x12, 0x34]))
        XCTAssertEqual(itemB.int, Int(b))
        
        let c: Int32 = 0x12345678
        let itemC = ASN1.Integer(c)
        XCTAssertEqual(itemC.tag, .integer)
        XCTAssertEqual(itemC.length, 4)
        XCTAssertEqual(itemC.data, Data([0x02, 0x04, 0x12, 0x34, 0x56, 0x78]))
        XCTAssertEqual(itemC.int, Int(c))
        
        let d: Int64 = 0x1234567887654321
        let itemD = ASN1.Integer(d)
        XCTAssertEqual(itemD.tag, .integer)
        XCTAssertEqual(itemD.length, 8)
        XCTAssertEqual(itemD.data, Data([0x02, 0x08, 0x12, 0x34, 0x56, 0x78, 0x87, 0x65, 0x43, 0x21]))
        XCTAssertEqual(itemD.int, Int(d))
        
        let e = Int(a)
        let itemE = ASN1.Integer(e)
        XCTAssertEqual(itemE.tag, .integer)
        XCTAssertEqual(itemE.length, 1)
        XCTAssertEqual(itemE.data, Data([0x02, 0x01, 0x12]))
        XCTAssertEqual(itemE.int, e)
        
        let integerDecoded = ASN1.Item.decode(data: itemE.data)
        XCTAssertTrue(integerDecoded is ASN1.Integer)
        XCTAssertEqual(integerDecoded.tag, .integer)
        XCTAssertEqual(integerDecoded.value, Data([0x12]))
    }
    
    /// Make sure negative numbers are encoded correctly.
    func testSignedIntegerNegative() {
        let a = -26731
        let itemA = ASN1.Integer(a)
        XCTAssertEqual(itemA.tag, .integer)
        XCTAssertEqual(itemA.length, 2)
        XCTAssertEqual(itemA.data, Data([0x02, 0x02, 0x97, 0x95]))
        XCTAssertEqual(itemA.int, a)
        
        let b = -127
        let itemB = ASN1.Integer(b)
        XCTAssertEqual(itemB.tag, .integer)
        XCTAssertEqual(itemB.length, 1)
        XCTAssertEqual(itemB.data, Data([0x02, 0x01, 0x81]))
        XCTAssertEqual(itemB.int, b)
        
        let c = -128
        let itemC = ASN1.Integer(c)
        XCTAssertEqual(itemC.tag, .integer)
        XCTAssertEqual(itemC.length, 1)
        XCTAssertEqual(itemC.data, Data([0x02, 0x01, 0x80]))
        XCTAssertEqual(itemC.int, c)
    }
    
    /// Make sure positive numbers get the prepended zeros.
    func testSignedIntegerPositive() {
        let a = 128
        let itemA = ASN1.Integer(a)
        XCTAssertEqual(itemA.tag, .integer)
        XCTAssertEqual(itemA.length, 2)
        XCTAssertEqual(itemA.data, Data([0x02, 0x02, 0x00, 0x80]))
        XCTAssertEqual(itemA.int, a)
    }
    
    func testBitString() {
        let encoded: [Data] = [
            Data([0x07, 0x80]), Data([0x06, 0xc0]),
            Data([0x05, 0xe0]), Data([0x04, 0xf0]),
            Data([0x03, 0xf8]), Data([0x02, 0xfc]),
            Data([0x01, 0xfe]), Data([0x00, 0xff])
        ]
        
        for bits in 1 ... 8 {
            let bitString = String(repeating: "1", count: bits)
            let unused = UInt8(8 - bits)
            
            let item = ASN1.BitString(bitString: bitString)
            XCTAssertEqual(item.value.first, unused)
            XCTAssertEqual(item.value, encoded[bits - 1])
            XCTAssertEqual(bitString, item.bitString)
        }
        
        let bitStringEncoded = Data([0x03, 0x02, 0x02, 0xfc])
        let bitString = ASN1.Item.decode(data: bitStringEncoded)
        XCTAssertTrue(bitString is ASN1.BitString)
        XCTAssertEqual(bitString.tag, .bitString)
        XCTAssertEqual(bitString.data, bitStringEncoded)
    }
    
    func testOctetString() {
        let data = Data(repeating: .random(in: 0 ... UInt8.max), count: .random(in: 0 ..< 5000))
        let octetItem = ASN1.OctetString(data)
        XCTAssertEqual(octetItem.tag, .octetString)
        XCTAssertEqual(octetItem.length, data.count)
        XCTAssertEqual(octetItem.value, data)
        
        let octetDecoded = ASN1.Item.decode(data: octetItem.data)
        XCTAssertTrue(octetDecoded is ASN1.OctetString)
        XCTAssertEqual(octetDecoded.tag, .octetString)
        XCTAssertEqual(octetDecoded.data, octetItem.data)
        XCTAssertEqual(octetDecoded.value, data)
    }
    
    func testNull() {
        let nullItem = ASN1.Null()
        XCTAssertEqual(nullItem.tag, .null)
        XCTAssertEqual(nullItem.length, 0)
        XCTAssertEqual(nullItem.value, Data())
        
        let nullDecoded = ASN1.Item.decode(data: nullItem.data)
        XCTAssertTrue(nullDecoded is ASN1.Null)
        XCTAssertEqual(nullDecoded.tag, .null)
        XCTAssertEqual(nullDecoded.value, nullItem.value)
        XCTAssertEqual(nullDecoded.data, nullItem.data)
    }
    
    func testObjectIdentifier() {
        let oidString = "1.2.840.113549.1.1.11"
        let oidItem = ASN1.OID(oidString: oidString)
        let oidEncoded = Data([0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x0B])
        XCTAssertEqual(oidItem.tag, .objectIdentifier)
        XCTAssertEqual(oidItem.length, 9)
        XCTAssertEqual(oidItem.data, oidEncoded)
        XCTAssertEqual(oidItem.oidString, oidString)
        
        let oidDecoded = ASN1.Item.decode(data: oidItem.data)
        XCTAssertTrue(oidDecoded is ASN1.ObjectIdentifier)
        XCTAssertEqual(oidDecoded.tag, .objectIdentifier)
        XCTAssertEqual(oidDecoded.value, oidItem.value)
        XCTAssertEqual(oidDecoded.data, oidItem.data)
    }
    
    func testUTF8String() {
        let string = "Test"
        let encodedString = Data([0x54, 0x65, 0x73, 0x74])
        let utf8Item = ASN1.UTF8String(string)
        XCTAssertEqual(utf8Item.tag, .utf8String)
        XCTAssertEqual(utf8Item.length, string.count)
        XCTAssertEqual(utf8Item.value, encodedString)
        XCTAssertEqual(utf8Item.utf8String, string)
        
        let utf8StringDecoded = ASN1.Item.decode(data: utf8Item.data)
        XCTAssertTrue(utf8StringDecoded is ASN1.UTF8String)
        XCTAssertEqual(utf8StringDecoded.length, string.count)
        XCTAssertEqual(utf8StringDecoded.value, encodedString)
        XCTAssertEqual(utf8StringDecoded.data, utf8Item.data)
    }
    
    func testSequence() {
        let oid = ASN1.OID(oidString: "2.5.4.10")
        let str = ASN1.PrintableString("Digital Signature Trust Co.")
        
        let sequence = ASN1.Sequence([oid, str])
        XCTAssertEqual(sequence.tag, .sequence)
        XCTAssertEqual(sequence.length, oid.data.count + str.data.count)
        XCTAssertEqual(sequence.value, oid.data + str.data)
        XCTAssertEqual(sequence.children.count, 2)
        
        for item in [oid, str] {
            XCTAssertNotNil(item.parent)
        }
        
        let sequenceDecoded = ASN1.Item.decode(data: sequence.data)
        XCTAssertTrue(sequenceDecoded is ASN1.Sequence)
        XCTAssertEqual(sequenceDecoded.tag, .sequence)
        XCTAssertEqual(sequenceDecoded.length, oid.data.count + str.data.count)
        XCTAssertEqual(sequenceDecoded.value, oid.data + str.data)
        XCTAssertEqual((sequenceDecoded as? ASN1.ConstructedItem)?.children.count, 2)
        
        for item in (sequenceDecoded as! ASN1.ConstructedItem).children {
            XCTAssertNotNil(item.parent)
        }
    }
    
    func testSet() {
        let oid = ASN1.OID(oidString: "2.5.4.10")
        let str = ASN1.PrintableString("Digital Signature Trust Co.")
        
        let set = ASN1.Set([oid, str])
        XCTAssertEqual(set.tag, .set)
        XCTAssertEqual(set.length, oid.data.count + str.data.count)
        XCTAssertEqual(set.value, oid.data + str.data)
        XCTAssertEqual(set.children.count, 2)
        
        for item in [oid, str] {
            XCTAssertNotNil(item.parent)
        }
        
        let setDecoded = ASN1.Item.decode(data: set.data)
        XCTAssertTrue(setDecoded is ASN1.Set)
        XCTAssertEqual(setDecoded.tag, .set)
        XCTAssertEqual(setDecoded.length, oid.data.count + str.data.count)
        XCTAssertEqual(setDecoded.value, oid.data + str.data)
        XCTAssertEqual((setDecoded as? ASN1.ConstructedItem)?.children.count, 2)
        
        for item in (setDecoded as! ASN1.ConstructedItem).children {
            XCTAssertNotNil(item.parent)
        }
    }
    
    func testPrintableString() {
        let encoded = Data([
            0x44, 0x69, 0x67, 0x69, 0x74, 0x61, 0x6c, 0x20, 0x53, 0x69,
            0x67, 0x6e, 0x61, 0x74, 0x75, 0x72, 0x65, 0x20, 0x54, 0x72,
            0x75, 0x73, 0x74, 0x20, 0x43, 0x6f, 0x2e
        ])
        let string = "Digital Signature Trust Co."
        let printable = ASN1.PrintableString(string)
        XCTAssertEqual(printable.tag, .printableString)
        XCTAssertEqual(printable.value, encoded)
        XCTAssertEqual(printable.printableString, string)
        
        let printableDecoded = ASN1.Item.decode(data: printable.data)
        XCTAssertTrue(printableDecoded is ASN1.PrintableString)
        XCTAssertEqual(printableDecoded.length, string.count)
        XCTAssertEqual(printableDecoded.value, encoded)
        XCTAssertEqual(printableDecoded.data, printable.data)
    }
    
    func testIA5String() {
        let encoded = Data([
            0x68, 0x74, 0x74, 0x70, 0x3A, 0x2F, 0x2F, 0x63, 0x70, 0x73,
            0x2E, 0x72, 0x6F, 0x6F, 0x74, 0x2D, 0x78, 0x31, 0x2E, 0x6C,
            0x65, 0x74, 0x73, 0x65, 0x6E, 0x63, 0x72, 0x79, 0x70, 0x74,
            0x2E, 0x6F, 0x72, 0x67
        ])
        let string = "http://cps.root-x1.letsencrypt.org"
        let ia5 = ASN1.IA5String(string)
        XCTAssertEqual(ia5.tag, .ia5String)
        XCTAssertEqual(ia5.value, encoded)
        XCTAssertEqual(ia5.ia5String, string)
        
        let ia5Decoded = ASN1.Item.decode(data: ia5.data)
        XCTAssertTrue(ia5Decoded is ASN1.IA5String)
        XCTAssertEqual(ia5Decoded.length, string.count)
        XCTAssertEqual(ia5Decoded.value, encoded)
        XCTAssertEqual(ia5Decoded.data, ia5.data)
    }
    
    func testBMPString() {
        let encoded = Data([
            0x00, 0x43, 0x00, 0x65, 0x00, 0x72, 0x00, 0x74, 0x00, 0x69,
            0x00, 0x66, 0x00, 0x69, 0x00, 0x63, 0x00, 0x61, 0x00, 0x74,
            0x00, 0x65, 0x00, 0x54, 0x00, 0x65, 0x00, 0x6d, 0x00, 0x70,
            0x00, 0x6c, 0x00, 0x61, 0x00, 0x74, 0x00, 0x65
        ])
        let string = "CertificateTemplate"
        let bmp = ASN1.BMPString(string)
        XCTAssertEqual(bmp.tag, .bmpString)
        XCTAssertEqual(bmp.value, encoded)
        
        let bmpDecoded = ASN1.Item.decode(data: bmp.data)
        XCTAssertTrue(bmpDecoded is ASN1.BMPString)
        XCTAssertEqual(bmpDecoded.length, encoded.count)
        XCTAssertEqual(bmpDecoded.value, encoded)
        XCTAssertEqual(bmpDecoded.data, bmp.data)
    }
    
    func testFirstWhere() {
        let sequence = ASN1.Sequence([
            ASN1.Sequence([
                ASN1.OID(oidString: "1.2.840.1.133871"),
                ASN1.UTF8String("Test Name")
            ]),
            ASN1.Sequence([
                ASN1.OID(oidString: "1.2.840.1.556"),
                ASN1.Null()
            ])
        ])
        
        let oid = sequence.first(where: { $0.tag == .objectIdentifier })
        XCTAssertNotNil(oid)
        XCTAssertEqual(oid!.tag, .objectIdentifier)
        XCTAssertEqual((oid! as! ASN1.OID).oidString, "1.2.840.1.133871")
        
        let printable = sequence.first(where: { $0.tag == .printableString })
        XCTAssertNil(printable)
    }
    
    func testFiltering() {
        let sequence = ASN1.Sequence([
            ASN1.Sequence([
                ASN1.OID(oidString: "1.2.840.1.133871"),
                ASN1.UTF8String("Test Name")
            ]),
            ASN1.Sequence([
                ASN1.OID(oidString: "1.2.840.1.556"),
                ASN1.Null()
            ])
        ])
        
        let sequences = sequence.filter({ $0.tag == .sequence })
        XCTAssertEqual(sequences.count, 3)
        
        let oids = sequence.filter({ $0.tag == .objectIdentifier }) as! [ASN1.OID]
        XCTAssertEqual(oids.count, 2)
        XCTAssertNotEqual(oids[0].data, oids[1].data)
    }
    
    static var allTests = [
        ("testStaticTags", testStaticTags),
        ("testItem", testItem),
        ("testUnsignedInteger", testUnsignedInteger),
        ("testSignedInteger", testSignedInteger),
        ("testSignedIntegerNegative", testSignedIntegerNegative),
        ("testSignedIntegerPositive", testSignedIntegerPositive),
        ("testBitString", testBitString),
        ("testOctetString", testOctetString),
        ("testNull", testNull),
        ("testObjectIdentifier", testObjectIdentifier),
        ("testUTF8String", testUTF8String),
        ("testSequence", testSequence),
        ("testSet", testSet),
        ("testPrintableString", testPrintableString),
        ("testIA5String", testIA5String),
        ("testBMPString", testBMPString),
        ("testFirstWhere", testFirstWhere),
        ("testFiltering", testFiltering)
    ]
}
