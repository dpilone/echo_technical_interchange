#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use HTTP::Status qw(:constants);
use JSON;
use REST::Client;
use Config::Properties;

sub get_token {
  my ($username, $password) = @_;

  # The REST endpoint to create a token in the ECHO Testbed environment
  my $echo_rest_tokens_url = 'https://testbed.echo.nasa.gov/echo-rest/tokens';

  # Create the REST client
  my $client = REST::Client->new();

  # We'll be using XML here.  We could also have used application/json
  my $request_headers = {
    'Content-Type' => 'application/json',
    'Accept' => 'application/json'
  };

  # The token request being sent
  my $token_request_hash_ref = {
    'token' => {
      'username' => $username,
      'password' => $password,
      'client_id' => 'ETIM Demo PERL',
      'user_ip_address' => '127.0.0.1'
    }
  };
  my $token_request_json = JSON::encode_json($token_request_hash_ref);

  # POST the request to the REST API
  $client->POST($echo_rest_tokens_url, $token_request_json, $request_headers);

  my $token = undef;

  if ($client->responseCode() == HTTP_CREATED) {
    # If we get a 201 status code back, the token was created
    my $response_hash_ref = JSON::decode_json($client->responseContent());
    $token = $response_hash_ref->{'token'}->{'id'};
  }
  else {
    # If we get anything other than a 201, something went wrong
    print "Failed to create token\n";
    parse_and_display_errors($client->responseContent());
    exit 1;
  }

  return $token;
}

# Pull out and display the errors
sub parse_and_display_errors {
  my $error_json = shift;

  my $errors_ref = JSON::decode_json($error_json);

  foreach my $error (@{$errors_ref->{'errors'}}) { print "  - ${error}\n"; }

  return;
}
open my $fh, '<', '../../ingest_config.properties'
    or die "unable to open configuration file";
    
my $properties = Config::Properties->new();
$properties->load($fh);

my $username = $properties->getProperty("username");
my $password = $properties->getProperty("password");

print 'Token: ' . get_token($username, $password) . "\n";
