#!/bin/bash

export DEBUG="${DEBUG:-}"
export NO_TIME_TESTING="${NO_TIME_TESTING:-}"
export LANG="ko_KR"

trap 'printf "\033[31mError ($(basename "$0")): at line '\
'$LINENO: $BASH_COMMAND\033[0m\n" >&2; cleanup' ERR INT TERM

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
grep -q '^제목: 뱀과물 (Snake And Water)$' 02.out
grep -q '^작가: 배수아 \[배, 수아\]$' 02.out
grep -q '^작가: Suah Bae \[Bae, Suah\]$' 02.out
grep -q '^번역: Deborah Smith$' 02.out
grep -q '^작성일: 2017-12-07$' 02.out
cp -f content.opf content.opf-02

epub_meta -d '<![CDATA[
<p>A dystopian novel about totalitarianism.</p>
<p>Published in 1949.</p>

]]>' content.opf 2> 03.err
epub_meta content.opf > 03.out
grep -q '^설명: <!\[CDATA\[$' 03.out
grep -q '^<p>A dystopian novel about totalitarianism.</p>$' 03.out
grep -q '^<p>Published in 1949.</p>$' 03.out
grep -q '^]]>$' 03.out
cp -f content.opf content.opf-03

epub_meta -i 'ISBN 978-89-9470-250-6 13191' -l en -m '2024-06-05' -u '2024-05-01' -p '문학동네' -s '문학//꿈//몽환' -x '권리를 존중해주세요' content.opf 2> 04.err
epub_meta content.opf > 04.out
grep -q '^주제: 문학$' 04.out
grep -q '^주제: 꿈$' 04.out
grep -q '^주제: 몽환$' 04.out
grep -q '^출판일: 2024-05-01$' 04.out
grep -q '^수정일: 2024-06-05$' 04.out
grep -q '^작성일: 2017-12-07$' 04.out
grep -q '^권리: 권리를 존중해주세요$' 04.out
grep -q '^도서번호: ISBN 978-89-9470-250-6 13191$' 04.out
grep -q '^출판사: 문학동네$' 04.out
grep -q '^설명: <!\[CDATA\[$' 04.out
grep -q '^<p>A dystopian novel about totalitarianism.</p>$' 04.out
grep -q '^<p>Published in 1949.</p>$' 04.out
grep -q '^$' 04.out
grep -q '^]]>$' 04.out
cp -f content.opf content.opf-04

# with -q option
epub_meta -i 'ISBN 978-89-9470-250-6 13191' -l en -m '2024-06-05' -u '2024-05-01' -p '문학동네' -s '문학//꿈//몽환' -x '권리를 존중해주세요' -q content.opf 2> 05.err
epub_meta content.opf > 05.out # Same to 04.out
cp -f content.opf content.opf-05
[[ ! -s 05.err ]]
diff 05.out 04.out

epub_meta -i 'ISBN 978-89-9470-250-6 13191' -l en -m '2024-06-05' -u '2024-05-01' -p '문학동네' -s '문학//꿈//몽환' -x '권리를 존중해주세요' content.opf 2> 06.err
epub_meta content.opf > 06.out # Same to 04.out
cp -f content.opf content.opf-06

diff content.opf-05 content.opf-04
diff 06.out 04.out
diff content.opf-06 content.opf-04
diff 06.err 04.err

epub_meta -i 'BAD
ISBN XXXXX' -a "Bad

Author
//Really Really
Bad Author--But has
Lovely Name" content.opf 2> 07.err
epub_meta content.opf > 07.out
grep -q 'BAD$' 07.out
grep -q 'Bad$' 07.out
grep -q '^$' 07.out
grep -q 'Really Really$' 07.out
grep -q '^$' 07.out
cp -f content.opf content.opf-07

epub_meta -i 'ISBN 978-89-9470-250-6 13191' -a '배수아' -r 'Deborah Smith' content.opf 2> 08.err
epub_meta content.opf > 08.out
cp -f content.opf content.opf-08

epub_meta -t "<&>\"'#//<&>\"#" -a "<&>\"'#//<&>\"#" content.opf 2> 09.err
epub_meta content.opf > 09.out
cp -f content.opf content.opf-09

diff 01.out ../01.out
for i in {2..9}; do
	[[ $i != 5 ]] && diff_text 0$i
	diff "0${i}.out" "../0${i}.out"
	diff "0${i}.err" "../0${i}.err"
	diff "content.opf-0${i}" "../content.opf-0${i}"
done

echo "Basic OPF testing completed"

echo "Basic EPUB testing started"

cp "$epub_merge_test_dir/samples/original/sample1.epub" sample.epub

epub_meta -a '배수아--배, 수아//Suah Bae--Bae, Suah' -t '뱀과물 (Snake And Water)' -r 'Deborah Smith' -i 'ISBN 978-89-9470-250-6 13191' -l ko -m '2024-06-05' -u '2024-05-01' -p '문학동네' -s '문학//꿈//몽환' -x '권리를 존중해주세요' sample.epub 2> aa.err
epub_meta sample.epub > aa.out

grep -q '^주제: 문학$' aa.out
grep -q '^주제: 꿈$' aa.out
grep -q '^주제: 몽환$' aa.out
grep -q '^출판일: 2024-05-01$' aa.out
grep -q '^수정일: 2024-06-05$' aa.out
grep -q '^권리: 권리를 존중해주세요$' aa.out
grep -q '^도서번호: ISBN 978-89-9470-250-6 13191$' aa.out
grep -q '^출판사: 문학동네$' aa.out

diff aa.out ../aa.out
diff aa.err ../aa.err
diff_text aa

echo "Basic EPUB testing completed"

[[ -n "$NO_TIME_TESTING" ]] && exit

time ( for i in {1..50}; do epub_meta content.opf > /dev/null; done )

echo
echo "50 reads completed"

time ( for i in {1..50}; do epub_meta -i 'ISBN 978-89-9470-250-6 13191' -l en -m '2024-06-05' -u '2024-05-01' -p '문학동네' -x '권리를 존중해주세요' -q content.opf; done )

echo
echo "50 writes completed"
