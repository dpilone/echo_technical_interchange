import java.io.*;
import java.util.*;
import java.net.URI;

import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathFactory;

import org.apache.http.client.utils.URIBuilder;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.xml.sax.InputSource;

import org.w3c.dom.NodeList;

/**
 * This example shows how to extract Browse URLs from granule metadata retrieved from ECHO using 
 * the Catalog REST API.
 * 
 * @author yliu
 */
public class GetBrowseImages
{
  public static void main(String[] args) throws Exception
  {
  	// Create the HTTPClient
    DefaultHttpClient httpClient = new DefaultHttpClient();

    List<String> urls = getBrowseUrls(httpClient);

  	for(String url: urls){
      System.out.println(url);
    }
  }

  /**
   * Retrieve the browse urls for the search granule results
   * 
   * @param httpClient
   *          the http client to use to send the data
   * @return the browse urls.
   * @throws Exception
   */
  private static List<String> getBrowseUrls(HttpClient httpClient) throws Exception
  {
    URI uri = new URI("http://testbed.echo.nasa.gov/catalog-rest/echo_catalog/granules.echo10");
    URIBuilder uribuilder = new URIBuilder(uri);
    uribuilder.setParameter("dataset_id", "MODIS/Terra+Aqua Nadir BRDF-Adjusted Reflectance 16-Day L3 Global 500m SIN Grid V005");
    uribuilder.setParameter("bounding_box", "10.488,-0.703,53.331,68.906");
    uribuilder.setParameter("temporal[]", "2009-01-01T10:00:00Z,2010-03-10T12:00:00Z");
    uribuilder.setParameter("provider", "LPDAAC_ECS");
    uribuilder.setParameter("sort_key[]", "end_date");
    uribuilder.setParameter("day_night_flag", "DAY");
    URI request_url = uribuilder.build();
    System.out.println("Request URL: " + request_url.toString());

    HttpGet httpGet = new HttpGet(request_url);
    HttpResponse response = httpClient.execute(httpGet);

    int responseCode = response.getStatusLine().getStatusCode();
    if (responseCode != 200)
    {
      System.out.println("Unexpected response code: " + responseCode);
    }

    List<String> urls;
    try
    {
      urls = getBrowseJpgs(response.getEntity().getContent());
    }
    finally
    {
      httpGet.releaseConnection();
    }
    
    return urls;
  }

  /**
   * Applies an XPath to the response inputstream and filter for only the jpg files
   * 
   * @param is
   *     input stream
   * @return list of browse urls.
   */
  private static List<String> getBrowseJpgs(InputStream is) throws Exception
  {
  	String xpath = "/results/result/Granule/OnlineResources/OnlineResource/URL";
    XPath xpathInstance = XPathFactory.newInstance().newXPath();
    XPathExpression evaluator = xpathInstance.compile(xpath);
    NodeList result = (NodeList) evaluator.evaluate(new InputSource(is), XPathConstants.NODESET);
    ArrayList<String> urls = new ArrayList<String>();
    for (int i = 0; i < result.getLength(); i++) {
    	String url = result.item(i).getTextContent();
    	if (url.endsWith(".jpg"))
    	{
    		urls.add(url);
    	}
    }
    
    return urls;
  }

}