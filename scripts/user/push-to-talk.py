import asyncio
import os
import subprocess

import evdev
from evdev import ecodes

TRIGGER = ecodes.ecodes[os.environ.get("PTT_TRIGGER", "KEY_F2")]
TARGET = os.environ.get("PTT_TARGET", "F19")
XDOTOOL = os.environ.get("XDOTOOL", "xdotool")

watched = {}
skipped = set()
held = set()


def send(action):
    subprocess.run([XDOTOOL, action, TARGET], check=False)


def release(path):
    if path in held:
        held.discard(path)
        if not held:
            send("keyup")


async def watch(dev):
    try:
        async for ev in dev.async_read_loop():
            # value: 1 = press, 0 = release, 2 = autorepeat (ignored)
            if ev.type != ecodes.EV_KEY or ev.code != TRIGGER:
                continue
            if ev.value == 1 and dev.path not in held:
                held.add(dev.path)
                if len(held) == 1:
                    send("keydown")
            elif ev.value == 0:
                release(dev.path)
    except OSError:
        pass  # device unplugged
    finally:
        watched.pop(dev.path, None)
        release(dev.path)
        dev.close()


async def main():
    # rescan periodically so keyboards plugged in later are picked up
    while 1:
        paths = set(evdev.list_devices())
        skipped.intersection_update(paths)
        for path in paths - watched.keys() - skipped:
            try:
                dev = evdev.InputDevice(path)
            except OSError:
                continue
            if TRIGGER in dev.capabilities().get(ecodes.EV_KEY, []):
                watched[path] = asyncio.create_task(watch(dev))
            else:
                skipped.add(path)
                dev.close()
        await asyncio.sleep(5)


asyncio.run(main())
