#!/bin/bash
# @vicinae.schemaVersion 1
# @vicinae.title Noctalia Settings
# @vicinae.description Open the Noctalia shell settings panel
# @vicinae.mode silent
# @vicinae.exec ["/run/current-system/sw/bin/bash"]

exec noctalia-shell ipc call settings open
