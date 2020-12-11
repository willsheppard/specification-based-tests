use Test2::V0;
use Test::LectroTest::Compat;
use Test::LectroTest::Generator qw< :all >;

# TEST #1 BEGINS

# 1a. The thing we are testing
sub the_thing_we_are_testing {
    my ($first, $second) = @_;
    return $first + $second;
}

# 1b. Generator of inputs to the thing we are testing
sub Positive_Int {
    Gen { abs Int->generate(@_) }
}

# 1c. Call the thing we are testing, with generated inputs, and check result
my $property_valid_sum = Property {

    # 1d. Special comment to define "generator bindings" inside magic delimiters ##[ ]##
    #      Question: Why is this strange syntax necessary?
    ##[ input_value_a <- Positive_Int, input_value_b <- Positive_Int ]##

    # 1e. Call the thing we are testing
    my $output_total = the_thing_we_are_testing( $input_value_a, $input_value_b );

    # Debug
    print "generated $input_value_a + $input_value_b = $output_total\n" if $ENV{DEBUG};

    # 1f. Test some properties of the thing we are testing
    ( $output_total >= $input_value_a ) && ( $output_total >= $input_value_b ); # NOTE: should return a boolean

},
name => 'sum of 2 positive integers is greater than or equal to either number'; # optional description

# 1g. Run everything (check that the properties hold).
#   holds() is the extra function from Test::LectroTest::Compat that makes it possible
#   to use this alongside regular Perl tests.
holds( $property_valid_sum );

# TEST #1 ENDS



# TEST #2 BEGINS

sub Signature {
    Gen {
        {   hash => String( charset => 'a-z', length => 64 )->generate(@_),
            time => String( charset => '0-9', length => 13 )->generate(@_),
        };
    };
}

my $thing_to_test = sub {
    sprintf <<'XML', $_[0]->{hash}, $_[0]->{time};
<Signature>
  <Hash>%s</Hash>
  <Time>%s</Time>
</Signature>
XML
};

holds(
    Property {
        ##[ signature <- Signature ]##
        my $value = $thing_to_test->($signature);

        print "generated signature '".Dumper($signature)."' => value '$value'\n" if $ENV{DEBUG}; use Data::Dumper;

        ( $value =~ qr/<Hash>[a-z]{64}<\/Hash>/ )
            && ( $value =~ qr/<Time>[0-9]{13}<\/Time>/ );
    },
    name => '$thing_to_test generates output containing <Hash/> and <Time/> elements',
);

# TEST #2 ENDS

done_testing;
