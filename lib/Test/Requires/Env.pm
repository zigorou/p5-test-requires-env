package Test::Requires::Env;

use strict;
use warnings;
use parent qw(Test::Builder::Module);

our $VERSION = '0.01';

sub import {
    my $class = shift;
    for my $entry ( @_ ) {
        if ( ref $entry eq 'HASH' ) {
            $class->test_environments( $entry );
        }
        else {
            $class->has_environments( $entry );
        }
    }
}

sub test_environments {
    my ( $class, $entry ) = @_;

    for my $env_name ( keys %$entry ) {
        unless ( exists $ENV{$env_name} ) {
            $class->skip_all( sprintf('%s environment is not existed', $env_name) );
        }

        if ( ref $entry->{$env_name} eq 'Regexp' ) {
            my $regex = $entry->{$env_name};
            $ENV{$env_name} =~ m#$regex#
                or $class->skip_all( sprintf('%s environment is not match by the pattern (pattern: %s)', $env_name, "$regex") );
        }
        else {
            ( $ENV{$env_name} eq $entry->{$env_name} )
                or $class->skip_all( sprintf("%s environment is not equals %s", $env_name, $entry->{$env_name}) );
        }
    }
}

sub has_environments {
    my ( $class, $env_name ) = @_;
    unless ( exists $ENV{$env_name} ) {
        $class->skip_all( sprintf('%s environment is not existed', $env_name) );
    }
}

sub skip_all {
    my ( $class, $message ) = @_;

    (sub {
         my $builder = __PACKAGE__->builder;

         if ( not defined $builder->has_plan ) {
             $builder->skip_all(@_);
         }
         elsif ( $builder->has_plan eq 'no_plan' ) {
             $builder->skip(@_);
             if ( $builder->can('parent') && $builder->parent ) {
                 die bless {} => 'Test::Builder::Exception';
             }
             exit 0;
         }
         else {
             for ( 1 .. $builder->has_plan ) {
                 $builder->skip(@_);
             }
             if ( $builder->can('parent') && $builder->parent ) {
                 die bless {} => 'Test::Builder::Exception';
             }
             exit 0;
         }
     })->( $message );
}

1;
__END__

=head1 NAME

Test::Requires::Env -

=head1 SYNOPSIS

  use Test::Requires::Env;

=head1 DESCRIPTION

Test::Requires::Env is

=head1 AUTHOR

Toru Yamaguchi E<lt>zigorou@cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
