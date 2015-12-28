package App::RL;

our $VERSION = '0.1.0';

use App::Cmd::Setup -app;

1;

__END__

=head1 NAME

App::RL - operating chromosome runlist files

=head1 SYNOPSIS

    runlist <command> [-?h] [long options...]
        -? -h --help    show help
    
    Available commands:
    
      commands: list the application's commands
          help: display a command's help screen
    
         merge: merge runlist yaml files
          stat: coverage on chromosomes for runlists

See C<runlist commands> for usage information.

=cut

=head1 LICENSE

Copyright 2015- Qiang Wang

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

Qiang Wang

=cut
