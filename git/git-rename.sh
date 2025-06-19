#!/bin/bash

# -depth により子→親の順で処理
# 変換例: "-" → "_"
from="$1"
to="$2"

find . -depth -name "*${from}*" | while read -r old_name; do
    new_name="${old_name//${from}/${to}}"
    if [[ "$old_name" != "$new_name" ]]; then
        mkdir -p "$(dirname "$new_name")"
        git mv "$old_name" "$new_name"
        echo "Renamed with git mv: $old_name → $new_name"
    fi
done
