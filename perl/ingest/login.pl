#!/usr/bin/env perl

use strict;
use warnings;

use HTTP::Status qw(:constants);
use REST::Client;
use XML::Simple;
use Config::Properties;

sub get_token {
  my ($username, $password) = @_;

  # The REST endpoint to create a token in the ECHO Testbed environment
  my $echo_rest_tokens_url = 'https://testbed.echo.nasa.gov/echo-rest/tokens';

  # Create the REST client
  my $client = REST::Client->new();

  # We'll be using XML here.  We could also have used application/json
  my $request_headers = {
    'Content-type' => 'application/xml',
    'Accept' => 'application/xml'
  };

  # The token request being sent
  my $token_request_hash_ref = {
    'username' => { 'content' => $username },
    'password' => { 'content' => $password  },
    'client_id' => { 'content' => 'ETIM Demo PERL' },
    'user_ip_address' => { 'content' => '127.0.0.1' }
  };
  my $token_request_xml = XMLout($token_request_hash_ref, RootName => 'token');

  # POST the request to the REST API
  $client->POST($echo_rest_tokens_url, $token_request_xml, $request_headers);

  my $token = undef;

  if ($client->responseCode() == HTTP_CREATED) {
    # If we get a 201 status code back, the token was created
    my $response_hash_ref = XMLin($client->responseContent());
    $token = $response_hash_ref->{'id'};
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
  my $error_xml = shift;

  my $errors_ref = XMLin($error_xml, ForceArray => qw(error));

  foreach my $error (@{$errors_ref->{'error'}}) { print "  - ${error}\n"; }

  return;
}
open my $fh, '<', '../../ingest_config.properties'
    or die "unable to open configuration file";

my $properties = Config::Properties->new();
$properties->load($fh);

my $username = $properties->getProperty("username");
my $password = $properties->getProperty("password");

print 'Token: ' . get_token($username, $password) . "\n";

