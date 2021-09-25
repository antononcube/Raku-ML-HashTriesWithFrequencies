#!/usr/bin/env perl6

use lib '.';
use lib './lib';

use ML::HashTriesWithFrequencies;

my $tr0 = TrieCreateBySplit(<bar barman bask bell best>);

say TrieNodeProbabilities($tr0).raku;

say TrieQ({TRIEVALUE => 1, a => {TRIEVALUE => 1, r => {TRIEVALUE => 1}}});

my $tr = TrieMake('bar'.comb);

say "TrieCreate1 : ", TrieCreate1( [['bar'.comb],['bas'.comb]]);

$tr = TrieCreateBySplit(<bark bas bell best car cat cast>);
TrieForm($tr);

my $tr2 = TrieNodeProbabilities($tr);
TrieForm($tr2);

