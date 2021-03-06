#! /bin/sh
# manxref - produce a list of man page cross references on stdout
#
# Usage: manxref > manxref.out
#
# Must be run from this directory.
#
# Wed Apr  9 22:09:31 1986  Charles (Herb) Kuta at SGI  (olympus!kuta)
#
# $Revision: 1.1 $
# $Date: 89/03/27 16:39:42 $

cd ..
find [gau]_man troff \( -name '*.[1-8]' -o -name '*.[1-8][a-z]' \) -print \
    | xargs egrep "\(([1-8]|[1-8][a-zA-Z])\)" /dev/null \
    | sed \
	-e 's/^\([^:]*\):/\1 /' \
	-e 's/\\".*//' \
	-e 's/\\s[+-][0-9]//g' \
	-e 's/\\s0//g' \
	-e 's/\\f[RIBSP123]//g' \
	-e 's/\\[|^]//g' \
	-e 's/"//g' \
	-e 's/\\\*p//g' \
	-e 's/ *\(([1-8]\)/\1/g' | \
    awk '{for (i = 2; i <= NF; i++)
	    if ($i ~ /.\([1-8]\)/ || $i ~ /.\([1-8][a-zA-Z]\)/) print $1,$i;
	 }' | \
    sed 's/^\([^ ]*\) \([^(]*([^)]*)\).*$/\2 \1/' | \
    sed 's/^(*//' |
    sort -u | \
    awk '{ if (length($1) < 8)
    		printf "%s\t\t%s\n",$1,$2 ;
	   else
    		printf "%s\t%s\n",$1,$2 }' | \
    sed -e '/package(3M)/d' \
	-e '/LR(1)/d' \
	-e '/^\./d' \
	-e '/^\\w/d' \
	-e '/^and(/d' \
	-e '/^or(/d' \
	-e '/^first(2n)/d' \
	-e '/^mstring(1)/d' \
	-e '/^reasons:(1)/d' \
	-e '/intro\.[1-8]/d' \
	-e '/[Ii]tem.*t3279/d' \
	-e '/either(1).*at\.1/d' \
	-e '/one(1)/d' \
	-e '/program(1)/d' \
	-e '/return.*matherr/d' 
