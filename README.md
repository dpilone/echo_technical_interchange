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

## Running Java examples

The Java Examples use the [Apache HttpComponents](http://hc.apache.org) library, http://hc.apache.org. The required jar files have already been bundled with the examples to make them easier to run them.

### Compiling

    cd java/ingest
    javac -cp ../httpclient-4.2.5.jar:../httpcore-4.2.4.jar:../commons-logging-1.1.1.jar:. IngestDataset.java

### Running

    java -cp ../httpclient-4.2.5.jar:../httpcore-4.2.4.jar:../commons-logging-1.1.1.jar:. IngestDataset
