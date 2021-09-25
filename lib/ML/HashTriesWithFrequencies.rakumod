
unit module ML::HashTriesWithFrequencies;

constant $TrieRoot = 'TRIEROOT';
constant $TrieValue = 'TRIEVALUE';

##=======================================================
## Trie predicates
##=======================================================
sub TrieBodyQ($tr) is export {
    $tr.isa(Hash) and $tr{$TrieValue}:exists;
}

sub TrieQ($tr) is export {
    $tr.isa(Hash) and $tr.elems ==1 and TrieBodyQ($tr.first.value)
}

sub TrieWithTrieRootQ($tr) is export {
    $tr.isa(Hash) and $tr.first.key eq $TrieRoot and TrieBodyQ($tr.first.value)
}

##=======================================================
## Core functions -- creation, merging, insertion, node frequencies
##=======================================================

#| @description Makes a base trie from a list
#| @param chars a list of objects
#| @param val value (e.g. frequency) to be assigned
#| @param bottomVal the bottom value
sub TrieMake(@chars,
             Num :$value = 1e0,
             Num :$bottomValue = 1e0,
             Bool :$verify-input = True
        --> Hash) is export {

    if $verify-input and not @chars.all ~~ Str {
        die "The first argument is expected to be a positional of strings."
    }

    if not so @chars {
        return Nil;
    }

#    my %res = @chars[*-1] => %( $TrieValue => $bottomValue);
#    for @chars[^(*- 1)].reverse -> $c {
#        my %res2 = %res.push( ($TrieValue => $value) );
#        %res.push( ($c => %res2) )
#    }

    my %init = @chars[*-1] => %( $TrieValue => $bottomValue);
    #my %res = reduce( -> %a, $x { { $x => %a.push( ($TrieValue => $value) ) } }, (%init, |@chars[^(*-1)].reverse) );
    my %res = reduce( -> %a, str $x { { $x => %(%a.first, $TrieValue => $value) } }, (%init, |@chars[^(*-1)].reverse) );

    return %res;
}

#--------------------------------------------------------
sub ToTrieWithRoot( %tr ) is export {

    if TrieWithTrieRootQ(%tr) { %tr }
    elsif TrieQ(%tr) { %( $TrieRoot => %tr.push( ($TrieValue => %tr.first.value{$TrieValue}) ) ) }
    else { Nil }
}

#--------------------------------------------------------
#| Merge tries.
proto TrieMerge(|) is export {*}

# This implementation closely follows Hash::Merge.merge-hash .
# See here : https://github.com/scriptkitties/p6-Hash-Merge/blob/master/lib/Hash/Merge.rakumod ,
# or here : https://git.sr.ht/~tyil/raku-hash-merge/tree/master/item/lib/Hash/Merge.rakumod .

#| Merge two tries together.
multi TrieMerge (
#| The original trie to merge the second trie into.
        %first,

#| The second trie, which will be merged into the first trie.
        %second,

#| Boolean to set whether Positional objects should be appended. When
#| set to False, Positional objects in %second will overwrite those
#| from %first.
        Bool:D :$positional-append = True,

        --> Hash )  {
    my %result = %first;

    for %second.keys -> $key {
        # If the key doesn't exist yet in %first, it can be inserted without worry.
        if (%first{$key}:!exists) {
            %result{$key} = %second{$key};
            next;
        }

        given (%first{$key}) {
            # Associative objects need to be merged deeply.
            when Associative {
                %result{$key} = TrieMerge(%first{$key}, %second{$key}, :$positional-append)
            }
            # Positional objects can be merged or overwritten depending on $append-array.
            when Positional {
                %result{$key} = $positional-append
                        ?? (|%first{$key}, |%second{$key})
                        !! %second{$key}
            }
            # Numeric objects (i.e. probabilities or frequencies) are added.
            when Numeric {
                %result{$key} = %first{$key} + %second{$key}
            }
            # Anything else will just overwrite.
            default {
                # This should not be happening.
                warn "Overwriting for key $key";
                %result{$key} = %second{$key};
            }
        }
    }

    %result;
}

#--------------------------------------------------------
#proto TrieInsert(Hash $tr, |) is export {*};

#|Inserts a "word" (a list of strings) into a trie with a given associated value.
sub TrieInsert(Hash $tr,
                @word,
                Num :$value = 1e0,
                Num :$bottomValue = 1e0,
                Bool :$verify-input = True
        --> Hash) is export {

    if $verify-input and not @word.all ~~ Str {
        die "The second argument is expected to be a positional of strings."
    }

    my %res0 = TrieMake(@word, :$value, :$bottomValue, :!verify-input);
    my %res = %( $TrieRoot => %res0.push( ($TrieValue => %res0.first.value{$TrieValue}) ) );

    TrieMerge($tr, %res)
}

#--------------------------------------------------------

#| Creates a trie from a given list of list of strings. (Non-recursively.)
sub TrieCreate1(@words,
                 Bool :$verify-input = True
        --> Hash) is export {

    if $verify-input and not @words.all ~~ Positional {
        die "The first argument is expected to be a positional of positionals of strings."
    }

    if not so @words {
        return Nil;
    }

    my %res0 = TrieMake(@words[0], :$verify-input);

    my %res = $TrieRoot => %res0.push( ($TrieValue => %res0.first.value{$TrieValue}) );

    for @words[1 .. (@words.elems - 1)] -> @w {
        %res = TrieInsert(%res, @w, :$verify-input);
    }

    return %res;
}

