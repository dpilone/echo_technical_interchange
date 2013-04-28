#!/usr/bin/env perl

use strict;
use warnings;

use File::Spec;
use File::Temp qw(tempdir);
use HTTP::Status qw(:constants);
use LWP::Simple;
use Net::Address::IP::Local;
use REST::Client;
use URI;
use XML::Simple;

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

  # Figure out our IP address, since that's required to get a token
  my $ip_address = Net::Address::IP::Local->public;

  # The token request being sent
  my $token_request_hash_ref = {
    'username' => { 'content' => $username },
    'password' => { 'content' => $password  },
    'client_id' => { 'content' => 'ETIM demo' },
    'user_ip_address' => { 'content' => $ip_address }
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

sub parse_and_display_errors {
  my $error_xml = shift;

  my $errors_ref = XMLin($error_xml, ForceArray => qw(error));

  foreach my $error (@{$errors_ref->{'error'}}) { print "  - ${error}\n"; }

  return;
}

sub get_dataset_id {
  my $token = shift;
  my $datasets_url = 'https://testbed.echo.nasa.gov/catalog-rest/echo_catalog/datasets';

  # Build up the list of search parameters that we're using
  my @query_parameters = ();
  push(@query_parameters, 'bounding_box=10.488,-0.703,53.331,68.906');
  push(@query_parameters, 'temporal[]=2009-01-01T10:00:00Z,2010-03-10T12:00:00Z');
  push(@query_parameters, 'provider=LPDAAC_ECS');

  my $query_string = join(q{&}, @query_parameters);

  my $request_url = "${datasets_url}?${query_string}";

  # Create the REST client
  my $client = REST::Client->new();

  # We'll be using XML here.  We could also have used application/json
  my $request_headers = {
    'Accept' => 'application/xml',
    'Echo-Token'=> $token
  };

  # Issue the GET request
  $client->GET($request_url, $request_headers);

  my $response_hash_ref = XMLin($client->responseContent());
  return $response_hash_ref->{'reference'}->{'id'};
}

sub get_granules {
  my ($token, $dataset_id) = @_;
  my $granules_url = 'https://testbed.echo.nasa.gov/catalog-rest/echo_catalog/granules';

  # Build up the list of search parameters that we're using
  my @query_parameters = ();
  push(@query_parameters, 'page_size=10');
  push(@query_parameters, 'page_num=1');
  push(@query_parameters, 'bounding_box=10.488,-0.703,53.331,68.906');
  push(@query_parameters, 'bounding_box=10.488,-0.703,53.331,68.906');
  push(@query_parameters, 'temporal[]=2009-01-01T10:00:00Z,2010-03-10T12:00:00Z');
  push(@query_parameters, 'provider=LPDAAC_ECS');
  push(@query_parameters, "echo_collection_id=${dataset_id}");

  my $query_string = join(q{&}, @query_parameters);

  my $request_url = "${granules_url}?${query_string}";

  # Create the REST client
  my $client = REST::Client->new();

  # We'll be using XML here.  We could also have used application/json
  my $request_headers = {
    'Accept' => 'application/echo10+xml',
    'Echo-Token'=> $token
  };

  # Issue the GET request
  $client->GET($request_url, $request_headers);

  return XMLin($client->responseContent());
}

sub get_browse_urls {
  my $granules_ref = shift;

  my $output_dir = File::Temp::tempdir();
  my @browse_urls;

  foreach my $granule (@{$granules_ref->{'result'}}) {
    my $online_resources = $granule->{'Granule'}->{'OnlineResources'}->{'OnlineResource'};
    foreach my $online_resource (@{$online_resources}) {
      if ($online_resource->{'Type'} eq 'BROWSE') {
        push(@browse_urls, $online_resource->{'URL'});
      }
    }
  }

  return @browse_urls;
}

sub fetch_browse_files {
  my $browse_urls_ref = shift;

  my $output_dir = File::Temp::tempdir();

  foreach my $browse_url (@{$browse_urls_ref}) {
    my $url = URI->new($browse_url);
    my $filename;
    (undef, undef, $filename) = File::Spec->splitpath($url->path);
    my $output_filename = File::Spec->catfile($output_dir, $filename);
    print "Fetching ${browse_url}\n";
    getstore($url, $output_filename);
  }

  return $output_dir;
}

my $token = get_token('guest', 'woot');
my $dataset_id = get_dataset_id($token);
my $granules = get_granules($token, $dataset_id);
my @browse_urls = get_browse_urls($granules);
my $browse_dir = fetch_browse_files(\@browse_urls);

print "Saved browse files to ${browse_dir}\n";

