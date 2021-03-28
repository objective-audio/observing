//
//  yas_observing_syncable.h
//

#pragma once

#include <observing/yas_observing_canceller.h>

namespace yas::observing {
struct endable {
    endable(std::function<canceller_ptr(void)> &&);

    canceller_ptr end();

   private:
    std::function<canceller_ptr(void)> _handler;

    endable(endable const &) = delete;
    endable(endable &&) = delete;
    endable &operator=(endable const &) = delete;
    endable &operator=(endable &&) = delete;
};

struct syncable final {
    syncable(std::function<canceller_ptr(bool const)> &&);

    canceller_ptr sync();
    canceller_ptr end();

   private:
    std::function<canceller_ptr(bool const)> _handler;

    canceller_ptr _call_handler(bool const);
};
}  // namespace yas::observing
