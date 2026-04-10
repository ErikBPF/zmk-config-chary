/*
 * ZMK Input Processor: Idle Suppress
 *
 * Drops all pointing device events if a keyboard key was pressed
 * within the configured idle timeout. This prevents trackball
 * vibration from moving the cursor during typing.
 *
 * Returns ZMK_INPUT_PROC_STOP to completely discard the event,
 * or ZMK_INPUT_PROC_CONTINUE to let it pass through.
 */

#define DT_DRV_COMPAT zmk_input_processor_idle_suppress

#include <zephyr/kernel.h>
#include <zephyr/device.h>
#include <drivers/input_processor.h>
#include <zephyr/logging/log.h>
#include <zmk/events/keycode_state_changed.h>

LOG_MODULE_DECLARE(zmk, CONFIG_ZMK_LOG_LEVEL);

struct idle_suppress_config {
    int16_t idle_timeout_ms;
};

struct idle_suppress_data {
    int64_t last_keypress_time;
};

static int handle_event(const struct device *dev, struct input_event *event,
                        uint32_t param1, uint32_t param2,
                        struct zmk_input_processor_state *state) {
    const struct idle_suppress_config *cfg = dev->config;
    struct idle_suppress_data *data = dev->data;

    int64_t now = k_uptime_get();
    int16_t timeout = (param1 > 0) ? (int16_t)param1 : cfg->idle_timeout_ms;

    if ((data->last_keypress_time + timeout) > now) {
        LOG_DBG("Suppressing input event (idle %lld ms < %d ms)",
                now - data->last_keypress_time, timeout);
        return ZMK_INPUT_PROC_STOP;
    }

    return ZMK_INPUT_PROC_CONTINUE;
}

/* Track keyboard keypresses to know when the user is typing */
static int on_keycode_state_changed(const zmk_event_t *eh) {
    const struct zmk_keycode_state_changed *ev = as_zmk_keycode_state_changed(eh);
    if (ev == NULL || !ev->state) {
        return ZMK_EV_EVENT_BUBBLE;
    }

    /* Update timestamp on all instances */
#define UPDATE_TIMESTAMP(n)                                                                        \
    {                                                                                              \
        struct idle_suppress_data *data =                                                          \
            (struct idle_suppress_data *)DEVICE_DT_INST_GET(n)->data;                              \
        data->last_keypress_time = ev->timestamp;                                                  \
    }

    DT_INST_FOREACH_STATUS_OKAY(UPDATE_TIMESTAMP)

    return ZMK_EV_EVENT_BUBBLE;
}

ZMK_LISTENER(idle_suppress, on_keycode_state_changed);
ZMK_SUBSCRIPTION(idle_suppress, zmk_keycode_state_changed);

static const struct zmk_input_processor_driver_api api = {
    .handle_event = handle_event,
};

static int idle_suppress_init(const struct device *dev) { return 0; }

#define IDLE_SUPPRESS_INST(n)                                                                      \
    static struct idle_suppress_data data_##n = {};                                                \
    static const struct idle_suppress_config config_##n = {                                        \
        .idle_timeout_ms = DT_INST_PROP(n, idle_timeout_ms),                                       \
    };                                                                                             \
    DEVICE_DT_INST_DEFINE(n, idle_suppress_init, NULL, &data_##n, &config_##n, POST_KERNEL,        \
                          CONFIG_KERNEL_INIT_PRIORITY_DEFAULT, &api);

DT_INST_FOREACH_STATUS_OKAY(IDLE_SUPPRESS_INST)
