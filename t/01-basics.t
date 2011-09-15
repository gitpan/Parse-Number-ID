#!perl

use 5.010;
use strict;
use warnings;
use Parse::Number::ID qw(parse_number_id);
use Test::More 0.96;

sub test_parse {
    my (%args) = @_;
    my $name = $args{name} // $args{num};

    subtest $name => sub {
        my $res;
        my $eval_err;
        eval { $res = parse_number_id(%{$args{args}}) }; $eval_err = $@;

        if ($args{dies}) {
            ok($eval_err, "dies");
        } else {
            ok(!$eval_err, "doesn't die") or diag $eval_err;
        }

        if (exists $args{res}) {
            is($res, $args{res}, "result");
        }
    };
}

test_parse name => 'empty string', args=>{text => ''}, res => undef;
test_parse name => 'no digits', args=>{text => 'x'}, res => undef;
test_parse name => 'int', args=>{text => '123'}, res => 123;
test_parse name => 'int (2)', args=>{text => '-123'}, res => -123;
test_parse name => 'int (3)', args=>{text => '+123'}, res => 123;
test_parse name => 'double sign = err (1)', args=>{text=>'--123'}, res => undef;
test_parse name => 'double sign = err (2)', args=>{text=>'++123'}, res => undef;
test_parse name => 'whitespace', args=>{text => ' 123 '}, res => 123;
test_parse name => 'nondigit', args=>{text => 'x123'}, res => undef;
test_parse name => 'nondigit 2', args=>{text => '1, 2, 3'}, res => 1;
test_parse name => 'nondigit 2b', args=>{text => '1x23'}, res => 1;
test_parse name => 'decimal (id 1)', args=>{text => '12,3'}, res => 12.3;
test_parse name => 'decimal (id 2)', args=>{text => ',3'}, res => 0.3;
test_parse name => 'decimal (id 3)', args=>{text => '-12,3'}, res => -12.3;
test_parse name => 'decimal (en 1)', args=>{text => '12.31'}, res => 12.31;
test_parse name => 'decimal (en 2)', args=>{text => ',31'}, res => 0.31;
test_parse name => 'decimal (en 3)', args=>{text => '-12.31'}, res => -12.31;
test_parse name=>'thousand sep 1', args=>{text=>'123.001'}, res => 123001;
test_parse name=>'thousand sep 2', args=>{text=>'12.300.000'}, res => 12300000;

test_parse name=>'decimal+thousand sep 1',
    args=>{text=>'-12.300,01'}, res => -12300.01;
test_parse name=>'decimal+thousand sep 2',
    args=>{text=>'12.300.01'}, res => 12300.01;
test_parse name=>'decimal+thousand sep 3',
    args=>{text=>'12,300.01'}, res => 12300.01;
test_parse name=>'decimal+thousand sep 4',
    args=>{text=>'12,300,01'}, res => 12.3;

test_parse name=>'exponent 1', args=>{text=>'1e5'}, res => 1e5;
test_parse name=>'exponent 2', args=>{text=>'-1e5'}, res => -1e5;
test_parse name=>'exponent 3', args=>{text=>'1e-5'}, res => 1e-5;
test_parse name=>'exponent 4', args=>{text=>'-1e-5'}, res => -1e-5;
test_parse name=>'exponent 5', args=>{text=>'1,1e2'}, res => 1.1e2;
test_parse name=>'exponent 6', args=>{text=>'1.1e2'}, res => 1.1e2;
test_parse name=>'exponent 6', args=>{text=>'.12e2'}, res => 12;

DONE_TESTING:
done_testing();
