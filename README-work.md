# Raku ML::HashTriesWithFrequencies


This Raku package has functions for creation and manipulation of 
[Tries (Prefix trees)](https://en.wikipedia.org/wiki/Trie) 
with frequencies.

The package provides Machine Learning (ML) functionalities, not "just" a Trie data structure.

This Raku implementation closely follows the Mathematica implementation [AAp2].

**Remark:** There is a Raku package with an alternative implementation, [AAp6],
which is the *primary* Tries-with-frequencies package.
The package in this repository, `ML::HashTriesWithFrequencies`, is made mostly for comparison studies.

------

## Usage 

Consider a trie (prefix tree) created over a list of words:

```perl6
use ML::HashTriesWithFrequencies;
my $tr = TrieCreateBySplit( <bar bark bars balm cert cell> );
TrieForm($tr);
```

Here we convert the trie with frequencies above into a trie with probabilities:

```perl6
my $ptr = TrieNodeProbabilities( $tr );
TrieForm($ptr);
```

------

## Representation

Each trie is tree based on 
[Hash](https://docs.raku.org/type/Hash) 
objects. For example:

```perl6
say TrieCreateBySplit(<core cort>).gist;
```

On such representation are based the Trie functionalities implementations of the Mathematica package [AAp2].

------

## Implementation notes

This package is a Raku re-implementation of the Mathematica Trie package [AAp2].

The current implementation is:
- ≈ 4 times slower than the Mathematica implementation [AAp2]
- ≈ 70 times slower than the Java implementation [AAp3]
- ≈ 1.8 times slower than the Raku implementation [AAp6]

------

## TODO

I do not plan to develop this package further, since [AAp6] is much faster. 
Nevertheless, some fundamental functions are missing, and might be a good idea to implement them. 

In the following list the most important items are placed first.

- [ ] Implement retrieval functions.

- [ ] Implement trie-shrinking (i.e. prefix finding) function.
  
- [ ] Implement "get words" and "get root-to-leaf paths" functions.

- [ ] Convert most of the WL unit tests in [AAp5] into Raku tests.

- [ ] Implement Trie traversal functions.

- [ ] Implement Trie-based classification.
  
- [ ] Implement sub-trie removal functions.

------

## References

### Articles

[AA1] Anton Antonov,
["Tries with frequencies for data mining"](https://mathematicaforprediction.wordpress.com/2013/12/06/tries-with-frequencies-for-data-mining/),
(2013),
[MathematicaForPrediction at WordPress](https://mathematicaforprediction.wordpress.com).

[AA2] Anton Antonov,
["Removal of sub-trees in tries"](https://mathematicaforprediction.wordpress.com/2014/10/12/removal-of-sub-trees-in-tries/),
(2013),
[MathematicaForPrediction at WordPress](https://mathematicaforprediction.wordpress.com).

[AA3] Anton Antonov,
["Tries with frequencies in Java"](https://mathematicaforprediction.wordpress.com/2017/01/31/tries-with-frequencies-in-java/)
(2017),
[MathematicaForPrediction at WordPress](https://mathematicaforprediction.wordpress.com).
[GitHub Markdown](https://github.com/antononcube/MathematicaForPrediction).

[RAC1] Tib,
["Day 10: My 10 commandments for Raku performances"](https://raku-advent.blog/2020/12/10/day-10-my-10-commandments-for-raku-performances/),
(2020),
[Raku Advent Calendar](https://raku-advent.blog).

[WK1] Wikipedia entry, [Trie](https://en.wikipedia.org/wiki/Trie).

### Packages

[AAp1] Anton Antonov, 
[Tries with frequencies Mathematica Version 9.0 package](https://github.com/antononcube/MathematicaForPrediction/blob/master/TriesWithFrequenciesV9.m),
(2013), 
[MathematicaForPrediction at GitHub](https://github.com/antononcube/MathematicaForPrediction).

[AAp2] Anton Antonov,
[Tries with frequencies Mathematica package](https://github.com/antononcube/MathematicaForPrediction/blob/master/TriesWithFrequencies.m),
(2013-2018),
[MathematicaForPrediction at GitHub](https://github.com/antononcube/MathematicaForPrediction).

[AAp3] Anton Antonov, 
[Tries with frequencies in Java](https://github.com/antononcube/MathematicaForPrediction/tree/master/Java/TriesWithFrequencies), 
(2017),
[MathematicaForPrediction at GitHub](https://github.com/antononcube/MathematicaForPrediction).

[AAp4] Anton Antonov, 
[Java tries with frequencies Mathematica package](https://github.com/antononcube/MathematicaForPrediction/blob/master/JavaTriesWithFrequencies.m), 
(2017),
[MathematicaForPrediction at GitHub](https://github.com/antononcube/MathematicaForPrediction).

[AAp5] Anton Antonov, 
[Java tries with frequencies Mathematica unit tests](https://github.com/antononcube/MathematicaForPrediction/blob/master/UnitTests/JavaTriesWithFrequencies-Unit-Tests.wlt), 
(2017), 
[MathematicaForPrediction at GitHub](https://github.com/antononcube/MathematicaForPrediction).

[AAp6] Anton Antonov,
[ML::TriesWithFrequencies Raku package](https://github.com/antononcube/Raku-ML-TriesWithFrequencies),
(2021),
[GitHub/antononcube](https://github.com/antononcube).


### Videos

[AAv1] Anton Antonov,
["Prefix Trees with Frequencies for Data Analysis and Machine Learning"](https://www.youtube.com/watch?v=MdVp7t8xQbQ),
(2017),
Wolfram Technology Conference 2017,
[Wolfram channel at YouTube](https://www.youtube.com/channel/UCJekgf6k62CQHdENWf2NgAQ).
