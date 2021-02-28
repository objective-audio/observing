//
//  yas_canceller_tests.mm
//

#import <XCTest/XCTest.h>
#import <chaining/chaining.h>
#import <vector>

using namespace yas;
using namespace yas::observing;

@interface yas_observing_canceller_tests : XCTestCase

@end

@implementation yas_observing_canceller_tests

- (void)test_destructor {
    std::vector<uint32_t> called;

    {
        auto remover = [&called](uint32_t const identifier) { called.emplace_back(identifier); };

        auto const canceller = canceller::make_shared(1, std::move(remover));

        XCTAssertEqual(canceller->identifier, 1);

        XCTAssertEqual(called.size(), 0);
    }

    XCTAssertEqual(called.size(), 1);
}

- (void)test_cancel {
    std::vector<uint32_t> called;

    {
        auto remover = [&called](uint32_t const identifier) { called.emplace_back(identifier); };

        auto const canceller = canceller::make_shared(1, std::move(remover));

        canceller->cancel();

        XCTAssertEqual(called.size(), 1);
    }

    XCTAssertEqual(called.size(), 1);
}

- (void)test_ignore {
    std::vector<uint32_t> called;

    {
        auto remover = [&called](uint32_t const identifier) { called.emplace_back(identifier); };

        auto const canceller = canceller::make_shared(1, std::move(remover));

        canceller->ignore();

        XCTAssertEqual(called.size(), 0);
    }

    XCTAssertEqual(called.size(), 0);
}

- (void)test_set_to {
    std::vector<uint32_t> called;

    {
        cancellable_ptr canceller = nullptr;
        {
            auto remover = [&called](uint32_t const identifier) { called.emplace_back(identifier); };

            canceller::make_shared(1, std::move(remover))->set_to(canceller);

            XCTAssertEqual(called.size(), 0);
        }
        XCTAssertEqual(called.size(), 0);
    }
    XCTAssertEqual(called.size(), 1);
}

- (void)test_has_cancellable {
    auto const canceller = canceller::make_shared(1, [](uint32_t const identifier) {});

    XCTAssertTrue(canceller->has_cancellable());

    canceller->cancel();

    XCTAssertFalse(canceller->has_cancellable());
}

@end
