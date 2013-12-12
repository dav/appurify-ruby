module Appurify
  class Client
    attr_accessor :scheme, :host, :port, :key, :secret, :request_timeout, :open_timeout, :last_request

    def initialize(key, secret, options={})
      @key = key
      @secret = secret

      @scheme, @host, @port, @request_timeout, @open_timeout = {
        scheme: "https",
        host: HOSTNAME,
        port: 443,
        request_timeout: 600,
        open_timeout: 10
      }.merge(options).values
    end

    def access_token
      unless access_token_active?
        url = build_url("access_token", "generate")
        data = {
          :key => @key,
          :secret => @secret
        }

        #result = post(url, data, false)
        result = post(url, data)
        @access_token = result["access_token"]
        @access_token_ttl = result["ttl"]
        @access_token_created = Time.now
      end

      @access_token
    end

    def device_types
      url = build_url("devices", "list")
      get(url)
    end

    def network_conditions
      url = build_url("devices", "config/networks/list")
      get(url)
    end

    def apps
      url = build_url("apps", "list")
      get(url)
    end

    def tests
      url = build_url("tests", "list")
      get(url)
    end

    def upload_app_from_file(app_path)
      abort "App not found" unless File.exists? app_path
      upload_app("raw", File.new(app_path, 'rb'))
    end

    def upload_app_from_url(app_url)
      upload_app("url", app_url)
    end

    def upload_app(source_type, source)
      url = build_url("apps", "upload")
      data = {
        :access_token => access_token,
        :source_type => source_type,
        :source => source
      }

      post(url, data)
    end

    def upload_test_from_file(test_path, test_type)
      abort "Tests not found" unless File.exists? test_path
      upload_test("raw", File.new(test_path, 'rb'), test_type)
    end

    def upload_test_from_url(test_url, test_type)
      upload_test("url", test_url, test_type)
    end

    def upload_test(source_type, source, test_type)
      url = build_url("tests", "upload")
      data = {
        :access_token => access_token,
        :source_type => source_type,
        :test_type => test_type,
        :source => source
      }

      post(url, data)
    end

    def upload_config(test_id, config_src)
      abort "Config not found" unless File.exists? config_src
      url = build_url("config", "upload")
      data = {
        :access_token => access_token,
        :test_id => test_id,
        :source => File.new(config_src, 'rb')
      }

      post(url, data)
    end

    def upload_device_conditions(test_id, conditions)
      url = build_url("config", "upload")
      file_data = "[appurify]\n" +  conditions.keys.collect{ |k| k.to_s + "=" + conditions[k].to_s }.join("\n")

      file = StringIO.new(file_data)
      file.class.class_eval { attr_accessor :name }
      file.class.class_eval { attr_accessor :path }
      file.name = "config.cnf"
      file.path = "config.cnf"

      data = {
        :access_token => access_token,
        :test_id => test_id,
        :source => file
      }

      post(url, data)
    end

    def run_test(device_type_id, app_id, test_id, async=1)
      url = build_url("tests", "run")
      data = {
        :access_token => access_token,
        :device_type_id => device_type_id,
        :app_id => app_id,
        :test_id => test_id,
        :async => async
      }

      post(url, data)
    end

    def monitor_test(test_run_id)
      url = build_url("tests", "check")
      params = { test_run_id: test_run_id }
      get(url, params)
    end

    private

    def access_token_active?
      @access_token && Time.now < @access_token_created + @access_token_ttl
    end

    def build_url(type, resource)
      @scheme + "://" + [@host, "resource", type, resource].join("/") + "/"
    end

    def get(url, params={})
      @last_request = {
        url: url,
        request: params
      }

      query_string_params = params.collect{ |p| "&#{p[0].to_s}=#{p[1].to_s}" }.join
      result = RestClient::Request.execute(:method => :get, :url => "#{url}?access_token=#{access_token}#{query_string_params}", :timeout => @request_timeout, :open_timeout => @open_timeout)
      @last_request[:response] = result

      JSON.parse(result)["response"]
    end

    def post(url, data, capture_request=true)
      if capture_request
        @last_request = {
          url: url,
          request: data
        }
      end

      result = RestClient::Request.execute(:method => :post, :url => url, :payload => data, :timeout => @request_timeout, :open_timeout => @open_timeout)
      @last_request[:response] = result if capture_request

      JSON.parse(result)["response"]
    end

  end
end