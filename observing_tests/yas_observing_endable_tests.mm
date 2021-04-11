//
//  yas_observing_endable_tests.mm
//

#import <XCTest/XCTest.h>
#import <observing/observing.h>
#import <vector>

using namespace yas;
using namespace yas::observing;

@interface yas_observing_endable_tests : XCTestCase

@end

@implementation yas_observing_endable_tests

- (void)test_end {
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

- (void)test_create_empty {
    observing::endable endable;

    auto canceller = endable.end();

    XCTAssertEqual(canceller, nullptr);
}

- (void)test_create_null {
    observing::endable endable{nullptr};

    auto canceller = endable.end();

    XCTAssertEqual(canceller, nullptr);
}

- (void)test_merge {
    std::size_t handler_called_1 = 0;
    std::vector<uint32_t> canceller_called_1;

    observing::endable endable1{[&handler_called_1, &canceller_called_1] {
        handler_called_1++;
        return canceller::make_shared(
            101, [&canceller_called_1](uint32_t const identifier) { canceller_called_1.emplace_back(identifier); });
    }};

    std::size_t handler_called_2 = 0;
    std::vector<uint32_t> canceller_called_2;

    observing::endable endable2{[&handler_called_2, &canceller_called_2] {
        handler_called_2++;
        return canceller::make_shared(
            102, [&canceller_called_2](uint32_t const identifier) { canceller_called_2.emplace_back(identifier); });
    }};

    endable1.merge(std::move(endable2));

    XCTAssertFalse(endable2.end());

    XCTAssertEqual(handler_called_2, 0);
    XCTAssertEqual(canceller_called_2.size(), 0);

    auto canceller1 = endable1.end();

    XCTAssertEqual(handler_called_1, 1);
    XCTAssertEqual(handler_called_2, 1);
    XCTAssertTrue(canceller1);

    canceller1->cancel();

    XCTAssertEqual(canceller_called_1.size(), 1);
    XCTAssertEqual(canceller_called_1.at(0), 101);
    XCTAssertEqual(canceller_called_2.size(), 1);
    XCTAssertEqual(canceller_called_2.at(0), 102);
}

@end
