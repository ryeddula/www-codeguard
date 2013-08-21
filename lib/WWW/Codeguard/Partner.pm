package WWW::Codeguard::Partner;

use 5.006;
use strict;
use warnings FATAL => 'all', NONFATAL => 'uninitialized';

use parent qw(WWW::Codeguard);

use Data::Dumper;
use HTTP::Request;
use JSON;
use LWP::UserAgent;

=head1 NAME

WWW::Codeguard::Partner - Perl interface to interact with the Codeguard API as the 'partner'

=cut

=head1 SYNOPSIS

This module provides you with an perl interface to interact with the Codeguard API and perform the 'partner' level calls.

	use WWW::Codeguard::Partner;

	my $api = WWW::Codeguard::Partner->new(
		$api_url,
		{
			partner_key => $partner_key,
		}
	);

	$api->create_user($params_for_create_user);
	$api->list_user($params_for_list_user);
	$api->delete_user($params_for_delete_user);

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

	$self->{api_url}     = $api_url;
	$self->{partner_key} = delete $opts->{partner_key} or $self->_error('partner_key is a required parameter', 1);

	# initialize the UA
	$self->{_ua} = LWP::UserAgent->new(
		agent    => 'WWW-Codeguard-Partner '.$self->VERSION(),
		ssl_opts => {
			verify_hostname => 1
		},
	);

	return $self;
}

=head1 METHODS

Each of these map to a call on Codeguard's Partner API.
 
=cut

=head2 create_user

This allows you to create an account, on to which you can add website/database resources. Params should be a hashref that contains the following attributes:

Required: The request will not succeed without these attributes.

name

email

Optional Attributes:

password

time_zone

partner_data - A string that can be used to store user-specific information the partner may need to identify the user (such as package id, etc)

plan_id

=cut

sub create_user {

	my ($self, $params) = @_;
	return $self->_do_method('create_user', $params);
}

=head2 list_user

This allows you to fetch information for a user. Params should be a hashref that contains the following attributes:

Required: The request will not succeed without these attributes.

user_id

Optional:

None

=cut

sub list_user {

	my ($self, $params) = @_;
	return $self->_do_method('list_user', $params);
}

=head2 delete_user

This method is used to delete existing users that were created using the specified partner_key. Parters can not delete users created by other partners.

B<Note:> Deleting a user resource will also delete all associated Website and Database records.

Params should be a hashref that contains the following attributes:

Required: The request will not succeed without these attributes.

user_id

Optional Attributes:

None

=cut

sub delete_user {

	my ($self, $params) = @_;
	return $self->_do_method('delete_user', $params);
}

=head2 change_user_plan

This method is used to change an existing user's plan. Params should be a hashref that contains the following attributes:

Required: The request will not succeed without these attributes.

user_id

plan_id

Optional Attributes

None

=cut

sub change_user_plan {

	my ($self, $params) = @_;
	return $self->_do_method('change_user_plan', $params);
}

=head1 Accessors

Basic accessor methods to retrieve the current settings

=cut

sub get_partner_key { shift->{partner_key}; }

# Internal Methods

sub _create_request {

	my ($self, $action, $params) = @_;
	my $action_map = {
		'change_user_plan' => 'POST',
		'create_user'      => 'POST',
		'delete_user'      => 'DELETE',
		'list_user'        => 'GET',
	};
	my $request = HTTP::Request->new( $action_map->{$action} );
	$request->header('Content-Type' => 'application/json' );
	$self->_set_content($request, $params);
	$self->_set_uri($action, $request, $params);
	return $request;
}

sub _set_uri {

	my ($self, $action, $request, $params) = @_;
	my $base_url = $self->get_api_url();
	my $uri_map = {
		'change_user_plan' => '/users/'.($params->{user_id} || '').'/plan',
		'create_user'      => '/users',
		'delete_user'      => '/users/'.($params->{user_id} || ''),
		'list_user'        => '/users/'.($params->{user_id} || ''),
	};
	$request->uri($base_url.$uri_map->{$action}.'?api_key='.$self->get_partner_key);
	return;
}

sub _fetch_required_params {

	my ($self, $action, $params) = @_;
	my $required_keys_map = {
		'create_user'      => { map { ($_ => 1) } qw(name email) },
		'list_user'        => { map { ($_ => 1) } qw(user_id) },
		'change_user_plan' => { map { ($_ => 1) } qw(user_id plan_id) },
	};
	$required_keys_map->{delete_user} = $required_keys_map->{list_user};
	return $required_keys_map->{$action};
}

sub _fetch_optional_params {

	my ($self, $action) = @_;
	my $optional_keys_map = {
		'create_user' => { map { ($_ => 1) } qw(password time_zone partner_data plan_id) },
	};
	return $optional_keys_map->{$action};
}

=head1 AUTHOR

Rishwanth Yeddula, C<< <ryeddula at cpan.org> >>

=cut

1;
