#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use File::Slurp;
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
    'Content-Type' => 'application/xml',
    'Accept' => 'application/xml'
  };

  # The token request being sent
  my $token_request_hash_ref = {
    'username' => { 'content' => $username },
    'password' => { 'content' => $password  },
    'client_id' => { 'content' => 'ETIM demo' },
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

  foreach my $error (@{$errors_ref->{'error'}}) {
    my $error_message = $error->{'content'};
    print "  - ${error_message}\n";
  }

  return;
}

sub delete_dataset {
  my ($token, $provider_id, $dataset_id) = @_;

  my $dataset_ingest_url = "https://testbed.echo.nasa.gov/catalog-rest/providers/${provider_id}/datasets/${dataset_id}";

  my $client = REST::Client->new();

  my $request_headers = {
    'Echo-Token' => $token
  };

  # PUT the dataset to the REST API
  $client->DELETE($dataset_ingest_url, $request_headers);

  if ($client->responseCode() == HTTP_NO_CONTENT) {
    # If a 204 status code is returned, the dataset was deleted
    print "Dataset was deleted.\n";
  }
  elsif ($client->responseCode() == HTTP_NOT_FOUND) {
    # If a 404 status code is returned, the dataset did not exist
    print "Dataset did not exist.\n";
  }
  else {
    # If we get anything other than a 200 or 404, something went wrong
    print "Failed to delete dataset\n";
    parse_and_display_errors($client->responseContent());
    exit 1;
  }

  return;
}
open my $fh, '<', '../../ingest_config.properties'
    or die "unable to open configuration file";

my $properties = Config::Properties->new();
$properties->load($fh);

my $provider_id = $properties->getProperty("provider");
my $username = $properties->getProperty("username");
my $password = $properties->getProperty("password");

my $dataset_id = "SampleValidCollection_10";
print "Deleting ${dataset_id}\n";

my $token = get_token($username, $password);
delete_dataset($token, $provider_id, $dataset_id);

