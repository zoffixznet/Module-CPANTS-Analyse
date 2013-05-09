package Module::CPANTS::Kwalitee::Version;
use warnings;
use strict;
use File::Find;
use File::Spec::Functions qw(catdir catfile abs2rel splitdir);
use File::stat;
use File::Basename;

our $VERSION = '0.87';

sub order { 100 }

##################################################################
# Analyse
##################################################################

my $match_version = qr/\$VERSION/;

sub analyse {
    my $class=shift;
    my $me=shift;
    my $distdir=$me->distdir;
    

    my %version_of;
    foreach my $module (@{$me->d->{modules}}) {
        my $version;
        if (open my $fh, '<', catfile($distdir, $module->{file})) {
            while (my $line = <$fh>) {
                if ($line =~ $match_version) {
                    $version = $line;  
                    last;
                }
            }
        }
        $version_of{$module->{file}} = $version if $module->{file};
    }

    $me->d->{versions} = \%version_of;

    return;
}



##################################################################
# Kwalitee Indicators
##################################################################

sub kwalitee_indicators {
  return [
    {
        name=>'has_version_in_each_file',
        error=>qq{This distribution has a .pm file without a version number. (Using $match_version to match them)},
        remedy=>q{Add a version number to each .pm file.},
        is_experimental=>1,
        code=>sub {
            my $d=shift;
            #use Data::Dumper;
            #die Dumper $d->{versions};
            my $number_modules = scalar @{$d->{modules} || []};
            my $number_pm_with_version = scalar grep { defined $d->{versions}{$_} } keys %{ $d->{versions} };
            
            if ($number_modules == $number_pm_with_version) {
                return 1;
            }
            else {
                my @errors = map { $_ }
                    grep { ! defined $d->{versions}{$_} }
                    keys %{ $d->{versions} };
                $d->{error}{has_version_in_each_file} = \@errors;
                return 0;
            }
        },
    },
];
}


q{Favourite record of the moment:
  Fat Freddys Drop: Based on a true story};


__END__

=encoding UTF-8

=head1 NAME

Module::CPANTS::Kwalitee::Files - Check for various files

=head1 SYNOPSIS

Find various files and directories that should be part of every self-respecting distribution.

=head1 DESCRIPTION

=head2 Methods

=head3 order

Defines the order in which Kwalitee tests should be run.

Returns C<10>, as data generated by C<MCK::Files> is used by all other tests.

=head3 map_filenames

get db_filenames from real_filenames

=head3 analyse

C<MCK::Files> uses C<File::Find> to get a list of all files and dirs in a dist. It checks if certain crucial files are there, and does some other file-specific stuff.

=head3 get_files

The subroutine used by C<File::Find>. Unfortunantly, it depends on some global values.

=head3 kwalitee_indicators

Returns the Kwalitee Indicators datastructure.

=over

=item * extractable

=item * extracts_nicely

=item * has_readme

=item * has_manifest

=item * has_meta_yml

=item * has_buildtool

=item * has_changelog 

=item * no_symlinks

=item * has_tests

=item * has_tests_in_t_dir

=item * buildfile_not_executabel

=item * has_example (optional)

=item * no_generated_file

=item * has_version_in_each_file

=item * no_stdin_for_prompting

=back

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

L<Thomas Klausner|https://metacpan.org/author/domm>

=head1 COPYRIGHT AND LICENSE

Copyright © 2003–2006, 2009 L<Thomas Klausner|https://metacpan.org/author/domm>

You may use and distribute this module according to the same terms
that Perl is distributed under.
