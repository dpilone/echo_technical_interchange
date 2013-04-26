#!/usr/bin/env perl

#
# Note: This example uses the Net::Address::IP::Local, REST::Client, and
# XML::Hash modules from CPAN.  You'll need to install those in order to run
# the example code.
#

use strict;
use warnings;

use HTTP::Status qw(:constants);
use Net::Address::IP::Local;
use REST::Client;
use XML::Hash;

# The REST endpoint to create a token in the ECHO Testbed environment
my $echo_rest_tokens_url = 'https://testbed.echo.nasa.gov/echo-rest/tokens';

# Create the REST client
my $client = REST::Client->new();

# We'll be using XML here.  We could also have used application/json
my $request_headers = {
  'Content-type' => 'application/xml',
  'Accept' => 'application/xml'
};

# Figure out our IP address, since that's required to get a token
my $ip_address = Net::Address::IP::Local->public;

# The token request being sent
my $token_request_hash = {
  'token' => {
    'username' => { 'text' => 'guest' },
    'password' => { 'text' => 'user@example.com' },
    'client_id' => { 'text' => 'ETIM demo' },
    'user_ip_address' => { 'text' => $ip_address }
  }
};

# For simplicity's sake, we'll use the XML::Hash module
my $xml_converter = XML::Hash->new();

my $token_request_xml = $xml_converter->fromHashtoXMLString($token_request_hash);

# POST the request to the REST API
$client->POST($echo_rest_tokens_url, $token_request_xml, $request_headers);

# Convert the XML response to something we can work with
my $response_hash_ref = $xml_converter->fromXMLStringtoHash($client->responseContent());

if ($client->responseCode() == HTTP_CREATED) {
  # If we get a 201 status code back, the token was created
  my $token = $response_hash_ref->{'token'}->{'id'}->{'text'};
  print "Token: ${token}\n";
}
else {
  # If we get anything other than a 201, something went wrong
  print "Failed to create token\n";

  # Extract and print out the errors.
  my @errors = ();
  if (ref($response_hash_ref->{'errors'}->{'error'}) eq 'HASH') {
    push(@errors, $response_hash_ref->{'errors'}->{'error'}->{'text'});
  }
  else {
    foreach my $error (@{$response_hash_ref->{'errors'}->{'error'}}) {
      push(@errors, $error->{'text'});
    }
  }

  foreach my $error (@errors) {
    print "  - ${error}\n";
  }
}

