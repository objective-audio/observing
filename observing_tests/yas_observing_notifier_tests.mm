//
//  yas_observing_notifier_tests.mm
//

#import <XCTest/XCTest.h>
#import <observing/observing.h>

using namespace yas;
using namespace yas::observing;

@interface yas_observing_notifier_tests : XCTestCase

@end

@implementation yas_observing_notifier_tests

- (void)test_notify {
    auto const notifier = observing::notifier<int>::make_shared();

    std::vector<int> called1;
    std::vector<int> called2;

    auto const canceller1 = notifier->observe([&called1](int const &value) { called1.emplace_back(value); }).end();
    auto const canceller2 = notifier->observe([&called2](int const &value) { called2.emplace_back(value); }).end();

    XCTAssertEqual(called1.size(), 0);
    XCTAssertEqual(called2.size(), 0);

    notifier->notify(1);

    XCTAssertEqual(called1.size(), 1);
    XCTAssertEqual(called1.at(0), 1);
    XCTAssertEqual(called2.size(), 1);
    XCTAssertEqual(called2.at(0), 1);

    canceller1->cancel();

    notifier->notify(2);

    XCTAssertEqual(called1.size(), 1);
    XCTAssertEqual(called2.size(), 2);
    XCTAssertEqual(called2.at(1), 2);
}

- (void)test_notify_null {
    auto const notifier = observing::notifier<std::nullptr_t>::make_shared();

    std::size_t called;

    auto const canceller = notifier->observe([&called](auto const &) { called += 1; }).end();

    XCTAssertEqual(called, 0);

    notifier->notify(nullptr);

    XCTAssertEqual(called, 1);

    notifier->notify();

    XCTAssertEqual(called, 2);
}

- (void)test_notify_no_observing {
    auto const notifier = observing::notifier<std::nullptr_t>::make_shared();

    notifier->notify(nullptr);
}

@end
