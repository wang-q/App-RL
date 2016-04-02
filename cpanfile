requires 'App::Cmd';
requires 'List::MoreUtils';
requires 'Path::Tiny';
requires 'Set::Scalar';
requires 'YAML::Syck';
requires 'perl', '5.008001';

requires 'AlignDB::IntSpan';
requires 'AlignDB::IntSpanXS';

on test => sub {
    requires 'Test::More', 0.88;
};
