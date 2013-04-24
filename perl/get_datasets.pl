#!/usr/bin/env perl

#
# Note: This example uses the JSON, and REST::Client modules from CPAN.
# You'll need to install those in order to run the example code.
#

use strict;
use warnings;

use JSON;
use REST::Client;

my $datasets_url = 'http://localhost:10000/catalog-rest/echo_catalog/datasets';

# Create the REST client
my $client = REST::Client->new();

# We'll be using JSON here.
my $request_headers = {
  'Accept' => 'application/json'
};

# Create a JSON parser
my $json = JSON->new;

# GET blah blah blah
$client->GET($datasets_url, $request_headers);

# Decode the response JSON to a Perl datastructure
my $datasets = $json->decode($client->responseContent());

foreach my $dataset (@{$datasets->{'feed'}->{'entry'}}) {
  my $dataset_id = $dataset->{'dataset_id'};
  print "${dataset_id}\n";
}

