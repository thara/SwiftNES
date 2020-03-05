#ifndef SOUND_QUEUE_WRAPPER_H
#define SOUND_QUEUE_WRAPPER_H

#ifdef __cplusplus
extern "C" {
#endif

const void* sound_queue_create();
void sound_queue_destroy(void* obj);

const char* sound_queue_init(void* obj, long sample_rate, int chan_count);
int sound_queue_sample_count(const void* obj);

void sound_queue_write(void* obj, const short*, int count);

#ifdef __cplusplus
}
#endif

#endif
