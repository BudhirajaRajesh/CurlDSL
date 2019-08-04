import XCTest
@testable import CurlDSL

final class ParserOptionsTests: XCTestCase {
	func testOptions1() {
		let str = ""
		let result = Parser.slice(str)
		let tokens = Parser.tokenize(result)
		do {
			_ = try Parser.convertTokensToOptions(tokens)
			XCTFail()
		} catch ParserError.invalidBegin {
		} catch {
			XCTFail()
		}
	}

	func testOptions1_1() {
		let str = " curl "
		let result = Parser.slice(str)
		let tokens = Parser.tokenize(result)
		do {
			_ = try Parser.convertTokensToOptions(tokens)
			XCTFail()
		} catch ParserError.noURL {
		} catch {
			XCTFail()
		}
	}

	func testOptions2() {
		let str = "curl \"https://kkbox.com\""
		let result = Parser.slice(str)
		let tokens = Parser.tokenize(result)
		do {
			let options = try Parser.convertTokensToOptions(tokens)
			switch options[0] {
			case .url(let url):
				XCTAssert(url == "https://kkbox.com")
			default:
				XCTFail()
			}
		} catch {
				XCTFail()
		}
	}

}

final class ParserTokenizingTests: XCTestCase {

	func testMultiLines() {
		let str = """
curl
http://kkbox.com
"""
		let result = Parser.slice(str)
		let tokens = Parser.tokenize(result)
		switch tokens[0] {
		case Token.commandBegin:
			break
		default:
			XCTFail()
		}
		switch tokens[1] {
		case Token.string(let str):
			XCTAssert(str == "http://kkbox.com")
		default:
			XCTFail()
		}
	}

	func testTokenize1() {
		let str = "curl"
		let result = Parser.slice(str)
		let tokens = Parser.tokenize(result)
		switch tokens.first! {
		case Token.commandBegin:
			break
		default:
			XCTFail()
		}
	}

	func testTokenize2() {
		let str = "curl http://kkbox.com"
		let result = Parser.slice(str)
		let tokens = Parser.tokenize(result)
		switch tokens[0] {
		case Token.commandBegin:
			break
		default:
			XCTFail()
		}
		switch tokens[1] {
		case Token.string(let str):
			XCTAssert(str == "http://kkbox.com")
		default:
			XCTFail()
		}
	}

	func testTokenize3() {
		let str = "curl -F x=x http://kkbox.com"
		let result = Parser.slice(str)
		let tokens = Parser.tokenize(result)
		switch tokens[0] {
		case Token.commandBegin:
			break
		default:
			XCTFail()
		}
		switch tokens[1] {
		case Token.shortCommand(let str):
			XCTAssert(str == "-F")
		default:
			XCTFail("\(tokens[1])")
		}
		switch tokens[2] {
		case Token.string(let str):
			XCTAssert(str == "x=x")
		default:
			XCTFail("\(tokens[2])")
		}
		switch tokens[3] {
		case Token.string(let str):
			XCTAssert(str == "http://kkbox.com")
		default:
			XCTFail()
		}
	}

	func testTokenize4() {
		let str = "curl --form=x=x http://kkbox.com"
		let result = Parser.slice(str)
		let tokens = Parser.tokenize(result)
		switch tokens[0] {
		case Token.commandBegin:
			break
		default:
			XCTFail()
		}
		switch tokens[1] {
		case Token.longCommand(let str):
			XCTAssert(str == "--form=x=x")
		default:
			XCTFail("\(tokens[1])")
		}
		switch tokens[2] {
		case Token.string(let str):
			XCTAssert(str == "http://kkbox.com")
		default:
			XCTFail()
		}
	}

}

final class ParserSlicingTests: XCTestCase {
	func testSlice1() {
		let str = "curl"
		let result = Parser.slice(str)
		XCTAssert(result == ["curl"])
	}

	func testSlice2() {
		let str = ""
		let result = Parser.slice(str)
		XCTAssert(result == [])
	}

	func testSlice3() {
		let str = "  "
		let result = Parser.slice(str)
		XCTAssert(result == [])
	}

	func testSlice4() {
		let str = "curl http://kkbox.com"
		let result = Parser.slice(str)
		XCTAssert(result == ["curl", "http://kkbox.com"])
	}

	func testSlice5() {
		let str = "curl \"http://kkbox.com\""
		let result = Parser.slice(str)
		XCTAssert(result == ["curl", "http://kkbox.com"], "\(result)")
	}

	func testSlice5_1() {
		let str = "curl \'http://kkbox.com\'"
		let result = Parser.slice(str)
		XCTAssert(result == ["curl", "http://kkbox.com"], "\(result)")
	}

	func testSlice6() {
		let str = "curl http\"://kkbox.com\""
		let result = Parser.slice(str)
		XCTAssert(result == ["curl", "http://kkbox.com"], "\(result)")
	}

	func testSlice6_1() {
		let str = "curl http\'://kkbox.com\'"
		let result = Parser.slice(str)
		XCTAssert(result == ["curl", "http://kkbox.com"], "\(result)")
	}

	func testSlice7() {
		let str = "curl http\"  ://kkbox.com  \""
		let result = Parser.slice(str)
		XCTAssert(result == ["curl", "http  ://kkbox.com  "], "\(result)")
	}

	func testSlice7_1() {
		let str = "curl http\'  ://kkbox.com  \'"
		let result = Parser.slice(str)
		XCTAssert(result == ["curl", "http  ://kkbox.com  "], "\(result)")
	}

	func testSlice8() {
		let str = "curl \"  \'http://kkbox.com\'  \""
		let result = Parser.slice(str)
		XCTAssert(result == ["curl", "  \'http://kkbox.com\'  "], "\(result)")
	}

	func testSlice8_1() {
		let str = "curl \'  \"http://kkbox.com\"  \'"
		let result = Parser.slice(str)
		XCTAssert(result == ["curl", "  \"http://kkbox.com\"  "], "\(result)")
	}

	func testSlice9() {
		let str = #"curl -F "{ \"name\"=\"name\" }" "http://kkbox.com""#
		let result = Parser.slice(str)
		XCTAssert(result == ["curl", "-F", "{ \"name\"=\"name\" }", "http://kkbox.com"], "\(result)")
	}

	func testSlice10() {
		let str = #"curl "http://kkbox.com"#
		let result = Parser.slice(str)
		XCTAssert(result == ["curl", "http://kkbox.com"], "\(result)")
	}


	//    static var allTests = [
	//        ("testExample", testExample),
	//    ]
}
