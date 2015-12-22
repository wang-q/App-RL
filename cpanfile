requires 'App::Cmd';
requires 'List::MoreUtils';
requires 'Path::Tiny';
requires 'YAML::Syck';
requires 'perl', '5.008001';

on test => sub {
    requires 'Test::More', 0.88;
};
