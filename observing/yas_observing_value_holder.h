//
//  yas_observing_value_holder.h
//

#pragma once

#include <observing/yas_observing_syncable.h>

namespace yas::observing::value {
template <typename T>
class holder;

template <typename T>
using holder_ptr = std::shared_ptr<holder<T>>;

template <typename T>
struct holder final {
    void set_value(T &&);
    void set_value(T const &);

    [[nodiscard]] T const &value() const;

    [[nodiscard]] syncable observe(typename caller<T>::handler_f &&);

    [[nodiscard]] static holder_ptr<T> make_shared(T const &);
    [[nodiscard]] static holder_ptr<T> make_shared(T &&);

   private:
    T _value;
    caller_ptr<T> const _caller = caller<T>::make_shared();

    holder(T &&);
};
}  // namespace yas::observing::value

#include <observing/yas_observing_value_holder_private.h>
