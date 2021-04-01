//
//  yas_observing_syncable.h
//

#pragma once

#include <observing/yas_observing_canceller.h>

namespace yas::observing {
struct endable {
    endable();
    explicit endable(std::function<canceller_ptr(void)> &&);

    endable(endable &&) = default;
    endable &operator=(endable &&) = default;

    canceller_ptr end();

   private:
    std::function<canceller_ptr(void)> _handler;

    endable(endable const &) = delete;
    endable &operator=(endable const &) = delete;
};

struct syncable final {
    syncable();
    explicit syncable(std::function<canceller_ptr(bool const)> &&);

    syncable(syncable &&) = default;
    syncable &operator=(syncable &&) = default;

    canceller_ptr sync();
    canceller_ptr end();

   private:
    std::function<canceller_ptr(bool const)> _handler;

    canceller_ptr _call_handler(bool const);

    syncable(syncable const &) = delete;
    syncable &operator=(syncable const &) = delete;
};
}  // namespace yas::observing
