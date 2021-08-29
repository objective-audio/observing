//
//  yas_observing_caller_private.h
//

#pragma once

namespace yas::observing {
template <typename T>
caller<T>::~caller() {
    for (auto const &canceller : this->_cancellers) {
        if (auto shared = canceller.second.lock()) {
            shared->ignore();
        }
    }
}

template <typename T>
canceller_ptr caller<T>::add(handler_f &&handler) {
    auto canceller = canceller::make_shared([this](uintptr_t const identifier) {
        this->_handlers.at(identifier).enabled = false;
        this->_handlers.erase(identifier);
        this->_cancellers.erase(identifier);
    });
    auto const identifier = canceller->identifier();
    this->_handlers.emplace(identifier, handler_container{.handler = handler});
    this->_cancellers.emplace(identifier, canceller);
    return canceller;
}

template <typename T>
void caller<T>::call(T const &value) {
    if (!this->_calling) {
        this->_calling = true;
        for (auto const &pair : this->_handlers) {
            if (pair.second.enabled) {
                pair.second.handler(value);
            }
        }
        this->_calling = false;
    }
}

template <typename T>
caller_ptr<T> caller<T>::make_shared() {
    return caller_ptr<T>(new caller<T>{});
}
}  // namespace yas::observing