#--------------------------------------------------------
#| Creates a trie from a given list of list of strings. (Recursively.)
sub TrieCreate(@words,
                UInt :$bisection-threshold = 15,
                Bool :$verify-input = True
        --> Hash) is export {

    if not so @words { return Nil; }

    if $verify-input and not @words.all ~~ Positional {
        die "The first argument is expected to be a positional of positionals of strings."
    }

    if @words.elems <= $bisection-threshold {
        return TrieCreate1(@words, :!verify-input);
    }

    return TrieMerge(
            TrieCreate(@words[^ceiling(@words.elems / 2)], :$bisection-threshold, :!verify-input),
            TrieCreate(@words[ceiling(@words.elems / 2) .. (@words.elems - 1)], :$bisection-threshold,
                    :!verify-input));
}

#--------------------------------------------------------
#| Creates a trie by splitting each of the strings in the given list of strings.
proto TrieCreateBySplit($words, |) is export {*}

multi TrieCreateBySplit(Str $word, *%args) {
    TrieCreateBySplit([$word], |%args)
}

multi TrieCreateBySplit(@words,
                           :$splitter = '',
                           :$skip-empty = True,
                           :$v = False,
                           UInt :$bisection-threshold = 15
        --> Hash) {

    if not so @words { return Nil }

    if not @words.all ~~ Str {
        die "The first argument is expected to be a positional of strings."
    }

    TrieCreate(@words.map({ [$_.split($splitter, :skip-empty, :v)] }), :$bisection-threshold);
}

#--------------------------------------------------------
#| Converts the counts (frequencies) at the nodes into node probabilities.
#| @param tr a trie object
sub TrieNodeProbabilities(%tr is copy --> Hash) is export {
    if TrieQ(%tr) {
        my %res = TrieNodeProbabilitiesRec(%tr.first.value);
        %res{$TrieValue} = 1e0;
        %($TrieRoot => %res)
    } else {
        note 'The first argument is expected to be a trie.';
        Nil
    }
}

#| @description Recursive step function for converting node frequencies into node probabilities.
#| @param tr a trie object
sub TrieNodeProbabilitiesRec(%tr is copy) {

    if TrieBodyQ(%tr) {
        if %tr.elems == 1 {
            %tr
        } else {
            my $sum = %tr{$TrieValue} ?? %tr{$TrieValue} !! TrieValueTotal(%tr);
            my %res = %tr.grep({ $_.key ne $TrieValue });
            if so %res {
                %res = %res.map({ my %tr1 = TrieNodeProbabilitiesRec($_.value); %tr1{$TrieValue} = %tr1{$TrieValue} / $sum; $_.key => %tr1 });
            }
            %res.push( ($TrieValue => %tr{$TrieValue}) )
        }
    } else {
        note 'The first argument is expected to be a trie.';
        Nil
    }
}


sub TrieValueTotal($tr) {
    $tr.grep({ $_.key != $TrieValue }).map({ $_.value{$TrieValue} }).sum
}

##=======================================================
## Retrieval functions
##=======================================================

#--------------------------------------------------------
#| @description Test is a trie object a leaf.
sub TrieLeafQ(Hash $tr --> Bool) is export {
    return $tr.elems == 1 and $tr.first.key == $TrieValue
}


#--------------------------------------------------------
#| Visualize
sub TrieForm(%tr,
             Str :$lb = '',
             Str :$sep = ' => ',
             Str :$rb = '',
             Bool :$key-value-nodes = True) is export {
    .say for visualize-tree( %tr.first, *.key, *.value.List, :$lb, :$sep, :$rb, :$key-value-nodes);
}

## Adapted from here:
##   https://titanwolf.org/Network/Articles/Article?AID=34018e5b-c0d5-4351-85b6-d72bd049c8c0
sub visualize-tree($tree, &label, &children,
                   :$indent = '',
                   :@mid = ('├─', '│ '),
                   :@end = ('└─', '  '),
                   Str :$lb = '',
                   Str :$sep = ' => ',
                   Str :$rb = '',
                   Bool :$key-value-nodes = True
                   ) {
    sub visit($node, *@pre) {
        my $suffix = '';
        if $key-value-nodes and $node.value.isa(Hash) and $node.value{$TrieValue}:exists {
            $suffix = $sep ~ $node.value{$TrieValue}
        }
        gather {
            if $node.&label ~~ $TrieValue {
                if not $key-value-nodes {
                    take @pre[0] ~ $node.value
                }
            } else {
                take @pre[0] ~ $lb ~ $node.&label ~ $suffix ~ $rb;
                my @children = sort $node.&children;
                my $end = @children.end;
                for @children.kv -> $_, $child {
                    when $end { take visit($child, (@pre[1] X~ @end)) }
                    default { take visit($child, (@pre[1] X~ @mid)) }
                }
            }
        }
    }

    flat visit($tree, $indent xx 2);
}