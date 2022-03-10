require 'uri'
require 'json'

Puppet::Functions.create_function(:'influxdb::retrieve_token') do
  dispatch :retrieve_token do
    param 'String', :uri
    param 'String', :token_name
    param 'String', :admin_token_file
  end

  def retrieve_token(uri, token_name, admin_token_file)
    admin_token = File.read(admin_token_file)
    client = Puppet.runtime[:http]
    response = client.get(URI(uri + '/api/v2/authorizations'),
                           headers: { 'Authorization' => "Token #{admin_token}" })

    if response.success?
      body = JSON.parse(response.body)
      token = body['authorizations'].find { |auth| auth['description'] == token_name }
      token ? token['token'] : nil
    else
      puts response.body
      nil
    end
  end
end
