requires 'App::Cmd';
requires 'IO::Zlib';
requires 'IPC::Cmd';
requires 'List::MoreUtils';
requires 'Path::Tiny';
requires 'Set::Scalar';
requires 'Tie::IxHash';
requires 'YAML::Syck';
requires 'perl', '5.010000';

requires 'AlignDB::IntSpan';

on test => sub {
    requires 'Test::More', 0.88;
};
