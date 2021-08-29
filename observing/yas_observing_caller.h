//
//  yas_observing_caller.h
//

#pragma once

#include <observing/yas_observing_canceller.h>

#include <map>
#include <vector>

namespace yas::observing {
template <typename T>
struct caller;
template <typename T>
using caller_ptr = std::shared_ptr<caller<T>>;

template <typename T>
struct caller {
    using handler_f = std::function<void(T const &)>;

    ~caller();

    [[nodiscard]] canceller_ptr add(handler_f &&);
    void call(T const &);

    static caller_ptr<T> make_shared();

   private:
    struct handler_container {
        bool enabled = true;
        handler_f handler;
    };

    std::map<uintptr_t, handler_container> _handlers;
    std::map<uintptr_t, canceller_wptr> _cancellers;
    bool _calling = false;

    caller() {
    }
};
}  // namespace yas::observing

#include <observing/yas_observing_caller_private.h>
