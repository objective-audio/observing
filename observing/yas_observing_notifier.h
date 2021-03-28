//
//  yas_observing_notifier.h
//

#pragma once

#include <observing/yas_observing_syncable.h>

namespace yas::observing {
template <typename T>
class notifier;

template <typename T>
using notifier_ptr = std::shared_ptr<notifier<T>>;

template <typename T>
struct notifier final {
    void notify(T const &);

    [[nodiscard]] endable observe(typename caller<T>::handler_f &&);

    [[nodiscard]] static notifier_ptr<T> make_shared();

   private:
    caller<T> _caller;

    notifier();
};
}  // namespace yas::observing

#include <observing/yas_observing_notifier_private.h>
