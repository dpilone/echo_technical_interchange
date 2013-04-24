#!/usr/bin/env perl

use strict;
use warnings;

use JSON;
use REST::Client;

my $echo_rest_users_url = 'http://localhost:10000/echo-rest/users';

my $client = REST::Client->new();

my $request_headers = {
  'Content-type' => 'application/json',
  'Accept' => 'application/json'
};

my $user_hash = {
  'user' => {
    'addresses' => [
      { 'country' => 'United States' }
    ],
    'email' => 'user@example.com',
    'first_name' => 'Joe',
    'last_name' => 'Example',
    'opt_in' => JSON::false,
    'password' => 'qweQWE123!@#',
    'user_domain' => 'GOVERNMENT',
    'user_region' => 'USA',
    'username' => 'example_user'
  }
};

my $json = JSON->new;

my $user_json = $json->encode($user_hash);

$client->POST($echo_rest_users_url, $user_json, $request_headers);

my $response_code = $client->responseCode();
if ($response_code == 201) {
  print "User created!\n";
}
else {
  print "Failed to create user\n";
  my $response_content = $json->decode($client->responseContent());
  foreach my $error (@{$response_content->{'errors'}}) {
    print "  - ${error}\n";
  }
}

