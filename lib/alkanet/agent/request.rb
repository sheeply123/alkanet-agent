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
          conn.adapter  Faraday.default_adapter
        end
      end

      def fetch_collector_info
        @api_clinet.get "/api/collectors/oneself.json"
      end

      def fetch_job_info(id)
        @api_clinet.get "/api/jobs/#{id}.json"
      end

      def update_job_info(id, params)
        @api_clinet.put "/api/jobs/#{id}.json", params
      end

      def upload_tracelog(id, tracelog)
        @api_clinet.post "/api/jobs/#{id}/tracelog", {
          tracelog: Faraday::UploadIO.new(tracelog, 'binary/octet-stream')
        }
      end

      def upload_report(id, tracelog)
        @api_clinet.post "/api/jobs/#{id}/report", {
          report: Faraday::UploadIO.new(tracelog, 'binary/octet-stream')
        }
      end
    end
  end
end
