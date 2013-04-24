#!/usr/bin/env perl

#
# Note: This example uses the JSON, Net::Address::IP::Local, and REST::Client
# modules from CPAN.  You'll need to install those in order to run the example
# code.
#

use strict;
use warnings;

use JSON;
use Net::Address::IP::Local;
use REST::Client;

# Other possible endpoints:
# Testbed: https://testbed.echo.nasa.gov/echo-rest/tokens
# Parter Test: https://api-test.echo.nasa.gov/echo-rest/tokens
# Operations: https://api.echo.nasa.gov/echo-rest/tokens
my $echo_rest_tokens_url = 'http://localhost:10000/echo-rest/tokens';

# Create the REST client
my $client = REST::Client->new();

# We'll be using JSON here.  We could also have used application/xml
my $request_headers = {
  'Content-type' => 'application/json',
  'Accept' => 'application/json'
};

# Figure out our IP address, since that's required to get a token
my $ip_address = Net::Address::IP::Local->public;

# The request being sent
my $token_request_hash = {
  'token' => {
    'username' => 'example_user',
    'password' => 'qweQWE123!@#',
    'client_id' => 'create_token.pl',
    'user_ip_address' => $ip_address
  }
};

# Create a JSON parser
my $json = JSON->new;

# Convert our request data to a JSON string
my $token_request_json = $json->encode($token_request_hash);

# POST the request to the REST API
$client->POST($echo_rest_tokens_url, $token_request_json, $request_headers);

my $response_content = $json->decode($client->responseContent());
my $response_code = $client->responseCode();

if ($response_code == 201) {
  # If we get a 201 status code back, the token was created
  my $token = $response_content->{'token'}->{'id'};
  print "Token: ${token}\n";
}
else {
  # If we get anything other than a 201, something went wrong
  print "Failed to create token\n";
  foreach my $error (@{$response_content->{'errors'}}) {
    print "  - ${error}\n";
  }
}

