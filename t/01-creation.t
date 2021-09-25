use Test;

use lib '.';
use lib './lib';

use ML::HashTriesWithFrequencies;

plan 7;

## 1
ok TrieCreate([['bar'.comb],]), 'make with one word';

## 2
isa-ok TrieCreateBySplit(['bar']).Str, Str, 'make with one word';

## 3
is-deeply TrieCreateBySplit(['bar']),
        TrieCreate([['bar'.comb],]),
        'equivalence of creation';

## 4
is-deeply
        TrieMerge(TrieCreate([['bar'.comb],]), TrieCreate([['bar'.comb],])),
        TrieCreateBySplit(<bar bar>),
        'merge equivalence to creation-by-splitting';

## 5
ok TrieInsert(TrieCreateBySplit('bar'), ['balk'.comb]),
        'insert test 1';

## 6
isa-ok TrieCreateBySplit(<bar bark balk cat cast>),
        Hash,
        'Hash format test 1';

## 7
my $tr5 = TrieCreate(<bar barman bask bell best>.map({ [$_.comb] }));
my $tr6 = TrieCreateBySplit(<bar barman bask bell best>);
is-deeply
        $tr5,
        $tr6,
        'equivalence test';

done-testing;
