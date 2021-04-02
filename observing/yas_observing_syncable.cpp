//
//  yas_observing_syncable_private.h
//

#include "yas_observing_syncable.h"

using namespace yas;
using namespace yas::observing;

endable::endable() : _handler(nullptr) {
}

endable::endable(std::function<canceller_ptr(void)> &&handler) : _handler(std::move(handler)) {
}

canceller_ptr endable::end() {
    if (auto handler = std::move(this->_handler)) {
        this->_handler = nullptr;
        return handler();
    } else {
        return nullptr;
    }
}

syncable::syncable() : _handler(nullptr) {
}

syncable::syncable(std::function<canceller_ptr(bool const)> &&handler) : _handler(std::move(handler)) {
}

canceller_ptr syncable::sync() {
    return this->_call_handler(true);
}

canceller_ptr syncable::end() {
    return this->_call_handler(false);
}

canceller_ptr syncable::_call_handler(bool const sync) {
    if (auto handler = std::move(this->_handler)) {
        this->_handler = nullptr;
        return handler(sync);
    } else {
        return nullptr;
    }
}
