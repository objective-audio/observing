//
//  yas_observing_syncable_tests.mm
//

#import <XCTest/XCTest.h>
#import <observing/observing.h>
#import <vector>

using namespace yas;
using namespace yas::observing;

@interface yas_observing_syncable_tests : XCTestCase

@end

@implementation yas_observing_syncable_tests

- (void)test_endable {
    std::size_t handler_called = 0;
    std::vector<uint32_t> canceller_called;

    observing::endable endable{[&handler_called, &canceller_called] {
        handler_called++;
        return canceller::make_shared(
            100, [&canceller_called](uint32_t const identifier) { canceller_called.emplace_back(identifier); });
    }};

    XCTAssertEqual(handler_called, 0);
    XCTAssertEqual(canceller_called.size(), 0);

    auto canceller1 = endable.end();

    XCTAssertEqual(handler_called, 1);
    XCTAssertTrue(canceller1);

    canceller1->cancel();

    XCTAssertEqual(canceller_called.size(), 1);
    XCTAssertEqual(canceller_called.at(0), 100);

    auto canceller2 = endable.end();

    XCTAssertEqual(canceller_called.size(), 1);
    XCTAssertFalse(canceller2);
}

- (void)test_endable_empty {
    observing::endable endable;

    auto canceller = endable.end();

    XCTAssertEqual(canceller, nullptr);
}

- (void)test_syncable_sync {
    std::vector<bool> handler_called;
    std::vector<uint32_t> canceller_called;

    observing::syncable syncable{[&handler_called, &canceller_called](bool const sync) {
        handler_called.emplace_back(sync);
        return canceller::make_shared(
            200, [&canceller_called](uint32_t const identifier) { canceller_called.emplace_back(identifier); });
    }};

    XCTAssertEqual(handler_called.size(), 0);
    XCTAssertEqual(canceller_called.size(), 0);

    auto canceller1 = syncable.sync();

    XCTAssertEqual(handler_called.size(), 1);
    XCTAssertTrue(handler_called.at(0));
    XCTAssertTrue(canceller1);

    canceller1->cancel();

    XCTAssertEqual(canceller_called.size(), 1);
    XCTAssertEqual(canceller_called.at(0), 200);

    auto canceller2 = syncable.sync();

    XCTAssertEqual(handler_called.size(), 1);
    XCTAssertEqual(canceller_called.size(), 1);
    XCTAssertFalse(canceller2);
}

- (void)test_syncable_end {
    std::vector<bool> handler_called;
    std::vector<uint32_t> canceller_called;

    observing::syncable syncable{[&handler_called, &canceller_called](bool const sync) {
        handler_called.emplace_back(sync);
        return canceller::make_shared(
            300, [&canceller_called](uint32_t const identifier) { canceller_called.emplace_back(identifier); });
    }};

    XCTAssertEqual(handler_called.size(), 0);
    XCTAssertEqual(canceller_called.size(), 0);

    auto canceller1 = syncable.end();

    XCTAssertEqual(handler_called.size(), 1);
    XCTAssertFalse(handler_called.at(0));
    XCTAssertTrue(canceller1);

    canceller1->cancel();

    XCTAssertEqual(canceller_called.size(), 1);
    XCTAssertEqual(canceller_called.at(0), 300);

    auto canceller2 = syncable.end();

    XCTAssertEqual(handler_called.size(), 1);
    XCTAssertEqual(canceller_called.size(), 1);
    XCTAssertFalse(canceller2);
}

@end
