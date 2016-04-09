requires 'App::Cmd';
requires 'IO::Zlib';
requires 'List::MoreUtils';
requires 'Path::Tiny';
requires 'Set::Scalar';
requires 'Tie::IxHash';
requires 'YAML::Syck';
requires 'perl', '5.010001';

requires 'AlignDB::IntSpanXS';

on test => sub {
    requires 'Test::More', 0.88;
};
