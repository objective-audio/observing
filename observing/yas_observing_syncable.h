//
//  yas_observing_syncable.h
//

#pragma once

#include <observing/yas_observing_endable.h>

namespace yas::observing {
struct syncable final {
    syncable();
    explicit syncable(std::function<canceller_ptr(bool const)> &&);

    syncable(syncable &&) = default;
    syncable &operator=(syncable &&) = default;

    cancellable_ptr sync();
    cancellable_ptr end();

    void merge(syncable &&);
    void merge(endable &&);

    endable to_endable();

   private:
    std::vector<std::function<canceller_ptr(bool const)>> _sync_handlers;
    std::vector<std::function<canceller_ptr(void)>> _end_handlers;

    cancellable_ptr _call_handlers(bool const);

    syncable(syncable const &) = delete;
    syncable &operator=(syncable const &) = delete;
};
}  // namespace yas::observing
