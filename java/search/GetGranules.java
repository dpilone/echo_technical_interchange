import java.io.*;
import java.net.URI;

import org.apache.http.client.utils.URIBuilder;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;


/**
 * This example shows how to search for and retrieve granule metadata from ECHO using 
 * the Catalog REST API.
 * 
 * @author yliu
 */
public class GetGranules
{
  public static void main(String[] args) throws Exception
  {
  	String format = null;
  	if (args.length > 0)
  	{
  		format = args[0];
  	}

  	// Create the HTTPClient
    DefaultHttpClient httpClient = new DefaultHttpClient();

    String reference = getGranules(httpClient, format);
    System.out.println(reference);
  }

  /**
   * Retrieve the granules in the given format.
   * 
   * @param httpClient
   *          the http client to use to send the data
   * @param format
   *          the format to retrieve the granules with
   * @return the granules in the given format.
   * @throws Exception
   */
  private static String getGranules(HttpClient httpClient, String format) throws Exception
  {
  	String url = "http://testbed.echo.nasa.gov/catalog-rest/echo_catalog/granules";
  	if (format != null)
  	{
  		url += "." + format;
  	}
  	
    URI uri = new URI(url);
    URIBuilder uribuilder = new URIBuilder(uri);
    uribuilder.setParameter("dataset_id", "MODIS/Terra+Aqua Nadir BRDF-Adjusted Reflectance 16-Day L3 Global 500m SIN Grid V005");
    uribuilder.setParameter("bounding_box", "10.488,-0.703,53.331,68.906");
    uribuilder.setParameter("temporal[]", "2009-01-01T10:00:00Z,2010-03-10T12:00:00Z");
    uribuilder.setParameter("provider", "LPDAAC_ECS");
    URI request_url = uribuilder.build();
    System.out.println("Request URL: " + request_url.toString());

    HttpGet httpGet = new HttpGet(request_url);
    HttpResponse response = httpClient.execute(httpGet);

    int responseCode = response.getStatusLine().getStatusCode();
    if (responseCode != 200)
    {
      System.out.println("Unexpected response code: " + responseCode);
    }

    String reference;
    try
    {
      reference = readInputStream(response.getEntity().getContent());
    }
    finally
    {
      httpGet.releaseConnection();
    }
    return reference;
  }

  /**
   * Reads an input stream and returns the contents as a string.
   * 
   * @param is
   *          input stream
   * @return string contents of input string
   * @throws IOException
   */
  private static String readInputStream(InputStream is) throws IOException
  {
    LineNumberReader reader = new LineNumberReader(new InputStreamReader(is));
    try
    {
      StringBuilder builder = new StringBuilder();
      String line = null;
      while ((line = reader.readLine()) != null)
      {
        if (builder.length() != 0)
        {
          builder.append("\n");
        }
        builder.append(line);
      }
      return builder.toString();
    }
    finally
    {
      reader.close();
    }
  }

}