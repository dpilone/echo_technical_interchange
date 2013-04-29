#!/usr/bin/env perl

use strict;
use warnings;

use File::Temp qw(tempdir);
use HTTP::Status qw(:constants);
use LWP::Simple;
use REST::Client;
use URI::Escape;
use XML::Simple;

# Build the granules URL based on the requested format
my $granules_url = 'https://testbed.echo.nasa.gov/catalog-rest/echo_catalog/granules.echo10';

# Build up the list of search parameters that we're using
# Make sure that the query parameter values are URI encoded
my @query_parameters = ();

push(@query_parameters, 'page_size=' . uri_escape('10'));
push(@query_parameters, 'page_num=' . uri_escape('1'));
push(@query_parameters, 'bounding_box=' . uri_escape('10.488,-0.703,53.331,68.906'));
push(@query_parameters, 'temporal[]=' . uri_escape('2009-01-01T10:00:00Z,2010-03-10T12:00:00Z'));
push(@query_parameters, 'provider=' . uri_escape('LPDAAC_ECS'));
push(@query_parameters, 'dataset_id=' . uri_escape('MODIS/Terra+Aqua Nadir BRDF-Adjusted Reflectance 16-Day L3 Global 500m SIN Grid V005'));
push(@query_parameters, 'sort_key[]=' . uri_escape('-end_date'));
push(@query_parameters, 'day_night_flag=' . uri_escape('DAY'));

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

# Parse the response
my $granules_ref = XMLin($client->responseContent());

# Let's collect the browse URLs from the granules that we found
my @browse_urls;

foreach my $granule (@{$granules_ref->{'result'}}) {
  my $online_resources = $granule->{'Granule'}->{'OnlineResources'}->{'OnlineResource'};
  foreach my $online_resource (@{$online_resources}) {
    if ($online_resource->{'Type'} eq 'BROWSE') {
      push(@browse_urls, $online_resource->{'URL'});
    }
  }
}

# Now that we have the URLs, let's download them
my $output_dir = File::Temp::tempdir();

foreach my $browse_url (@browse_urls) {
  my $url = URI->new($browse_url);
  my $filename;
  (undef, undef, $filename) = File::Spec->splitpath($url->path);
  my $output_filename = File::Spec->catfile($output_dir, $filename);
  print "Fetching ${browse_url}\n";
  getstore($url, $output_filename);
}

print "Saved browse files to ${output_dir}\n";

