set -euo pipefail
cd "$1"
mkdir -p /security/patches /security/sury-patches
while read -r name selected_file; do
    test -n "$name" || continue
    original="/tmp/sury/debian/patches/$name"
    cp "$original" "/security/sury-patches/$name"
    if [ -n "$selected_file" ]; then
        awk -v target="diff --git a/$selected_file b/$selected_file" '
            /^diff --git / { keep = ($0 == target) }
            keep { print }
        ' "$original" > "/security/patches/$name"
        test -s "/security/patches/$name"
    else
        cp "$original" "/security/patches/$name"
    fi
    patch --batch --fuzz=0 -p1 < "/security/patches/$name"
done < /tmp/build/patches.list
