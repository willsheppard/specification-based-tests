use Test2::V0;
use Test::LectroTest::Compat;
use Test::LectroTest::Generator qw< :all >;

# TEST #1 BEGINS

sub Positive_Int {
    Gen { abs Int->generate(@_) }
}

my $property_valid_sum = Property({
    ##[ a <- Positive_Int, b <- Positive_Int ]##
    my $c = sub { $_[0] + $_[1] }
        ->( $a, $b );

    print "generated $a + $b = $c\n" if $ENV{DEBUG};

    ( $c >= $a ) && ( $c >= $b ); # NOTE: should return a boolean
},
name => 'sum of 2 positive integers is greater than or equal to either number');

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
