#!/bin/bash

set -euo pipefail

export DEBUG="${DEBUG:-}"
EPUB_MERGE_DIR="$(realpath "$(dirname "$0")/..")"

trap 'echo "Error (epub-meta): at line $LINENO" >&2; cat err' ERR INT TERM

cleanup() {
	[[ -n "$temp_dir" ]] && rm -fr "$temp_dir" || true
}

trap cleanup EXIT

epub_meta() {
	"$EPUB_MERGE_DIR/epub-meta" "$@"
}

temp_dir="$(mktemp -d)"

cp samples-meta/* "$temp_dir"

cd "$temp_dir"

cp -f content.opf.org content.opf

diff <( LANG=ko epub_meta -O content.opf ) 01.out

LANG=ko epub_meta -a '배수아::배, 수아;Suah Bae::Bae, Suah' -t '뱀과물 (Snake And Water)' -r 'Deborah Smith' -O content.opf 2> err
diff content.opf content.opf-02
diff 02.err err
diff 02.out <( LANG=ko epub_meta -O content.opf )

LANG=kr epub_meta -d '<![CDATA[
<p>A dystopian novel about totalitarianism.</p>
<p>Published in 1949.</p>
]]>' -O content.opf 2> err
diff content.opf content.opf-03
diff 03.err err
diff 03.out <( LANG=ko epub_meta -O content.opf )

LANG=kr epub_meta -i 'ISBN 978-89-9470-250-6 13191' -l en -m '2025-06-05' -u '2025-05-01' -p '문학동네' -s '문학;꿈;몽환' -x '권리를 존중해주세요' -O content.opf 2> err
diff content.opf content.opf-04
diff 04.err err
diff 04.out <( LANG=ko epub_meta -O content.opf )

# with -q option
LANG=kr epub_meta -i 'ISBN 978-89-9470-250-6 13191' -l en -m '2025-06-05' -u '2025-05-01' -p '문학동네' -s '문학;꿈;몽환' -x '권리를 존중해주세요' -q -O content.opf 2> err
diff content.opf content.opf-05
diff 05.err err
diff 04.out <( LANG=ko epub_meta -O content.opf )

# itempotency
# without -q option
LANG=kr epub_meta -i 'ISBN 978-89-9470-250-6 13191' -l en -m '2025-06-05' -u '2025-05-01' -p '문학동네' -s '문학;꿈;몽환' -x '권리를 존중해주세요' -O content.opf 2> err
diff 06.err err
diff 04.out <( LANG=ko epub_meta -O content.opf )

cp -f content.opf.org content.opf

LANG=kr epub_meta -i 'BAD
ISBN XXXXX' -a "Bad
Author
;Really Really
Bad Author::But has
Lovely Name" -O content.opf 2> err
diff 07.err err
diff 07.out <( LANG=ko epub_meta -O content.opf )

LANG=kr epub_meta -i 'ISBN 978-89-9470-250-6 13191' -a '배수아' -r 'Deborah Smith' -O content.opf 2> err
diff 08.err err
diff 08.out <( LANG=ko epub_meta -O content.opf )

echo "Basic testing completed"

time ( for i in {1..100}; do epub_meta -O content.opf > /dev/null; done )

echo
echo "100 reads completed"

time ( for i in {1..100}; do epub_meta -i 'ISBN 978-89-9470-250-6 13191' -l en -m '2025-06-05' -u '2025-05-01' -p '문학동네' -x '권리를 존중해주세요' -qO content.opf; done )

echo
echo "100 writes completed"
