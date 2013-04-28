import java.io.*;
import java.util.Properties;

import javax.xml.xpath.*;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.xml.sax.InputSource;

public class Login
{

  public static void main(String[] args) throws Exception
  {
    // Get username and password
    Properties properties = loadProperties();
    String username = properties.getProperty("username");
    String password = properties.getProperty("password");

    // Create the HTTPClient
    DefaultHttpClient httpClient = new DefaultHttpClient();

    String token = getToken(httpClient, username, password);
    System.out.println(token);
  }

  /**
   * Logs in and returns a token.
   * 
   * @return the token.
   * @throws Exception
   */
  private static String getToken(HttpClient httpClient, String username,
      String password) throws Exception
  {
    HttpPost httpPost = new HttpPost(
        "https://testbed.echo.nasa.gov/echo-rest/tokens");

    StringEntity requestEntity = new StringEntity(getLoginPostBody(username,
        password));
    requestEntity.setContentType("application/xml");
    httpPost.setEntity(requestEntity);

    HttpResponse response = httpClient.execute(httpPost);
    String token;
    try
    {
      String xmlResponse = readInputStream(response.getEntity().getContent());
      // Parse out the token value from the XML response
      token = applyXPath(xmlResponse, "/token/id");
    }
    finally
    {
      httpPost.releaseConnection();
    }
    return token;
  }

  /**
   * Returns the POST body to login.
   * 
   * @param username
   * @param password
   * @return XML POST body to login
   */
  private static String getLoginPostBody(String username, String password)
  {
    return "<token><username>"
        + username
        + "</username><password>"
        + password
        + "</password><client_id>ETIM Demo Java</client_id><user_ip_address>127.0.0.1</user_ip_address></token>";
  }

  /**
   * Applies an XPath to an XML string and returns the text result.
   * 
   * @param xml
   * @param xpath
   * @return Result of applying XPath.
   * @throws XPathExpressionException
   */
  private static String applyXPath(String xml, String xpath)
      throws XPathExpressionException
  {
    XPath evaluator = XPathFactory.newInstance().newXPath();
    return evaluator.evaluate(xpath, new InputSource(new StringReader(xml)));
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

  /**
   * Loads the Ingest config properties.
   * 
   * @return properties containing username, password, and provider.
   * @throws Exception
   */
  private static Properties loadProperties() throws Exception
  {
    FileInputStream in = null;
    Properties properties = new Properties();
    try
    {
      in = new FileInputStream("../../ingest_config.properties");
      properties.load(in);
    }
    finally
    {
      if (in != null)
      {
        in.close();
      }
    }
    return properties;
  }

}
