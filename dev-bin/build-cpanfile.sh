#!/bin/bash

function err {
    echo $1
    exit 1
}

function download-cpan-package-index {
    curl --silent --show-error --fail -O https://www.cpan.org/modules/02packages.details.txt.gz || err "Failed to download 02packages.details.txt.gz";
}

function print-cpanfile {
    if [[ ! -f 02packages.details.txt.gz ]]; then
        download-cpan-package-index
    fi

    # Take the "shortest" module name from a dist as the "main module" of that dist
    modules=$(gzcat 02packages.details.txt.gz | egrep ^Perl::Critic | perl -E 'my %mod; while(<>) { my ($m, undef, $dist) = split(/\s+/); if (! $mod{$dist} or length($m) < length($mod{$dist})) { $mod{$dist} = $m } } say for sort { length($a) <=> length($b) } values %mod')

    for module in $modules
    do
        echo requires \"$module\"\;
    done
}

cd $(dirname $0)

(
    echo '# Generated by ./dev-bin/build-cpanfile.sh'
    print-cpanfile
) > ../cpanfile
