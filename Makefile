.PHONY: numbers dupes decades

numbers:
	@awk '/^[0-9]+\. / { \
		n = $$1 + 0; want++; \
		if (n != want) { \
			printf "%s:%d: expected %d, found %d\n", FILENAME, FNR, want, n; \
			want = n; \
		} \
	} END { printf "%s: %d entries\n", FILENAME, want }' all-time.md

dupes:
	@awk '/^[0-9]+\. / { \
		line = $$0; \
		sub(/^[0-9]+\. /, "", line); \
		gsub(/\*\*/, "", line); \
		sub(/ *\([^()]*\) *$$/, "", line); \
		key = FILENAME "|" tolower(line); \
		if (key in seen) \
			printf "%s:%d: duplicate of line %d: %s\n", FILENAME, FNR, seen[key], line; \
		else \
			seen[key] = FNR; \
	}' all-time.md by-decade.md 21st-century.md top-directors.md

decades:
	@awk '/^## [0-9][0-9][0-9][0-9]s/ { dec = substr($$2, 1, 4) + 0; next } \
	/^[0-9]+\. / { \
		if (!dec) next; \
		if (!match($$0, /\([^()]*\)[ \t]*$$/)) { \
			printf "%s:%d: no year found: %s\n", FILENAME, FNR, $$0; \
			next; \
		} \
		p = substr($$0, RSTART + 1, RLENGTH - 2); \
		year = 0; \
		while (match(p, /[0-9]+/)) { \
			tok = substr(p, RSTART, RLENGTH); \
			if (length(tok) == 4) year = tok + 0; \
			else if (length(tok) == 2 && year) year = year - (year % 100) + (tok + 0); \
			p = substr(p, RSTART + RLENGTH); \
		} \
		if (year < dec || year > dec + 9) \
			printf "%s:%d: %ds section holds a %d film: %s\n", FILENAME, FNR, dec, year, $$0; \
	}' by-decade.md
