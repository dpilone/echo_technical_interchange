#!/usr/bin/env perl

#
# Note: This example uses the JSON and REST::Client modules from CPAN.  You'll
# need to install those in order to run the example code.
#

use strict;
use warnings;

use JSON;
use REST::Client;

# Other possible endpoints:
# Testbed: https://testbed.echo.nasa.gov/echo-rest/users
# Parter Test: https://api-test.echo.nasa.gov/echo-rest/users
# Operations: https://api.echo.nasa.gov/echo-rest/users
my $echo_rest_users_url = 'http://localhost:10000/echo-rest/users';

# Create the REST client
my $client = REST::Client->new();

# We'll be using JSON here.  We could also have used application/xml
my $request_headers = {
  'Content-Type' => 'application/json',
  'Accept' => 'application/json'
};

# Describe the user
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

# Create a JSON parser
my $json = JSON->new;

# Convert our user to a JSON string
my $user_json = $json->encode($user_hash);

# POST the user to the REST API
$client->POST($echo_rest_users_url, $user_json, $request_headers);

my $response_code = $client->responseCode();
if ($response_code == 201) {
  # If we get a 201 status code back, the user was created
  print "User created!\n";
}
else {
  # If we get anything other than a 201, something went wrong
  print "Failed to create user\n";
  my $response_content = $json->decode($client->responseContent());
  foreach my $error (@{$response_content->{'errors'}}) {
    print "  - ${error}\n";
  }
}

