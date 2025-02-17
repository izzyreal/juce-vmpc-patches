#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <repo-path>"
    exit 1
fi

REPO_PATH="$1"
PATCH_PATH=$(pwd)

if [ ! -d "$REPO_PATH/.git" ]; then
    echo "Error: '$REPO_PATH' is not a valid git repository."
    exit 1
fi

cd "$REPO_PATH" || exit 1

for PATCH in \
    "auv2_auv3_inst_and_effect.patch" \
    "auv2_auv3_expose_component_type.patch" \
    "auv2_aumu_default_bus_layout_in_order_to_support_mixed_mono_and_stereo_outputs.patch" \
    "auv3_aumu_default_bus_layout_in_order_to_support_mixed_mono_and_stereo_outputs.patch" \
    "ableton_live_editor_reopen.patch" \
    "ios_audio.patch"
do
    if [ ! -f "$PATCH_PATH/$PATCH" ]; then
        echo "Error: Patch '$PATCH' not found."
        exit 1
    fi
    git apply "$PATCH_PATH/$PATCH" || exit 1
done

echo "All patches applied successfully."
