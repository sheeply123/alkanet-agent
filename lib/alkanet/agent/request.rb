require 'faraday'
require 'faraday_middleware/multi_json'

module Alkanet
  module Agent
    class Request
      def initialize(option)
        @api_clinet = Faraday.new(option) do |conn|
          conn.request :multipart
          conn.request  :url_encoded
          conn.response :raise_error
          conn.response :multi_json, symbolize_keys: true
          conn.adapter  :httpclient
        end
      end

      def fetch_collector_info
        @api_clinet.get('/internal/api/collectors/oneself.json')
      end

      def fetch_job_info(id)
        @api_clinet.get("/internal/api/jobs/#{id}.json")
      end

      def update_job_info(id, params)
        @api_clinet.put("/internal/api/jobs/#{id}.json", params)
      end

      def upload_tracelog(id, tracelog)
        tracelog_io = Faraday::UploadIO.new(tracelog, 'binary/octet-stream')
        @api_clinet.post("/internal/api/jobs/#{id}/tracelog", tracelog: tracelog_io) do |req|
          req.options.timeout = 0
        end
      end

      def upload_report(id, tracelog)
        tracelog_io = Faraday::UploadIO.new(tracelog, 'binary/octet-stream')
        @api_clinet.post("/internal/api/jobs/#{id}/report", report: tracelog_io) do |req|
          req.options.timeout = 0
        end
      end
    end
  end
end
