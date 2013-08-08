package WWW::Codeguard::User;

use 5.006;
use strict;
use warnings FATAL => 'all', NONFATAL => 'uninitialized';

use parent qw(WWW::Codeguard);

use Net::OAuth;
use LWP::UserAgent;
use HTTP::Request;

=head1 NAME

WWW::Codeguard::User - Perl interface to interact with the Codeguard API as the 'user'

=cut

=head1 SYNOPSIS

This module provides you with an perl interface to interact with the Codeguard API and perform the 'user' level calls.

	use WWW::Codeguard::User;

	my $api = WWW::Codeguard::User->new(
		$api_url,
		{
			api_secret    => $user_api_secret,
			api_key       => $user_api_key,
			access_secret => $user_access_secret,
			access_token  => $user_access_token,
		}
	);

=cut

sub new {

	my $class = shift;
	my $self = {};
	bless $self, $class;
	$self->_initialize(@_);
	return $self;
}

sub _initialize {

	my ($self, $api_url, $opts) = @_;

	$self->{api_url} = $api_url;
	foreach my $key (qw(api_secret api_key access_secret access_token)) {
		$self->{$key} = delete $opts->{$key} or $self->_error($key.' is a required parameter', 1);
	}

	# initialize the UA
	$self->{_ua} = LWP::UserAgent->new(
		agent    => 'WWW-Codeguard-User '.$self->VERSION(),
		max_redirect => 0,
		ssl_opts => {
			verify_hostname => 1
		},
	);

	return $self;
}

=head1 METHODS

Each of these map to a call on Codeguard's User API.
 
=cut

=head2 create_website

This allows you to create a website resource under your User account. Params should be a hashref that contains the following attributes:

Required: The request will not succeed without these attributes.

url

hostname

account

password or key

provider

Optional:

port

=cut

sub create_website {

	my ($self, $params) = @_;
	return $self->_do_method('create_website', $params);
}

=head2 list_websites

This allows you to list the website resources under your User account. Params should be a hashref that contains the following attributes:

Required:

None

Optional:

None

=cut

sub list_websites {

	my ($self, $params) = @_;
	return $self->_do_method('list_websites', $params);
}

=head2 list_website_rules

This allows you to list the exclusion rules for a website resource under your User account. Params should be a hashref that contains the following attributes:

Required:

website_id

Optional:

None

=cut

sub list_website_rules {

	my ($self, $params) = @_;
	return $self->_do_method('list_website_rules', $params);
}

=head2 set_website_rules

This allows you to set the exclusion rules for a website resource under your User account. Params should be a hashref that contains the following attributes:

Required:

website_id

exclude_rules - must be an array ref with elements specifying what paths/files to ignore. Example:

	[
		'access-logs/*'
		'*error_log*'
		'*stats/*'
		'/path/to/a/folder/*'
		'/path/to/a/file.txt'
	]

Optional:

None

=cut

sub set_website_rules {

	my ($self, $params) = @_;
	return $self->_do_method('set_website_rules', $params);
}

=head2 create_database

This allows you to create a database resource under your User account. Params should be a hashref that contains the following attributes:

Required: The request will not succeed without these attributes.

website_id

server_address

account

password

port

database_name

Optional Attributes

authentication_mode

server_account

server_password

=cut

sub create_database {

	my ($self, $params) = @_;
	return $self->_do_method('create_database', $params);
}

=head2 list_databases

This allows you to fetch all Database Records owned by the user.

Required:

None

Optional:

None

=cut

sub list_databases {

	my ($self, $params) = @_;
	return $self->_do_method('list_databases', $params);
}

=head2 show_database

This allows you to fetch information for the specified database resource under your User account. Params should be a hashref that contains the following attributes:

Required:

website_id

database_id

Optional:

None

=cut

sub show_database {

	my ($self, $params) = @_;
	return $self->_do_method('show_database', $params);
}

=head2 edit_database

This allows you to edit information for the specified database resource under your User account. Params should be a hashref that contains the following attributes:

Required:

database_id

Optional:

server_address

account

password

port

database_name

authentication_mode

server_account

server_password

=cut

sub edit_database {

	my ($self, $params) = @_;
	return $self->_do_method('edit_database', $params);
}

# 'fake' login call, cause right now CG doesn't have a proper login url generator in place
sub generate_login_link {

	my $self = shift;
	return $self->_set_uri('list_websites');
}

=head1 Accessors

Basic accessor methods to retrieve the current settings

