#!/usr/bin/env bash
# Only on the task-owned disposable VM. Read workload; no raw root-disk writes.
set -euo pipefail
[[ $(cat /etc/linux-video-lab 2>/dev/null) == linux-video-20261015 ]] || { echo 'Wrong machine'; exit 1; }
[[ $EUID == 0 ]] || { echo 'Run with sudo on the recording VM'; exit 1; }
base=/var/tmp/linux-video-disk-delay
name=linux-video-delay
[[ ! -e $base && ! -e /dev/mapper/$name ]] || { echo 'Previous experiment exists; inspect it first'; exit 1; }
mkdir -m 700 "$base"
loop_device=
cleanup() {
    # Never force-remove a busy mapping; keep evidence if cleanup cannot finish.
    if [[ -e /dev/mapper/$name ]]; then dmsetup remove "$name" || return; fi
    if [[ -n $loop_device ]]; then losetup -d "$loop_device" || return; fi
    echo 'Mapping detached. Backing file retained in /var/tmp/linux-video-disk-delay.'
}
trap cleanup EXIT
dd if=/dev/zero of="$base/backing.img" bs=1M count=256 status=none
loop_device=$(losetup --find --show --read-only "$base/backing.img")
# 256 MiB / 512 bytes per sector = 524288 sectors, reads delayed by 200 ms.
dmsetup create "$name" --readonly --table "0 524288 delay $loop_device 0 200"
echo "Read-only delayed device: /dev/mapper/$name; 200 ms/read; 8 workers; 90 seconds"
dmsetup table "$name"
fio --name=wait-demo --filename="/dev/mapper/$name" --readonly --rw=randread --bs=4k --ioengine=psync --direct=1 --numjobs=8 --size=256M --time_based --runtime=90 --group_reporting
