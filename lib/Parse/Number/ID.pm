package Parse::Number::ID;

use 5.010;
use strict;
use warnings;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(parse_number_id $Pat);

our $VERSION = '0.04'; # VERSION

our %SPEC;

our $Pat = qr/(?:
                  [+-]?
                  (?:
                      \d{1,2}([.]\d{3})*(?:[,]\d*)? | # indo
                      \d{1,2}([,]\d{3})*(?:[.]\d*)? | # english
                      [,.]\d+ |
                      \d+
                  )
                  (?:[Ee][+-]?\d+)?
              )/x;

sub _clean_nd {
    my $n = shift;
    $n =~ s/\D//;
    $n;
}

sub _parse_mantissa {
    my $n = shift;
    if ($n =~ /^([+-]?)([\d,.]*)\.(\d{0,2})$/) {
        return (_clean_nd($2 || 0) + "0.$3")*
            ($1 eq '-' ? -1 : 1);
    } else {
        $n =~ s/\.//g;
        $n =~ s/,/./g;
        no warnings;
        return $n+0;
    }
}

$SPEC{parse_number_id} = {
    summary => 'Parse number from Indonesian text',
    args    => {
        text => ['str*' => {
            summary => 'The input text that contains number',
        }],
    },
    result_naked => 1,
};
sub parse_number_id {
    my %args = @_;
    my $text = $args{text};

    $text =~ s/^\s+//s;
    return undef unless length($text);

    $text =~ s/^([+-]?[0-9,.]+)// or return undef;
    my $n = _parse_mantissa($1);
    return undef unless defined $n;
    if ($text =~ /[Ee]([+-]?\d+)/) {
        $n *= 10**$1;
    }
    $n;
}

1;
# ABSTRACT: Parse number from Indonesian text


=pod

=head1 NAME

Parse::Number::ID - Parse number from Indonesian text

=head1 VERSION

version 0.04

=head1 SYNOPSIS

 use Parse::Number::ID qw(parse_number_id);

 my @a = map {parse_number_id(text=>$_)}
     ("12.345,67", "-1,2e3", "x123", "1.23");
 # @a = (12345.67, -1200, undef, 1.23)

=head1 DESCRIPTION

This module parses numbers from text, according to Indonesian rule of decimal-
and thousand separators ("," and "." respectively, while English uses "." and
","). Since English numbers are more widespread, it will be parsed too whenever
unambiguous, e.g.:

 12.3     # 12.3
 12.34    # 12.34
 12.345   # 12345

This module does not parse numbers that are written as Indonesian words, e.g.
"seratus dua puluh tiga" (123). See L<Lingua::ID::Words2Nums> for that.

=head1 VARIABLES

None are exported by default, but they are exportable.

=head2 $Pat (REGEX)

A regex for quickly matching/extracting number from text. It's not 100% perfect
(the extracted number might not be valid), but it's simple and fast.

=head1 FUNCTIONS

None of the functions are exported by default, but they are exportable.

=head1 SEE ALSO

L<Lingua::ID::Words2Nums>

=head1 FUNCTIONS


=head2 parse_number_id(%args) -> [status, msg, result, meta]

Parse number from Indonesian text.

Arguments ('*' denotes required arguments):

=over 4

=item * B<text>* => I<str>

The input text that contains number.

=back

Return value:

Returns an enveloped result (an array). First element (status) is an integer containing HTTP status code (200 means OK, 4xx caller error, 5xx function error). Second element (msg) is a string containing error message, or 'OK' if status is 200. Third element (result) is optional, the actual result. Fourth element (meta) is called result metadata and is optional, a hash that contains extra information.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

