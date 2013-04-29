#!/usr/bin/env perl

use strict;
use warnings;

use HTTP::Status qw(:constants);
use REST::Client;
use URI::Escape;
use XML::Simple;

# Get the format from the command line, or default to xml
my $format = defined($ARGV[0]) ? $ARGV[0] : 'xml';

# Build the granules URL based on the requested format
my $granules_url = "https://testbed.echo.nasa.gov/catalog-rest/echo_catalog/granules.${format}";

# Build up the list of search parameters that we're using
# Make sure that the query parameter values are URI encoded
my @query_parameters = ();

push(@query_parameters, 'dataset_id=' . uri_escape('MODIS/Terra+Aqua Nadir BRDF-Adjusted Reflectance 16-Day L3 Global 500m SIN Grid V005'));
push(@query_parameters, 'bounding_box=' . uri_escape('10.488,-0.703,53.331,68.906'));
push(@query_parameters, 'temporal[]=' . uri_escape('2009-01-01T10:00:00Z,2010-03-10T12:00:00Z'));
push(@query_parameters, 'provider=' . uri_escape('LPDAAC_ECS'));

my $query_string = join(q{&}, @query_parameters);

# Add the query parameters to the request URL
my $request_url = "${granules_url}?${query_string}";

# Create the REST client
my $client = REST::Client->new();

# Issue the GET request
print "> GET ${request_url}\n";
$client->GET($request_url);

my $response_content = $client->responseContent();

foreach my $response_line (split(/\n/sxm, $response_content)) {
  print "< ${response_line}\n"
}

