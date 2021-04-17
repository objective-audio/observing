//
//  yas_observing_fetcher.h
//

#pragma once

#include <observing/yas_observing_syncable.h>

namespace yas::observing {
template <typename T>
class fetcher;

template <typename T>
using fetcher_ptr = std::shared_ptr<fetcher<T>>;

template <typename T>
struct fetcher final {
    [[nodiscard]] std::optional<T> fetched_value() const;

    void push();
    void push(T const &value);

    [[nodiscard]] syncable observe(typename caller<T>::handler_f &&);

    [[nodiscard]] static fetcher_ptr<T> make_shared(std::function<std::optional<T>(void)>);

   private:
    std::function<std::optional<T>(void)> _fetching_handler;
    caller_ptr<T> const _caller = caller<T>::make_shared();

    explicit fetcher(std::function<std::optional<T>(void)> &&);
};
}  // namespace yas::observing

#include <observing/yas_observing_fetcher_private.h>
