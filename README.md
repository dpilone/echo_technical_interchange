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
  * JSON
  * XML::Hash
  * Mozilla::CA


## Running PERL examples

Each PERL example is self contained and can be run by itself. For example the login.pl example can be run like this.

    cd perl/ingest
    perl login.pl

### Java Setup

Download apache httpclient 4.2.5 from http://hc.apache.org/downloads.cgi

TODO - Verify the setup and possibly add a .env file to setup things like the CLASSPATH 

## Running java examples

TODO
