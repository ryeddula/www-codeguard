package CommonSubs;

sub initiate_api_partner {

	require WWW::Codeguard;

	my $api = WWW::Codeguard->new(
		{
			api_url       => $ENV{'CG_API_URL'} || 'http://testing-codeguard.not.real.dns',
			partner       => {
				partner_key => $ENV{'CG_PARTNER_KEY'} || 'mypartnerkey',
			},
		}
	);

	return $api;
}

sub initiate_api_user {

	require WWW::Codeguard;

	my $api = WWW::Codeguard->new(
		{
			api_url       => $ENV{'CG_API_URL'} || 'http://testing-codeguard.not.real.dns',
			user       => {
				api_key       => $ENV{'CG_USER_API_KEY'} || 'myuserkey',
				api_secret    => $ENV{'CG_USER_API_SECRET'} || 'myusersecret',
				access_secret => $ENV{'CG_USER_ACCESS_TOKEN'} || 'myuseraccesssecret',
				access_token  => $ENV{'CG_USER_ACCESS_TOKEN'} || 'myuseraccesstoken',
			},
		}
	);

	return $api;
}

sub initiate_api_both {

	require WWW::Codeguard;

	my @apis = WWW::Codeguard->new(
		{
			api_url       => $ENV{'CG_API_URL'} || 'http://testing-codeguard.not.real.dns',
			user       => {
				api_key       => $ENV{'CG_USER_API_KEY'} || 'myuserkey',
				api_secret    => $ENV{'CG_USER_API_SECRET'} || 'myusersecret',
				access_secret => $ENV{'CG_USER_ACCESS_TOKEN'} || 'myuseraccesssecret',
				access_token  => $ENV{'CG_USER_ACCESS_TOKEN'} || 'myuseraccesstoken',
			},
			partner       => {
				partner_key => $ENV{'CG_PARTNER_KEY'} || 'mypartnerkey',
			},
		}
	);

	return \@apis;
}

1;