=cut

=head2 get_api_secret

Returns the current value in $self->{api_secret}.

=cut

sub get_api_secret { shift->{api_secret}; }

=head2 get_api_key

Returns the current value in $self->{api_key}.

=cut

sub get_api_key { shift->{api_key}; }

=head2 get_access_secret

Returns the current value in $self->{access_secret}.

=cut

sub get_access_secret { shift->{access_secret}; }

=head2 get_access_token

Returns the current value in $self->{access_token}.

=cut

sub get_access_token { shift->{access_token}; }

# Internal Methods

sub _create_request {

	my ($self, $action, $params) = @_;
	my $action_map = {
		'create_website'     => 'POST',
		'list_websites'      => 'GET',
		'list_website_rules' => 'GET',
		'set_website_rules'  => 'POST',
		'create_database'    => 'POST',
		'list_databases'     => 'GET',
		'show_database'      => 'GET',
		'edit_database'      => 'PUT',
	};
	my $request = HTTP::Request->new( $action_map->{$action} );
	$request->header('Content-Type' => 'application/json' );
	$self->_set_uri($action, $request, $params);
	$self->_set_content($request, $params);
	return $request;
}

sub _set_uri {

	my ($self, $action, $request, $params) = @_;
	my $base_url = $self->get_api_url();
	my $uri_map  = {
		'create_website'     => '/websites',
		'list_websites'      => '/websites',
		'list_website_rules' => '/websites/'.($params->{website_id} || '').'/rules',
		'set_website_rules'  => '/websites/'.($params->{website_id} || '').'/rules',
		'create_database'    => '/database_backups',
		'list_databases'     => '/database_backups',
		'show_database'      => '/websites/'.($params->{website_id} || '').'/database_backups/'.($params->{database_id} || ''),
		'edit_database'      => '/database_backups'.($params->{database_id} || ''),
	};

	my $oauth_req = Net::OAuth->request('protected resource')->new(
		'consumer_key'     => $self->{api_key},
		'consumer_secret'  => $self->{api_secret},
		'token'            => $self->{access_token},
		'token_secret'     => $self->{access_secret},
		'signature_method' => 'HMAC-SHA1',
		'timestamp'        => time(),
		'nonce'            => _oauth_nonce(),
		'request_method'   => ($request) ? $request->method() : 'GET',
		'request_url'      => $base_url.$uri_map->{$action},
	);
	$oauth_req->sign;
	return ($request) ? $request->uri($oauth_req->to_url) : $oauth_req->to_url;
}

sub _fetch_required_params {

	my ($self, $action, $params) = @_;
	my $required_keys_map = {
		create_website     => { map { ($_ => 1) } qw(url hostname account provider) },
		list_websites      => { },
		list_website_rules => { map { ($_ => 1) } qw(website_id) },
		set_website_rules  => { map { ($_ => 1) } qw(website_id exclude_rules) },
		create_database    => { map { ($_ => 1) } qw(server_address account password port database_name) },
		list_databases     => { },
		show_database      => { map { ($_ => 1) } qw(website_id database_id) },
		edit_database      => { map { ($_ => 1) } qw(database_id) },
	};

	# if action is 'create_website',
	# then we checke $params
	# and mark either 'password' or 'key' as the required param.
	if ($action eq 'create_website') {
		if (exists $params->{key} and $params->{key}) {
			$required_keys_map->{create_website}->{key} = 1;
			delete $params->{password};
		} elsif (exists $params->{password} and $params->{password}) {
			$required_keys_map->{create_website}->{password} = 1;
		} else {
			# if neither key or password are present, then push a 'fake' value in, to indicate this.
			$required_keys_map->{create_website}->{'Key or Password'} = 1;
		}
	}
	return $required_keys_map->{$action};
}

sub _fetch_optional_params {

	my ($self, $action) = @_;
	my $optional_keys_map = {
		create_website  => { map { ($_ => 1) } qw(port) },
		create_database => { map { ($_ => 1) } qw(website_id authentication_mode server_account server_password) },
		edit_database   => { map { ($_ => 1) } qw(server_address account password port database_name authentication_mode server_account server_password) },
	};
	return $optional_keys_map->{$action};
}

sub _oauth_nonce {

	my $nonce = '';
	$nonce .= sprintf("%02x", int(rand(255))) for 1..16;
	return $nonce;
}

=head1 AUTHOR

Rishwanth Yeddula, C<< <ryeddula at cpan.org> >>

=cut

1;
