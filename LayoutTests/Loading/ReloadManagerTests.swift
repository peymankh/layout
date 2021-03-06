//  Copyright © 2017 Schibsted. All rights reserved.

import XCTest
@testable import Layout

class ReloadManagerTests: XCTestCase {

    private class TestController: UIViewController, LayoutLoading {
        var loadCount = 0

        func layoutDidLoad(_: LayoutNode) {
            loadCount += 1
        }
    }

    func testReload() {
        let vc = TestController()
        vc.loadLayout(named: "LayoutDidLoad_Valid.xml", bundle: Bundle(for: type(of: self)))
        XCTAssertNotNil(vc.layoutNode)
        XCTAssertEqual(vc.loadCount, 1)

        ReloadManager.reload(hard: true)
        XCTAssertEqual(vc.loadCount, 2)
    }

    func testIgnoreDuplicateRegistration() {
        let vc = TestController()
        vc.loadLayout(named: "LayoutDidLoad_Valid.xml", bundle: Bundle(for: type(of: self)))
        XCTAssertEqual(vc.loadCount, 1)
        ReloadManager.addObserver(vc)
        ReloadManager.addObserver(vc)
        ReloadManager.addObserver(vc)

        ReloadManager.reload(hard: true)
        XCTAssertEqual(vc.loadCount, 2)
    }

    func testRelease() {
        weak var weakRef: TestController?
        let initialObserverCount = ReloadManager.observers.count
        autoreleasepool {
            var vc: TestController? = TestController()
            weakRef = vc
            vc?.loadLayout(named: "LayoutDidLoad_Valid.xml", bundle: Bundle(for: type(of: self)))
            ReloadManager.reload(hard: true)
            XCTAssert(ReloadManager.observers.contains { $0 === vc })
            XCTAssertNotNil(weakRef)
            vc = nil
        }
        XCTAssertNil(weakRef)
        XCTAssertEqual(ReloadManager.observers.count, initialObserverCount)
    }
}
