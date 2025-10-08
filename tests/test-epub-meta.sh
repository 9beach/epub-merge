#!/bin/bash

export DEBUG="${DEBUG:-}"

trap 'echo "Error (epub-meta): at line $LINENO" >&2' ERR INT TERM

cleanup() {
	[[ -n "$temp_dir" ]] && rm -fr "$temp_dir" || true
}

trap cleanup EXIT

epub_meta() {
	"$epub_merge_test_dir/../epub-meta" "$@"
}

epub_merge_test_dir="$(realpath "$(dirname "$0")")"

test_dir="${test_dir:-}"
temp_dir="${temp_dir:-}"

if [[ -n "$test_dir" ]]; then
	cp "$epub_merge_test_dir/samples-meta/"* "$test_dir"
	cd "$test_dir"
else
	set -euo pipefail
	temp_dir="$(mktemp -d)"
	cp "$epub_merge_test_dir/samples-meta/"* "$temp_dir"
	cd "$temp_dir"
fi

mkdir -p out
cd out

# alias epub_meta=epub-meta
cp -f ../content.opf-org content.opf

epub_meta content.opf > 01.out

diff_text() {
	diff "$1".out <( sed -E 's/\x1b\[[0-9;]*m//g' "$1.err" )
}

export LANG=ko_KR.UTF-8

echo "Basic OPF testing started"

epub_meta -a '배수아--배, 수아//Suah Bae--Bae, Suah' -t '뱀과물 (Snake And Water)' -r 'Deborah Smith' content.opf 2> 02.err
epub_meta content.opf > 02.out
cp -f content.opf content.opf-02

epub_meta -d '<![CDATA[
<p>A dystopian novel about totalitarianism.</p>
<p>Published in 1949.</p>
]]>' content.opf 2> 03.err
epub_meta content.opf > 03.out
cp -f content.opf content.opf-03

epub_meta -i 'ISBN 978-89-9470-250-6 13191' -l en -m '2025-06-05' -u '2025-05-01' -p '문학동네' -s '문학//꿈//몽환' -x '권리를 존중해주세요' content.opf 2> 04.err
epub_meta content.opf > 04.out
cp -f content.opf content.opf-04

# with -q option
epub_meta -i 'ISBN 978-89-9470-250-6 13191' -l en -m '2025-06-05' -u '2025-05-01' -p '문학동네' -s '문학//꿈//몽환' -x '권리를 존중해주세요' -q content.opf 2> 05.err
epub_meta content.opf > 05.out # Same to 04.out
cp -f content.opf content.opf-05
[[ ! -s 05.err ]]

epub_meta -i 'ISBN 978-89-9470-250-6 13191' -l en -m '2025-06-05' -u '2025-05-01' -p '문학동네' -s '문학//꿈//몽환' -x '권리를 존중해주세요' content.opf 2> 06.err
epub_meta content.opf > 06.out # Same to 04.out
cp -f content.opf content.opf-06

diff 05.out 04.out
diff 06.out 04.out
diff 06.err 04.err

epub_meta -i 'BAD
ISBN XXXXX' -a "Bad
Author
//Really Really
Bad Author--But has
Lovely Name" content.opf 2> 07.err
epub_meta content.opf > 07.out
cp -f content.opf content.opf-07

epub_meta -i 'ISBN 978-89-9470-250-6 13191' -a '배수아' -r 'Deborah Smith' content.opf 2> 08.err
epub_meta content.opf > 08.out
cp -f content.opf content.opf-08

epub_meta -t "<&>\"'#//<&>\"#" -a "<&>\"'#//<&>\"#" content.opf 2> 09.err
epub_meta content.opf > 09.out
cp -f content.opf content.opf-09

diff 01.out ../01.out
for i in {2..9}; do
	diff_text 02
	diff "0${i}.out" "../0${i}.out"
	diff "0${i}.err" "../0${i}.err"
	diff "content.opf-0${i}" "../content.opf-0${i}"
done

echo "Basic OPF testing completed"

echo "Basic EPUB testing started"

cp "$epub_merge_test_dir/samples/original/sample1.epub" .

epub_meta -a '배수아--배, 수아//Suah Bae--Bae, Suah' -t '뱀과물 (Snake And Water)' -r 'Deborah Smith' -i 'ISBN 978-89-9470-250-6 13191' -l ko -m '2025-06-05' -u '2025-05-01' -p '문학동네' -s '문학//꿈//몽환' -x '권리를 존중해주세요' sample1.epub 2> aa.err
epub_meta sample1.epub > aa.out

diff aa.out ../aa.out
diff aa.err ../aa.err
diff_text aa

echo "Basic EPUB testing completed"

time ( for i in {1..50}; do epub_meta content.opf > /dev/null; done )

echo
echo "50 reads completed"

time ( for i in {1..50}; do epub_meta -i 'ISBN 978-89-9470-250-6 13191' -l en -m '2025-06-05' -u '2025-05-01' -p '문학동네' -x '권리를 존중해주세요' -q content.opf; done )

echo
echo "50 writes completed"
