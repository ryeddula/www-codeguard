use Test::More;
use FindBin;
use lib $FindBin::Bin;
use CommonSubs;

BEGIN { use_ok ( 'WWW::Codeguard' ); }
require_ok ( 'WWW::Codeguard' );

my $partner_api = CommonSubs::initiate_api_partner();
my $partner_key = $ENV{'CG_PARTNER_KEY'} || 'mypartnerkey';
my $api_url     = $ENV{'CG_API_URL'}     || 'http://testing-codeguard.not.real.dns';

ok ( defined ($partner_api) && ref $partner_api eq 'WWW::Codeguard::Partner', "Partner API object creation" );
ok ( $partner_api->get_api_url() eq $api_url,  "Codeguard API url");
ok ( $partner_api->get_partner_key() eq $partner_key, "Codeguard partner key");

my $user_api = CommonSubs::initiate_api_user();
my $user_key    = $ENV{'CG_USER_API_KEY'} || 'myuserkey';
my $user_secret = $ENV{'CG_USER_API_SECRET'} || 'myusersecret';
my $user_access_secret = $ENV{'CG_USER_ACCESS_TOKEN'} || 'myuseraccesssecret';
my $user_access_token  = $ENV{'CG_USER_ACCESS_TOKEN'} || 'myuseraccesstoken';

ok ( defined ($user_api) && ref $partner_api eq 'WWW::Codeguard::Partner', "Partner API object creation" );
ok ( $user_api->get_api_url() eq $api_url,  "Codeguard API url");
ok ( $user_api->get_api_key() eq $user_key, "Codeguard user api key");
ok ( $user_api->get_api_secret() eq $user_secret, "Codeguard user api secret");
ok ( $user_api->get_access_secret() eq $user_access_secret, "Codeguard user access secret");
ok ( $user_api->get_access_token() eq $user_access_token, "Codeguard user access token");

my $apis = CommonSubs::initiate_api_both();
ok ( defined ($apis) && (ref $apis eq 'ARRAY' && scalar(@{$apis}) == 2), "Both APIs initialized");
ok ( defined ($apis->[0]) && ref $apis->[0] eq 'WWW::Codeguard::Partner', "Partner API object creation" );
ok ( defined ($apis->[1]) && ref $apis->[1] eq 'WWW::Codeguard::User', "User API object creation" );

done_testing();
