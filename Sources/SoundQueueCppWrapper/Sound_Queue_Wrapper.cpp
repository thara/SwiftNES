#include "Sound_Queue_Wrapper.h"

#include "Sound_Queue.h"

template<typename T>
inline T* ptr(void* obj) {
    return reinterpret_cast<T*>(obj);
}

template<typename T>
inline const T* const_ptr(const void* obj) {
    return const_cast<T*>(reinterpret_cast<const T*>(obj));
}

const void* sound_queue_create() {
    Sound_Queue* obj = new Sound_Queue();
    return (void *)obj;
}

void sound_queue_destroy(void* obj) {
    Sound_Queue* sq = ptr<Sound_Queue>(obj);
    delete sq;
}

const char* sound_queue_init(void* obj, long sample_rate, int chan_count) {
    ptr<Sound_Queue>(obj)->init(sample_rate, chan_count);
}

int sound_queue_sample_count(const void* obj) {
    const_ptr<Sound_Queue>(obj)->sample_count();
}

void sound_queue_write(void* obj, const short* in, int count) {
    ptr<Sound_Queue>(obj)->write(in, count);
}
