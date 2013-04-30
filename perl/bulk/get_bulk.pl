#!/usr/bin/env perl

use strict;
use warnings;

use HTTP::Status qw(:constants);
use REST::Client;
use URI::Escape;
use XML::Simple;

# Get the format from the command line, or default to xml
my $format = defined($ARGV[0]) ? $ARGV[0] : 'xml';

# Since this example is strictly for atom feeds, set $format to atom.
$format = "atom";

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

# Issue the GET request for obtaining the number of hits.
$client->GET($request_url);

# I'll be interested in the "Echo-Hits" return value later.
my $hits = $client->responseHeader('Echo-Hits');

# Start your looping through the hits!
my $page_size=50;
my $page_num=1;

# Append &page_size=something to the original request_url
$request_url = "${request_url}&page_size=${page_size}";
my $new_request_url = "${request_url}";
my $response_content;

while ( $page_num <= ($hits/$page_size + 1) ) {
  # Appending &page_num=$page_num loop variable here
  $new_request_url = "${request_url}&page_num=${page_num}";
  # Make another REST call with the page_num and page_size defined
  $client->GET($new_request_url);
  $response_content = $client->responseContent();
  # Start Looping through all of the responses, looking for link.../data# only
  foreach my $response_line (split(/\n/sxm, $response_content)) {
    my @fields = split (/"/, ${response_line});
    print "$fields[1]\n" if ($response_line =~ m/link.*\/data#/);
  }
  $page_num++;
}

