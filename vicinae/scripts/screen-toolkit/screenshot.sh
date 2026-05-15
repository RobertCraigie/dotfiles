#!/bin/bash
# @vicinae.schemaVersion 1
# @vicinae.title Screenshot region
# @vicinae.description Select a region, then annotate it with pens, arrows, text, blur
# @vicinae.mode silent
# @vicinae.exec ["/run/current-system/sw/bin/bash"]

exec noctalia-shell ipc call plugin:screen-toolkit annotate
