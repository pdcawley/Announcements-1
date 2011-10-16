use inc::Module::Install;
use Module::Install::GithubMeta;
use Module::Install::ManifestSkip;
use Module::Install::AutoManifest;

name     'Announcements';
all_from 'lib/Announcements.pm';
githubmeta;

requires 'Moose';
requires 'MooseX::Types';
requires 'MooseX::Types::Moose';
requires 'Set::Object';
test_requires 'Test::More' => '0.88';
test_requires 'Test::Fatal';

manifest_skip;
auto_manifest;
WriteAll;

