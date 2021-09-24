//
//  yas_observing_notifier_private.h
//

#pragma once

namespace yas::observing {
template <typename T>
notifier<T>::notifier() {
}

template <typename T>
void notifier<T>::notify(T const &value) {
    if (auto const &caller = this->_caller) {
        caller->call(value);
    }
}

template <typename T>
void notifier<T>::notify() {
    if (auto const &caller = this->_caller) {
        caller->call(nullptr);
    }
}

template <typename T>
endable notifier<T>::observe(typename caller<T>::handler_f &&handler) {
    if (!this->_caller) {
        this->_caller = caller<T>::make_shared();
    }
    return endable{[canceller = this->_caller->add(std::move(handler))] { return canceller; }};
}

template <typename T>
notifier_ptr<T> notifier<T>::make_shared() {
    return std::shared_ptr<notifier<T>>(new notifier<T>{});
}
}  // namespace yas::observing
