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

- (void)test_sync {
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

- (void)test_end {
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

- (void)test_merge {
    std::vector<bool> handler_called1;
    std::vector<uint32_t> canceller_called1;

    observing::syncable syncable1{[&handler_called1, &canceller_called1](bool const sync) {
        handler_called1.emplace_back(sync);
        return canceller::make_shared(
            201, [&canceller_called1](uint32_t const identifier) { canceller_called1.emplace_back(identifier); });
    }};

    std::vector<bool> handler_called2;
    std::vector<uint32_t> canceller_called2;

    observing::syncable syncable2{[&handler_called2, &canceller_called2](bool const sync) {
        handler_called2.emplace_back(sync);
        return canceller::make_shared(
            202, [&canceller_called2](uint32_t const identifier) { canceller_called2.emplace_back(identifier); });
    }};

    std::size_t handler_called3 = 0;
    std::vector<uint32_t> canceller_called3;

    observing::endable endable{[&handler_called3, &canceller_called3] {
        handler_called3++;
        return canceller::make_shared(
            203, [&canceller_called3](uint32_t const identifier) { canceller_called3.emplace_back(identifier); });
    }};

    syncable1.merge(std::move(syncable2));

    XCTAssertFalse(syncable2.end());

    XCTAssertEqual(handler_called2.size(), 0);
    XCTAssertEqual(canceller_called2.size(), 0);

    syncable1.merge(std::move(endable));

    XCTAssertFalse(endable.end());

    XCTAssertEqual(handler_called3, 0);
    XCTAssertEqual(canceller_called3.size(), 0);

    auto canceller1 = syncable1.sync();

    XCTAssertTrue(canceller1);
    XCTAssertEqual(handler_called1.size(), 1);
    XCTAssertTrue(handler_called1.at(0));
    XCTAssertEqual(handler_called2.size(), 1);
    XCTAssertTrue(handler_called2.at(0));
    XCTAssertEqual(handler_called3, 1);

    canceller1->cancel();

    XCTAssertEqual(canceller_called1.size(), 1);
    XCTAssertEqual(canceller_called1.at(0), 201);
    XCTAssertEqual(canceller_called2.size(), 1);
    XCTAssertEqual(canceller_called2.at(0), 202);
    XCTAssertEqual(canceller_called3.size(), 1);
    XCTAssertEqual(canceller_called3.at(0), 203);
}

- (void)test_to_endable {
    std::vector<bool> handler_called1;
    std::vector<uint32_t> canceller_called1;

    observing::syncable syncable{[&handler_called1, &canceller_called1](bool const sync) {
        handler_called1.emplace_back(sync);
        return canceller::make_shared(
            301, [&canceller_called1](uint32_t const identifier) { canceller_called1.emplace_back(identifier); });
    }};

    std::size_t handler_called2 = 0;
    std::vector<uint32_t> canceller_called2;

    observing::endable endable{[&handler_called2, &canceller_called2] {
        handler_called2++;
        return canceller::make_shared(
            302, [&canceller_called2](uint32_t const identifier) { canceller_called2.emplace_back(identifier); });
    }};

    syncable.merge(std::move(endable));

    auto dst_endable = syncable.to_endable();

    XCTAssertFalse(syncable.sync());
    XCTAssertEqual(handler_called1.size(), 0);
    XCTAssertEqual(handler_called2, 0);

    auto canceller = dst_endable.end();

    XCTAssertTrue(canceller);

    XCTAssertEqual(handler_called1.size(), 1);
    XCTAssertFalse(handler_called1.at(0));
    XCTAssertEqual(handler_called2, 1);

    canceller->cancel();

    XCTAssertEqual(canceller_called1.size(), 1);
    XCTAssertEqual(canceller_called1.at(0), 301);
    XCTAssertEqual(canceller_called2.size(), 1);
    XCTAssertEqual(canceller_called2.at(0), 302);
}

- (void)test_create_empty {
    observing::syncable syncable;

    auto canceller = syncable.sync();

    XCTAssertEqual(canceller, nullptr);
}

- (void)test_create_null {
    observing::syncable syncable{nullptr};

    auto canceller = syncable.sync();

    XCTAssertEqual(canceller, nullptr);
}

@end
