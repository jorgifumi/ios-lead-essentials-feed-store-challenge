//
//  XCTestCase+TrackForMemoryLeaks.swift
//  Tests
//
//  Created by Jorge Lucena on 19/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

extension XCTestCase {
	func trackFromMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
		}
	}
}
