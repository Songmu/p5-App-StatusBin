requires 'Imager';
requires 'Plack::MIME';
requires 'Puncheur::Lite';
requires 'perl', '5.008001';

on configure => sub {
    requires 'Module::Build::Tiny', '0.035';
};

on test => sub {
    requires 'Test::More', '0.98';
};
