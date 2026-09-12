# juce-vmpc-patches

Some patches for JUCE that are used for https://github.com/izzyreal/vmpc-juce.

I've applied them to my fork of JUCE 7.0.9 here: https://github.com/izzyreal/JUCE/tree/7.0.9-vmpc.

## `auv2_auv3_inst_and_effect.patch`

To publish VMPC2000XL AUv2 and AUv3 as instrument as well as effect. JUCE allows only one AU subtype, but we need two.
Some properties are hardcoded to make the code cleaner.

## `auv2_auv3_expose_component_type.patch`

A `std::string auComponentType` property is added to `juce::AudioProcessor`, which is immediately set in the AUv2 and AUv3 constructors to the component type, like `aumu`, `aumf`, etc.
We do this, because in VMPC2000XL, in the About screen we want to include whether the user is running the AudioUnit as an instrument or as an effect.

## `ios_audio.patch`

Backports and local fixes for JUCE iOS audio in a single patch:

1. `AVAudioSessionCategoryOptionAllowBluetooth` is removed for `PlayAndRecord`, so JUCE does not opt into low-quality bidirectional Bluetooth input routes that can force poor sample-rate choices. `AVAudioSessionCategoryOptionAllowBluetoothA2DP` is still enabled where available so normal Bluetooth output remains available.

2. `AVAudioSessionCategoryOptionOverrideMutedMicrophoneInterruption` is enabled on iOS 14.5+ to avoid the Smart Folio microphone-mute interruption path that JUCE 7.0.9 does not recover from correctly.

3. The iOS 18+ buffer-size handling from newer JUCE is backported. This includes the `SubstituteAudioUnit` activation wait, exact preferred buffer-duration requests on iOS 18+, and the updated `updateAvailableBufferSizes()` probing logic.

4. The newer iOS sample-rate handling is also backported, including the AudioQueue-based workaround for iOS 18 sample-rate detection, the available-sample-rate cache per route, and the updated open/restart ordering around hardware refreshes.

## `ableton_live_editor_reopen.patch`

See https://forum.juce.com/t/blank-white-screen-after-plugin-was-closed-and-opened-again/59281/20

The fix is taken from a later JUCE (I think JUCE 8, but not sure) AUv3 wrapper.

## `auv2_aumu_default_bus_layout_in_order_to_support_mixed_mono_and_stereo_outputs.patch`

Use default (non-explicit) AUv2 bus layout if the AUv2 is an aumu (music device).

This allows VMPC2000XL to be used in Logic with:
1. 1x stereo in, 1x stereo out.
2. 1x stereo in, 5x stereo out, 8x mono out.

Also see https://github.com/juce-framework/JUCE/issues/1508

## `macos_do_not_use_CGWindowListCreateImage.patch`

`CGWindowListCreateImage` doesn't build against the macOS 15 SDK. This function is used in JUCE 7 for creating screenshots, which is something we don't need in VMPC2000XL. This patch eliminates usage of `CGWindowListCreateImage` by returning an empty `juce::Image`.

See https://github.com/izzyreal/vmpc-juce/issues/125

## `juce8_AudioDeviceSelectorComponent.patch`

Grabbed from JUCE 8.0.6 (as in, tag `8.0.6`). There was an issue where an incorrect output device would suddenly be selected after the user made a change to the selected input device. See https://github.com/izzyreal/vmpc-juce/issues/137. The updated version of `AudioDeviceSelectorComponent` doesn't suffer from this issue anymore.

## `juce_pushnotifications_windows.patch`

See https://forum.juce.com/t/windows-juce-8-0-6-builds-issues-juce-pushnotifications-h/65317

## `raw_keyboard_macos.patch` and `raw_keyboard_macos_mod_synthesis.patch`

Propagate raw keycodes on macOS only. No native Windows, Linux or iOS code is touched by these patches. Added for Renoise and Ardour, because they don't allow https://github.com/izzyreal/juce-raw-keyboard-input-module. In the case of Renoise, it allows the raw keyboard input module's modifier monitor, but not the normal key down/up monitor. With Ardour, all monitoring is blocked. Since on macOS modifier keys do not come as separate events, we synthesise and emit them ourselves in several relevant places: before propagating a non-mod key-down/up, and before propagating mouse events.
Note that the mod synthesis patch depends on `raw_keyboard_macos.patch`.

## `android_safe_area.patch`

A minimal backport of the Android safe-area reporting improvements from JUCE commit
[`f904fd356ac821e4e03db548ac41ba984f51c45c`](https://github.com/juce-framework/JUCE/commit/f904fd356ac821e4e03db548ac41ba984f51c45c).
It makes `Display::safeAreaInsets` account for system bars and display cutouts, reports
keyboard insets separately, and listens for inset changes on the activity's decor view.

This intentionally includes only the native JNI/windowing changes needed by VMPC2000XL
and excludes the upstream commit's broader Java edge-to-edge and system-bar rewrite.

## `linux_touch.patch`

Backports XInput 2.2 touchscreen support to JUCE 7.0.9, using upstream commits
[`032a1f433b8e24da0a539ab344d6e13279a2a3f8`](https://github.com/juce-framework/JUCE/commit/032a1f433b8e24da0a539ab344d6e13279a2a3f8)
and [`55b2f9cf66d08d762b6c79c30253e90ab1f9a0e7`](https://github.com/juce-framework/JUCE/commit/55b2f9cf66d08d762b6c79c30253e90ab1f9a0e7).

Multiple contacts become independent JUCE touch input sources. XI mouse events
replace core pointer events while XInput is active to avoid duplicate clicks from
touch emulation. Device subscriptions are refreshed on hierarchy changes and
contacts are removed from the mapper when their window is destroyed.

The implementation lives inside `juce_gui_basics`, with XInput logic extracted to
`native/juce_XInput_linux.h` and `.cpp`. There is no additional module. Adaptations
retain JUCE 7's existing mouse-button support and C++17 helpers, decode generic
cookies before interpreting their union as a window event, and propagate keyboard
modifiers to touch callbacks. The native window-system header includes its own
XInput dependency so the raw-keyboard module can continue including it directly.
The two extracted files retain upstream notices.
The only test access is a friend declaration guarded by `JUCE_UNIT_TESTS`.

`JUCE_USE_XINPUT` defaults to `1`. Linux builds, including Linux-hosted juceaide,
need `libxi-dev`; install it in CI/build images before using this fork. Runtime
loading uses `libXi.so.6`; absent or unsupported XInput falls back to ordinary X11
mouse input. Define `JUCE_USE_XINPUT=0` for all JUCE compilation, including host
tools, to build without XInput headers. It is a preprocessor definition, not a
JUCE CMake option.

This targets JUCE's X11 backend. XWayland depends on compositor/device support;
this does not add native Wayland, trackpad gesture recognition, or independent
mouse pointers. Existing Windows and mobile backends are unchanged.

See [Linux touch verification](tests/linux-touch/README.md) for the reproducible
harness, Apple Container setup, fallback checks, and hardware acceptance list.
