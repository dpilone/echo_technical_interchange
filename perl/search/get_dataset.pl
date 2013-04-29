#!/usr/bin/env perl

use strict;
use warnings;

use HTTP::Status qw(:constants);
use REST::Client;
use URI::Encode qw(uri_encode);
use XML::Simple;

sub get_dataset_id {
  my $datasets_url = 'https://testbed.echo.nasa.gov/catalog-rest/echo_catalog/datasets';

  # Build up the list of search parameters that we're using
  my @query_parameters = ();
  push(@query_parameters, 'bounding_box=10.488,-0.703,53.331,68.906');
  push(@query_parameters, 'temporal[]=2009-01-01T10:00:00Z,2010-03-10T12:00:00Z');
  push(@query_parameters, 'provider=LPDAAC_ECS');

  my $query_string = uri_encode(join(q{&}, @query_parameters));

  my $request_url = "${datasets_url}?${query_string}";

  # Create the REST client
  my $client = REST::Client->new();

  # We'll be using XML here.  We could also have used application/json
  my $request_headers = {
    'Accept' => 'application/xml',
  };

  # Issue the GET request
  print "> GET ${request_url}\n";
  $client->GET($request_url, $request_headers);

  my $response_hash_ref = XMLin($client->responseContent());
  return $response_hash_ref->{'reference'}->{'id'};
}

my $dataset_id = get_dataset_id();
print "${dataset_id}\n";

