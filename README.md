NASA ECHO Technical Interchange
===============================

Temporary repository for the ECHO Technical Interchange development track material. 

## Setting up

Copy ingest_config.properties.template to ingest_config.properties. Update the values of username, password, and provider in ingest_config.properties.

### PERL Setup

Install the following CPAN modules:

  * Config::Properties
  * REST::Client
  * Net::Address::IP::Local

## Running PERL examples

Each PERL example is self contained and can be run by itself. For example the login.pl example can be run like this.

    cd perl/ingest
    PERL_LWP_SSL_VERIFY_HOSTNAME=0 perl login.pl

TODO Determine what needs to be changed to run the examples without PERL_LWP_SSL_VERIFY_HOSTNAME flag.


## Running java examples

TODO