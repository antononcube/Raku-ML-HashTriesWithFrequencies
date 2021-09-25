use Test;

use lib '.';
use lib './lib';

use ML::HashTriesWithFrequencies;

plan 2;

## 1
my $tr0 = TrieCreateBySplit(<bar barman bask bell best>);
isa-ok $tr0, Hash, 'created trie';

## 2
is-deeply
        TrieNodeProbabilities($tr0),
        {:TRIEROOT(${:TRIEVALUE(1e0), :b(${:TRIEVALUE(1e0), :a(${:TRIEVALUE(0.6e0), :r(${:TRIEVALUE(0.6666666666666666e0), :m(${:TRIEVALUE(0.5e0), :a(${:TRIEVALUE(1e0), :n(${:TRIEVALUE(1e0)})})})}), :s(${:TRIEVALUE(0.3333333333333333e0), :k(${:TRIEVALUE(1e0)})})}), :e(${:TRIEVALUE(0.4e0), :l(${:TRIEVALUE(0.5e0), :l(${:TRIEVALUE(1e0)})}), :s(${:TRIEVALUE(0.5e0), :t(${:TRIEVALUE(1e0)})})})})})},
        'node probabilities comparison';

done-testing;
