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
    std::vector<uint32_t> called;

    observing::endable endable{[&called] {
        return canceller::make_shared(100, [&called](uint32_t const identifier) { called.emplace_back(identifier); });
    }};

    XCTAssertEqual(called.size(), 0);

    endable.end();

    XCTAssertEqual(called.size(), 1);
    XCTAssertEqual(called.at(0), 100);

    endable.end();

    XCTAssertEqual(called.size(), 1);
}
/*
- (void)test_syncable_sync {
    std::size_t handler_called;
    std::vector<uint32_t> canceller_called;

    observing::syncable syncable{[&handler_called] { handler_called += 1; },
                                 canceller::make_shared(200, [&canceller_called](uint32_t const identifier) {
                                     canceller_called.emplace_back(identifier);
                                 })};

    XCTAssertEqual(handler_called, 0);
    XCTAssertEqual(canceller_called.size(), 0);

    syncable.sync();

    XCTAssertEqual(handler_called, 1);
    XCTAssertEqual(canceller_called.size(), 1);
    XCTAssertEqual(canceller_called.at(0), 200);

    syncable.sync();

    XCTAssertEqual(handler_called, 1);
    XCTAssertEqual(canceller_called.size(), 1);
}

- (void)test_syncable_end {
    std::size_t handler_called;
    std::vector<uint32_t> canceller_called;

    observing::syncable syncable{[&handler_called] { handler_called += 1; },
                                 canceller::make_shared(300, [&canceller_called](uint32_t const identifier) {
                                     canceller_called.emplace_back(identifier);
                                 })};

    XCTAssertEqual(handler_called, 0);
    XCTAssertEqual(canceller_called.size(), 0);

    syncable.end();

    XCTAssertEqual(handler_called, 0);
    XCTAssertEqual(canceller_called.size(), 1);
    XCTAssertEqual(canceller_called.at(0), 300);

    syncable.end();

    XCTAssertEqual(handler_called, 0);
    XCTAssertEqual(canceller_called.size(), 1);
}
*/
@end
