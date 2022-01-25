//
//  yas_observing_caller_private.h
//

#pragma once

namespace yas::observing {
template <typename T>
caller<T>::caller() : _member(std::make_shared<member>()) {
}

template <typename T>
caller<T>::~caller() {
    auto const member = this->_member;
    for (auto const &canceller : member->cancellers) {
        if (auto shared = canceller.second.lock()) {
            shared->ignore();
        }
    }
}

template <typename T>
canceller_ptr caller<T>::add(handler_f &&handler) {
    auto canceller = canceller::make_shared([this](uintptr_t const identifier) {
        auto const member = this->_member;

        member->handlers.at(identifier).enabled = false;
        if (!member->calling) {
            member->handlers.erase(identifier);
        }
        member->cancellers.erase(identifier);
    });
    auto const identifier = canceller->identifier();
    this->_member->handlers.emplace(identifier, handler_container{.handler = handler});
    this->_member->cancellers.emplace(identifier, canceller);
    return canceller;
}

template <typename T>
void caller<T>::call(T const &value) {
    auto const member = this->_member;

    if (!member->calling) {
        member->calling = true;
        std::vector<uintptr_t> removed;
        for (auto const &pair : member->handlers) {
            if (pair.second.enabled) {
                pair.second.handler(value);
            }

            if (!pair.second.enabled) {
                removed.emplace_back(pair.first);
            }
        }
        for (auto const &identifier : removed) {
            member->handlers.erase(identifier);
        }
        member->calling = false;
    }
}

template <typename T>
caller_ptr<T> caller<T>::make_shared() {
    return caller_ptr<T>(new caller<T>{});
}
}  // namespace yas::observing
