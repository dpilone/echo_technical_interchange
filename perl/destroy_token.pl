#!/usr/bin/env perl

#
# Note: This example uses the JSON, File::Spec, and REST::Client
# modules from CPAN.  You'll need to install those in order to run the example
# code.
#

use strict;
use warnings;

use JSON;
use REST::Client;

my $token = '08D386C0-D020-A2BD-A65E-F54593A56FDB';

# Other possible endpoints:
# Testbed: https://testbed.echo.nasa.gov/echo-rest/tokens
# Parter Test: https://api-test.echo.nasa.gov/echo-rest/tokens
# Operations: https://api.echo.nasa.gov/echo-rest/tokens
my $echo_rest_tokens_url = 'http://localhost:10000/echo-rest/tokens';

# Example URL: http://localhost:10000/echo-rest/tokens/08D386C0-D020-A2BD-A65E-F54593A56FDB
my $token_url = "${echo_rest_tokens_url}/${token}";

# Create the REST client
my $client = REST::Client->new();

# DELETE the token
$client->DELETE($token_url, { 'Accept' => 'application/json' });

my $response_code = $client->responseCode();

if ($response_code == 204) {
  # If we get a 204 status code back, it worked
  print "Deleted token\n";
}
else {
  # If we get anything other than a 204, something went wrong
  print "Failed to destroy token\n";
  my $json = JSON->new;
  my $response_content = $json->decode($client->responseContent());
  foreach my $error (@{$response_content->{'errors'}}) {
    print "  - ${error}\n";
  }
}

